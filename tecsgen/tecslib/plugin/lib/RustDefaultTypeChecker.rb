require 'yaml'
require 'json'

module Default
  class Catalog
    attr_reader :entries

    def initialize(source)
      @entries = case source
                 when String
                   load_from_path(source)
                 when Array
                   source
                 else
                   raise ArgumentError, "Catalog source must be a path String or an Array"
                 end
      # 事前にテンプレートをASTへパース&キャッシュ
      @parsed_entries = @entries.map do |e|
        {
          raw: e,
          default: e['default'] || e[:default],
          requires: (e['requires'] || e[:requires] || []),
          generics: (e['generics'] || e[:generics] || []).map(&:to_s),
          template_str: (e['template'] || e[:template]).to_s,
          template_ast: parse_type((e['template'] || e[:template]).to_s)
        }
      end
    end

    def default_impl?(type_str)
      ast = parse_type(type_str)

      # 1) テンプレート一致＋requires満たすものがあればOK
      @parsed_entries.each do |e|
        next unless truthy?(e[:default])
        ok, bindings = match_ast(ast, e[:template_ast], e[:generics])
        next unless ok
        return true if requires_satisfied?(e[:requires], bindings)
      end

      # 2) 非ジェネリクス・名前一致（フォールバック）
      @parsed_entries.any? do |e|
        next false unless truthy?(e[:default])
        tmpl = e[:template_str]
        ast[:kind] == :normal && ast[:args].empty? && tmpl == ast[:name]
      end
    end

    private

    def truthy?(v)
      return v == true
    end

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

    # ===== パーサ & マッチャ =====

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

    # 返り値: { kind: :normal|:array|:tuple, name: String, args: [...] }
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

    # concrete(AST) が tmpl(AST)（ジェネリクス含む）に合致するか
    # 戻り値 [matched:boolean, bindings: { "T" => concrete_ast, "N" => "32" ... }]
    def match_ast(conc, tmpl, generics)
      # テンプレート位置がジェネリクス記号（T/E/N）なら束縛
      if tmpl[:kind] == :normal && tmpl[:args].empty? && generics.include?(tmpl[:name])
        return [true, { tmpl[:name] => conc }]
      end

      # 配列
      if tmpl[:kind] == :array
        return [false, {}] unless conc[:kind] == :array
        ok_e, bind_e = match_ast(conc[:args][0], tmpl[:args][0], generics)

        n_tmpl = tmpl[:args][1]
        n_conc = conc[:args][1]
        ok_n = true
        bind_n = {}

        if generics.include?(n_tmpl.to_s)
          bind_n[n_tmpl.to_s] = n_conc # そのまま束縛
        else
          ok_n = (n_tmpl.to_s == n_conc.to_s)
        end

        return [ok_e && ok_n, bind_e.merge(bind_n)]
      end

      # タプル
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

      # 通常
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

    # requires（["T: Default", "U: Default"] など）を満たすか
    def requires_satisfied?(reqs, bindings)
      reqs.all? do |req|
        lhs, trait = req.split(':').map!(&:strip)
        return false unless trait == 'Default'
        bound = bindings[lhs]
        # 配列長Nのような数値束縛はDefault判定対象外 → false
        return false unless bound.is_a?(Hash)
        default_impl?(render_type(bound))
      end
    end

    # デバッグ用：AST→文字列
    def render_type(ast)
      case ast[:kind]
      when :array
        "[#{render_type(ast[:args][0])}; #{ast[:args][1]}]"
      when :tuple
        "(" + ast[:args].map { |a| render_type(a) }.join(", ") + ")"
      else
        if ast[:args].empty?
          ast[:name]
        else
          ast[:name] + "<" + ast[:args].map { |a| render_type(a) }.join(", ") + ">"
        end
      end
    end
  end

  # 共有のシングルトン風に使いたい場合はこちら
  @catalog_instance = nil

  def self.load!(source)
    @catalog_instance = Catalog.new(source)
  end

  def self.default_impl?(type_str)
    raise "Default catalog not loaded. Call Default.load!(source) first." unless @catalog_instance
    @catalog_instance.default_impl?(type_str)
  end
end