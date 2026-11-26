module GroundHeatExchangerANN

# Artificial neural networks (abstraction, then one file per trained network)
include("ann_model.jl")
include("ann_published.jl")
include("ann_deep.jl")

using PCHIPInterpolation: Interpolator

"""
    _pchip(tᵢ, vᵢ, t)

Shape-preserving (PCHIP) interpolation of `vᵢ`, sampled at `tᵢ`, onto `t` (scalar or vector).
"""
_pchip(tᵢ, vᵢ, t) = Interpolator(tᵢ, vᵢ).(t)

# Model tags
export AbstractANN, PublishedANN, DeepANN

# Short-term outlet g-function: interpolated at any time, or on the native nodes
export ann, ann_nodes

end
