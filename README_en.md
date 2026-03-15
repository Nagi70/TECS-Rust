# TECS/Rust (Rust Support for TECS Generator)

TECS/Rust is a generator extension (set of plugins) for the TOPPERS Embedded Component System (TECS) that enables the use of Rust, a highly safe language, as the implementation language for components.
In addition to traditional component implementations in C, it supports the development of highly reliable embedded systems using Rust.
This project is an experimental release and supports only a portion of TECS features.

## Provided Features (Plugins)

This repository implements and provides Rust code generation plugins for the following environments and kernels.

* **RustGenPlugin Series** (`RustGenPlugin.rb`, `RustGenCellPlugin.rb`, `RustGenCelltypePlugin.rb`)
  Provides core functionality for general Rust code generation (such as type definition conversion, constant optimization, and generation of cell structures utilizing generics).

* **RustITRONPlugin Series** (`RustITRONPlugin.rb`, `RustITRONCellPlugin.rb`, `RustITRONCelltypePlugin.rb`)
  Generates code to handle kernel API calls common to the μITRON architecture and kernel objects (e.g., tasks, semaphores) from Rust.

* **RustASP3Plugin Series** (`RustASP3Plugin.rb`, `RustASP3CellPlugin.rb`, `RustASP3CelltypePlugin.rb`)
  Responsible for constructing a Rust environment specialized for the single-core RTOS "TOPPERS/ASP3 Kernel" and converting the kernel configuration (`tecsgen.cfg`). For Makefiles and samples to build the TOPPERS/ASP3 Kernel together, refer to [ASP3+TECS](https://github.com/Nagi70/ASP3-TECS-Rust).

* **RustFMP3Plugin Series** (`RustFMP3Plugin.rb`, `RustFMP3CellPlugin.rb`, `RustFMP3CelltypePlugin.rb`)
  Provides an extension to develop components in Rust for the multi-core RTOS "TOPPERS/FMP3 Kernel". For Makefiles and samples to build the TOPPERS/FMP3 Kernel together, refer to [FMP3+TECS](https://github.com/azu-lab/FMP3-TECS-Rust).

## Usage Conditions

Like its parent project, the TECS Generator, TECS/Rust is subject to the TOPPERS License. Please check the license notation at the top of each file before use.

## TECS Reference Manual

For the reference manual of the embedded component system TECS, please see the following:

* [TECS Reference Manual](http://tecs-docs.readthedocs.io/ja/latest/) (Japanese)

## Prerequisites

To use TECS/Rust, in addition to the standard `tecsgen` execution environment (Ruby), the following Rust development environment is required:

* Rust toolchain (`rustup`, `cargo`, `rustc`, etc.)
* Standard library for the target architecture (e.g., `thumbv7em-none-eabihf`, depending on the target board)
* Nightly compiler (if using specific features)

## Usage

By writing a `generate` declaration for a plugin in the CDL file, Rust code for the specified cell type will be generated. When you run the generator, it outputs Rust traits corresponding to various interfaces and skeleton code for developers to write the implementation.

**Example (For ASP3 Environment)**:

```cdl
generate( RustASP3Plugin, "lib" );
celltype hoge {
    ...
};
```

**Example (For FMP3 Environment)**:

```cdl
generate( RustFMP3Plugin, "lib" );
celltype hoge {
    ...
};
```

By specifying `size_first` in the plugin options, you can change the default speed-first code generation to size-first generation.

```cdl
generate( RustFMP3Plugin, "lib, size_first" );
```

For basic usage of the TECS generator itself, please refer to the included [README-tecsgen-eng.txt](README-tecsgen-eng.txt).
