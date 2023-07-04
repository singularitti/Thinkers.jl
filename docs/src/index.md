```@meta
CurrentModule = Thinkers
```

# Thinkers

Documentation for [Thinkers](https://github.com/singularitti/Thinkers.jl).

This repository is inspired by [Thunks.jl](https://github.com/tbenst/Thunks.jl), but with
some modifications to its design.

See the [Index](@ref main-index) for the complete list of documented functions
and types.

The code is [hosted on GitHub](https://github.com/singularitti/Thinkers.jl),
with some continuous integration services to test its validity.

This repository is created and maintained by [@singularitti](https://github.com/singularitti).
You are very welcome to contribute.

## Installation

The package can be installed with the Julia package manager.
From the Julia REPL, type `]` to enter the Pkg REPL mode and run:

```julia
pkg> add Thinkers
```

Or, equivalently, via the `Pkg` API:

```@repl
import Pkg; Pkg.add("Thinkers")
```

## Documentation

- [**STABLE**](https://singularitti.github.io/Thinkers.jl/stable) — **documentation of the most recently tagged version.**
- [**DEV**](https://singularitti.github.io/Thinkers.jl/dev) — _documentation of the in-development version._

## Project status

The package is tested against, and being developed for, Julia `1.6` and above on Linux,
macOS, and Windows.

## Questions and contributions

Usage questions can be posted on
[our discussion page](https://github.com/singularitti/Thinkers.jl/discussions).

Contributions are very welcome, as are feature requests and suggestions. Please open an
[issue](https://github.com/singularitti/Thinkers.jl/issues)
if you encounter any problems. The [Contributing](@ref) page has
a few guidelines that should be followed when opening pull requests and contributing code.

## Manual outline

```@contents
Pages = [
    "installation.md",
    "api.md",
    "developers/contributing.md",
    "developers/style-guide.md",
    "developers/design-principles.md",
    "troubleshooting.md",
]
Depth = 3
```

## Library outline

```@contents
Pages = ["api.md"]
```

### [Index](@id main-index)

```@index
Pages = ["api.md"]
```
