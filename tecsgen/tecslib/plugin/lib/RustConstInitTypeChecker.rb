require 'yaml'
require 'json'

# ConstInit: determine if a Rust type can be initialized in a const context,
# and return that expression as a String.
module ConstInit
  class Catalog
    def initialize(source)
      @entries = case source
                 when String
                   load_from_path(source)
                 when Array
                   source
                 else
                   raise ArgumentError, 'Catalog source must be a path String or an Array'
                 end
      @parsed = @entries.map do |e|
        {
          template_str: (e['template'] || e[:template]).to_s,
          expr: (e['expr'] || e[:expr]).to_s,
          generics: ((e['generics'] || e[:generics] || []).map(&:to_s)),
        }.merge(template_ast: parse_type((e['template'] || e[:template]).to_s))
      end
    end

    # Return [ok:boolean, expr:String]
    def const_expr(type_str, custom_types: [])
      ast = parse_type(type_str)

      # nested custom struct -> Type::const_init()
      if ast[:kind] == :normal && ast[:args].empty? && custom_types.include?(ast[:name])
        return [true, "#{ast[:name]}::const_init()"]
      end

      # 1) Catalog templates
      @parsed.each do |e|
        ok, bindings = match_ast(ast, e[:template_ast], e[:generics])
        next unless ok
        expr, ok2 = render_expr(e[:expr], bindings, custom_types)
        return [true, expr] if ok2
      end

      # 2) Built-in fallbacks (bool/nums/char/unit)
      base = builtin_expr(ast)
      return [true, base] if base

      [false, nil]
    end

    private

    def load_from_path(path)
      text = File.read(path)
      ext = File.extname(path).downcase
      begin
        case ext
        when '.yml', '.yaml'
          YAML.safe_load(text, permitted_classes: [], aliases: false)
        when '.json'
          JSON.parse(text)
        else
          YAML.safe_load(text, permitted_classes: [], aliases: false)
        end
      rescue
        JSON.parse(text)
      end
    end

    def split_top_level(str, sep = ',')
      parts = []
      da = ds = dp = 0
      buf = ''
      str.each_char do |ch|
        case ch
        when '<' then da += 1
        when '>' then da -= 1
        when '[' then ds += 1
        when ']' then ds -= 1
        when '(' then dp += 1
        when ')' then dp -= 1
        when sep
          if da.zero? && ds.zero? && dp.zero?
            parts << buf.strip
            buf.clear
            next
          end
        end
        buf << ch
      end
      parts << buf.strip unless buf.empty?
      parts
    end

    def parse_type(str)
      s = str.strip
      # [T; N]
      if s.start_with?('[') && s.end_with?(']')
        inner = s[1..-2].strip
        parts = split_top_level(inner, ';')
        raise "Invalid array type: #{str}" unless parts.size == 2
        return { kind: :array, name: 'array', args: [parse_type(parts[0]), parts[1].strip] }
      end
      # (T,U, V)
      if s.start_with?('(') && s.end_with?(')')
        inner = s[1..-2].strip
        return { kind: :tuple, name: 'tuple', args: split_top_level(inner, ',').map { |e| parse_type(e) } }
      end
      # Name<...>
      if (lt = s.index('<'))
        raise "Type must end with '>': #{str}" unless s.end_with?('>')
        name  = s[0...lt].strip
        inner = s[(lt + 1)...-1].strip
        return { kind: :normal, name: name, args: split_top_level(inner, ',').map { |a| parse_type(a) } }
      end
      { kind: :normal, name: s, args: [] }
    end

    def match_ast(conc, tmpl, generics)
      # Generic symbol
      if tmpl[:kind] == :normal && tmpl[:args].empty? && generics.include?(tmpl[:name])
        return [true, { tmpl[:name] => conc }]
      end

      if tmpl[:kind] == :array
        return [false, {}] unless conc[:kind] == :array
        ok_e, bind_e = match_ast(conc[:args][0], tmpl[:args][0], generics)

        n_tmpl = tmpl[:args][1]
        n_conc = conc[:args][1]
        ok_n = true
        bind_n = {}

        if generics.include?(n_tmpl.to_s)
          bind_n[n_tmpl.to_s] = n_conc
        else
          ok_n = (n_tmpl.to_s == n_conc.to_s)
        end

        return [ok_e && ok_n, bind_e.merge(bind_n)]
      end

      if tmpl[:kind] == :tuple
        return [false, {}] unless conc[:kind] == :tuple
        return [false, {}] unless conc[:args].size == tmpl[:args].size
        all_ok = true
        all_bind = {}
        tmpl[:args].each_with_index do |sub_t, i|
          ok, b = match_ast(conc[:args][i], sub_t, generics)
          all_ok &&= ok
          all_bind.merge!(b)
        end
        return [all_ok, all_bind]
      end

      return [false, {}] unless conc[:kind] == :normal
      return [false, {}] unless conc[:name] == tmpl[:name]
      return [false, {}] unless conc[:args].size == tmpl[:args].size

      all_ok = true
      all_bind = {}
      tmpl[:args].each_with_index do |sub_t, i|
        ok, b = match_ast(conc[:args][i], sub_t, generics)
        all_ok &&= ok
        all_bind.merge!(b)
      end
      [all_ok, all_bind]
    end

    def render_expr(expr_tmpl, bindings, custom_types)
      rendered = expr_tmpl.dup
      rendered.gsub!(/\$\{N\}/) do
        b = bindings['N']
        b.is_a?(Hash) ? render_type(b) : b.to_s
      end

      # Replace ${E0}, ${E1}, ... with const expr for that sub-ast
      # We support explicit bindings: "0", "0.0" etc. or nested AST
      idx = 0
      loop do
        key = "${E#{idx}}"
        break unless rendered.include?(key)
        ast = bindings[idx.to_s] || bindings["E#{idx}"] || bindings['T'] || nil
        ok, e = if ast.is_a?(Hash)
                  const_expr(render_type(ast), custom_types: custom_types)
                else
                  # literal like "0" or "0.0"
                  [true, ast.to_s]
                end
        return [nil, false] unless ok && e
        rendered.gsub!(key, e)
        idx += 1
      end
      [rendered, true]
    end

    def render_type(ast)
      case ast[:kind]
      when :array
        "[#{render_type(ast[:args][0])}; #{ast[:args][1]}]"
      when :tuple
        '(' + ast[:args].map { |a| render_type(a) }.join(', ') + ')'
      else
        if ast[:args].empty?
          ast[:name]
        else
          ast[:name] + '<' + ast[:args].map { |a| render_type(a) }.join(', ') + '>'
        end
      end
    end

    def builtin_expr(ast)
      return '()' if ast[:kind] == :normal && ast[:name] == '()'
      return "'\\0'" if ast[:kind] == :normal && ast[:name] == 'char'
      return 'false' if ast[:kind] == :normal && ast[:name] == 'bool'
      if ast[:kind] == :normal && %w[i8 i16 i32 i64 i128 isize u8 u16 u32 u64 u128 usize].include?(ast[:name])
        return '0'
      end
      if ast[:kind] == :normal && %w[f32 f64].include?(ast[:name])
        return '0.0'
      end
      nil
    end
  end

  @catalog_instance = nil

  def self.load!(source)
    @catalog_instance = Catalog.new(source)
  end

  def self.const_expr(type_str, custom_types: [])
    raise 'ConstInit catalog not loaded. Call ConstInit.load!(source) first.' unless @catalog_instance
    @catalog_instance.const_expr(type_str, custom_types: custom_types)
  end
end
