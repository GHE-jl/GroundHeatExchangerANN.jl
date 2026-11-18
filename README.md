# GroundHeatExchangerANN.jl

[![CI](https://github.com/GHE-jl/GroundHeatExchangerANN.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/GHE-jl/GroundHeatExchangerANN.jl/actions/workflows/CI.yml)
[![Docs: dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://GHE-jl.github.io/GroundHeatExchangerANN.jl/dev)
[![Docs: stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://GHE-jl.github.io/GroundHeatExchangerANN.jl/stable)
[![License: AGPL v3](https://img.shields.io/badge/License-AGPLv3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)

Julia package for the short-term transfer function of the borehole-outlet fluid temperature of a
single U-tube ground heat exchanger, from trained artificial neural networks (ANNs). The networks
emulate the thermal resistance and capacity model and yield the dimensionless outlet transfer
function for a 1 °C step between the borehole inlet and outlet, including the borehole geometry,
thermal capacity and vertical fluid advection.

The package is part of the GHE.jl ecosystem: its networks are re-exported by
[GroundHeatExchanger.jl](https://github.com/GHE-jl/GroundHeatExchanger.jl), whose
`outlet_transfer_function` joins them to a long-term ground model from minutes to decades.

## Quick start

```julia
using GroundHeatExchangerANN

rb, ri, ro, H, s, V̇ = 0.08, 0.017, 0.022, 150.0, 0.05, 30 / 6e4   # geometry [m], flow [m³/s]
ks, Cs, kg, Cg      = 3.0, 2.11e6, 1.6, 2.0e6                    # ground and grout
kp, Cp, Cf          = 0.4, 1.9e6, 4.2e6                          # pipe and fluid

# Interpolated onto any t (PCHIP), within the horizon of the network
t = exp10.(range(log10(60.0), log10(7 * 86400.0); length = 100))
t, g = ann(DeepANN(), t, rb, ri, ro, H, s, V̇, ks, Cs, kg, Cg, kp, Cp, Cf)

# Raw values on the native time nodes of the network
ts, gn = ann_nodes(PublishedANN(), ks, Cs, kg, Cg, kp, Cp, Cf, ri, ro, rb, H, V̇, s)
```

## Models

| Model tag | Reference | Time nodes | Horizon |
|---|---|---|---|
| `PublishedANN()` | Pasquier, Zarrella & Labib (2018) — pipe properties fixed | 85 | 7 days |
| `DeepANN()` | Pasquier & Marcotte (2020) — pipe properties free, wider validity ranges | 95 | 21 days |

Both are subtypes of `AbstractANN`. `DeepANN` is the default of `outlet_transfer_function` in
GroundHeatExchanger.jl.

## Functions

| Function | Description |
|---|---|
| `ann(model, t, rb, ri, ro, H, s, V̇, ks, Cs, kg, Cg, kp, Cp, Cf; clamp = true)` | Outlet transfer function at `t`, returns `(t, g)` |
| `ann_nodes(model, ks, Cs, kg, Cg, kp, Cp, Cf, ri, ro, rb, H, V̇, s; clamp = true)` | Outlet transfer function on the native nodes, returns `(ts, g)` |

Inputs outside the training ranges of the network (listed in the docstrings) are clamped to the
nearest bound with a warning (`clamp = true`, default) or rejected with an `ArgumentError`
(`clamp = false`).

## Installation

```julia
using Pkg
Pkg.add("GroundHeatExchangerANN")
```

## Dependencies

| Package | Used for |
|---------|----------|
| [PCHIPInterpolation.jl](https://github.com/gerlero/PCHIPInterpolation.jl) | Interpolation of the native nodes onto any `t` |

## References

- Pasquier, P., Zarrella, A., & Labib, R. (2018). Application of artificial neural networks to
  near-instant construction of short-term g-functions (`PublishedANN`). Applied Thermal
  Engineering, 143, 910–921.
- Pasquier, P., & Marcotte, D. (2020). Robust identification of volumetric heat capacity and
  analysis of thermal response tests by Bayesian inference with correlated residuals (`DeepANN`).
  Applied Energy, 261, 114394.
