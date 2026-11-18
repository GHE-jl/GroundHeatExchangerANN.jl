# GroundHeatExchangerANN.jl

*Short-term transfer functions of ground heat exchangers from artificial neural networks, in pure
Julia.*

`GroundHeatExchangerANN.jl` evaluates trained artificial neural networks (ANNs) that emulate the
short-term response of a single U-tube borehole computed by the thermal resistance and capacity
model. Each network directly yields the dimensionless transfer function of the borehole
**outlet** fluid temperature (``T_{out}``, i.e. the entering water temperature on the heat-pump
source side) for a unit temperature step (``\Delta T = 1`` °C) between the borehole inlet and
outlet. It therefore embeds the borehole geometry, its thermal capacity and the vertical fluid
advection, which the long-term (Eskilson-type) ground models neglect.

The package is part of the GHE.jl ecosystem. Its networks are re-exported by
[`GroundHeatExchanger.jl`](https://github.com/GHE-jl/GroundHeatExchanger.jl), whose
`outlet_transfer_function` joins them to a long-term ground model for the full minutes-to-decades
response. It depends only on
[`PCHIPInterpolation.jl`](https://github.com/gerlero/PCHIPInterpolation.jl).

## Installation

```julia
using Pkg
Pkg.add("GroundHeatExchangerANN")
```

## Two trained networks

The network is selected by a model tag, a subtype of [`AbstractANN`](@ref):

| Model | Reference | Free inputs | Time nodes | Horizon |
|---|---|---|---|---|
| [`PublishedANN`](@ref) | Pasquier, Zarrella & Labib (2018) | 8 (pipe properties fixed) | 85 | 7 days |
| [`DeepANN`](@ref) | Pasquier & Marcotte (2020) | pipe properties (`kp`, `Cf`, `ri`, `ro`) also free, wider ranges | 95 | 21 days |

`DeepANN` is the default model of `outlet_transfer_function` in `GroundHeatExchanger.jl`; the
original 2018 network remains available as an explicit, citable `PublishedANN` choice. The
underlying deep network can in principle report the temperature at any probe location along the
U-tube; only the borehole outlet is exposed here, matching the signature of the published network.
The validity ranges of each network (its training bounds) are listed in the docstrings of
[`ann`](@ref) and [`ann_nodes`](@ref).

## Native nodes and interpolation

Each network returns the transfer function on its own fixed, geometric time nodes, the last node
marking its validity horizon:

- [`ann_nodes`](@ref) evaluates the network on its native nodes and returns `(ts, g)`, with no
  interpolation and no time validation. It is the building block that `outlet_transfer_function`
  consumes directly (it joins the long-term model at `ts[end]`).
- [`ann`](@ref) interpolates these nodes onto any requested `t` by shape-preserving (PCHIP)
  interpolation, and validates `t` against the horizon (15 s to 7 or 21 days; only the last value
  is bounded).

```julia
using GroundHeatExchangerANN

rb, ri, ro, H, s, V̇ = 0.08, 0.017, 0.022, 150.0, 0.05, 30 / 6e4   # geometry [m], flow [m³/s]
ks, Cs, kg, Cg      = 3.0, 2.11e6, 1.6, 2.0e6                    # ground and grout
kp, Cp, Cf          = 0.4, 1.9e6, 4.2e6                          # pipe and fluid

t = exp10.(range(log10(60.0), log10(7 * 86400.0); length = 100))
t, g = ann(DeepANN(), t, rb, ri, ro, H, s, V̇, ks, Cs, kg, Cg, kp, Cp, Cf)

ts, gn = ann_nodes(PublishedANN(), ks, Cs, kg, Cg, kp, Cp, Cf, ri, ro, rb, H, V̇, s)
```

Note the two argument orders: `ann` takes the time and the geometry first, `ann_nodes` the ground,
grout, pipe and fluid properties first.

## Out-of-range inputs

Every input is checked against the training ranges of the network. With `clamp = true` (the
default), an out-of-range value is clamped to the nearest bound with a `@warn`; with
`clamp = false`, an `@error` is emitted and an `ArgumentError` is thrown. The same policy applies to
the last requested time of `ann`.

## Conventions

| Symbol | Meaning | Unit |
|---|---|---|
| `rb` | Borehole radius | m |
| `ri`, `ro` | Inner / outer pipe radius | m |
| `H` | Borehole length | m |
| `s` | Shank spacing (distance between the two legs of the U-tube) | m |
| `V̇` | Fluid flow rate | m³/s |
| `ks`, `kg`, `kp` | Ground / grout / pipe thermal conductivity | W/m·K |
| `Cs`, `Cg`, `Cp`, `Cf` | Ground / grout / pipe / fluid volumetric heat capacity | J/m³·K |
| `g` | Outlet transfer function (add 1 for the inlet) | – |

## Manual outline

- **[API reference](@ref)** — the docstrings of every exported symbol, with the validity ranges.
- **[References](@ref)** — the papers of the two networks.
