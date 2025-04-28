# GetDP.jl

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://electa-git.github.io/GetDP.jl/dev/)
[![Build Status](https://github.com/Electa-Git/GetDP.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Electa-Git/GetDP.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![codecov](https://codecov.io/gh/Electa-Git/GetDP.jl/graph/badge.svg?token=YA4PV3EXOX)](https://codecov.io/gh/Electa-Git/GetDP.jl)

This package provides a Julia interface to [GetDP](http://getdp.info/), for finite element analysis.

## Installation

Clone the package and add to the Julia environment:

```julia
] add https://github.com/Electa-Git/GetDP.jl.git
```

```julia
using GetDP
```

## Usage

`GetDP.jl` provides several wrappers to the main GetDP objects and operators. Currently the following objects are implemented:

- `Group`: Defining topological entities.
- `Function`: Defining functions.
- `Constraint`: Defining constraints.
- `FunctionSpace`: Defining function spaces.
- `Jacobian`: Defining jacobians.
- `Integration`: Defining integration methods.
- `Formulation`: Building equations.
- `Resolution`: Defining how to solve the problem.
- `PostProcessing`: Defining post-processing.
- `PostOperation`: Defining post-operations.
- `Problem`: The main problem definition class that brings together all the components.

The [examples](examples) directory contains files illustrating basic usage.

## License

The source code is provided under the [BSD 3-Clause License](LICENSE).

## Acknowledgements

This work is supported by the Etch Competence Hub of EnergyVille, financed by the Flemish Government. The primary developer is Amauri Martins ([@amaurigmartins](https://github.com/amaurigmartins)). This package is inspired by the [pygetdp](https://gitlab.com/benvial/pygetdp) project.

<p align = "left">
  <p><br><img src="assets/img/ETCH_LOGO_RGB_NEG.svg" width="150" alt="Etch logo"></p>
  <p><img src="assets/img/ENERGYVILLE-LOGO.svg" width="150" alt="EV logo"></p>
  <p><img src="assets/img/kul_logo.svg" width="150" alt="KUL logo"></p>
</p>