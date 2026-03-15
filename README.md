# TECS/Rust (Rust Support for TECS Generator)

TECS/Rust は、組込みコンポーネントシステム TECS (TOPPERS Embedded Component System) において、コンポーネントの実装言語として安全性に優れた Rust を利用可能にするためのジェネレータ拡張（プラグイン群）です。
従来の C 言語によるコンポーネント実装に加え、Rust 言語を用いた高信頼な組込みシステムの開発を支援します。
このプロジェクトは実験的なリリースであり、TECS の一部の機能のみをサポートしています。

## 提供されている機能（プラグイン群）

本リポジトリでは、以下の環境およびカーネルに対応した Rust コード生成プラグインが実装・提供されています。

* **RustGenPlugin 系** (`RustGenPlugin.rb`, `RustGenCellPlugin.rb`, `RustGenCelltypePlugin.rb`)
  一般的な Rust コード生成（型定義の変換、定数最適化、ジェネリクスを活用したセル構造体の生成など）を行うコア機能を提供します。

* **RustITRONPlugin 系** (`RustITRONPlugin.rb`, `RustITRONCellPlugin.rb`, `RustITRONCelltypePlugin.rb`)
  μITRON アーキテクチャに共通するカーネル API 呼び出しやタスク、セマフォなどのカーネルオブジェクトを Rust から扱うためのコードを生成します。

* **RustASP3Plugin 系** (`RustASP3Plugin.rb`, `RustASP3CellPlugin.rb`, `RustASP3CelltypePlugin.rb`)
  シングルコア向け RTOS「TOPPERS/ASP3 カーネル」に特化した Rust 環境の構築、カーネルコンフィギュレーション (`tecsgen.cfg` への変換) 等を担います。TOPPERS/ASP3 カーネルをまとめてビルドする Makefile やサンプルは、[ASP3+TECS](https://github.com/Nagi70/ASP3-TECS-Rust) を参照してください。

* **RustFMP3Plugin 系** (`RustFMP3Plugin.rb`, `RustFMP3CellPlugin.rb`, `RustFMP3CelltypePlugin.rb`)
  マルチコア向け RTOS「TOPPERS/FMP3 カーネル」において Rust でコンポーネントを開発するための拡張を提供します。TOPPERS/FMP3 カーネルをまとめてビルドする Makefile やサンプルは、[FMP3+TECS](https://github.com/azu-lab/FMP3-TECS-Rust) を参照してください。

## 利用条件

TECS/Rust は、親プロジェクトである TECS ジェネレータと同様に、TOPPERS ライセンスの適用を受けます。各ファイルの先頭に記載されているライセンス表記をご確認の上、ご利用ください。

## TECS リファレンスマニュアル

組込みコンポーネントシステム TECS のリファレンスマニュアルは、以下を参照してください。

* [TECS リファレンスマニュアル](http://tecs-docs.readthedocs.io/ja/latest/)

## 準備

TECS/Rust を使用するためには、通常の `tecsgen` の実行環境 (Ruby) に加えて、以下の Rust 開発環境が必要です。

* Rust ツールチェーン (`rustup`, `cargo`, `rustc` 等)
* ターゲットアーキテクチャ向けの標準ライブラリ（例: `thumbv7em-none-eabihf` など、対象ボードによる）
* Nightly コンパイラ（特定の機能を利用する場合）

## 使用方法

CDL ファイル内にプラグインの `generate` 宣言を記述することで、指定したセルタイプに対して Rust 向けのコードが生成されます。ジェネレータを実行すると、各種インタフェースに対応した Rust トレイトや、開発者が中身を記述するためのスケルトンコードが出力されます。

**例 (ASP3 環境向け)**:

```cdl
generate( RustASP3Plugin, "lib" );
celltype hoge {
    ...
};
```

**例 (FMP3 環境向け)**:

```cdl
generate( RustFMP3Plugin, "lib" );
celltype hoge {
    ...
};
```

プラグインのオプションに `size_first` を指定することで、デフォルトの速度優先からサイズ優先のコード生成へと変更できます。

```cdl
generate( RustFMP3Plugin, "lib, size_first" );
```

その他の TECS ジェネレータ自体の基本的な使用方法については、同梱の [README-tecsgen.txt](README-tecsgen.txt) を参照してください。
