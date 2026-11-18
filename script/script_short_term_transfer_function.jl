# Short-term outlet transfer function of a single U-tube borehole from the two trained ANNs.
#   Figure, left  : PublishedANN vs DeepANN on the same borehole — native nodes (`ann_nodes`) and
#                   PCHIP interpolation onto a user time vector (`ann`)
#   Figure, right : DeepANN sensitivity to the ground thermal conductivity ks
#
# To join this short-term response to a long-term ground model (minutes to decades), see
# `outlet_transfer_function` and `script_outlet_transfer_function.jl` in GroundHeatExchanger.jl.
#
# References
#   - Pasquier, P., Zarrella, A., & Labib, R. (2018). Application of artificial neural networks to
#       near-instant construction of short-term g-functions. Applied Thermal Engineering, 143,
#       910-921.
#   - Pasquier, P., & Marcotte, D. (2020). Robust identification of volumetric heat capacity and
#       analysis of thermal response tests by Bayesian inference with correlated residuals. Applied
#       Energy, 261, 114394.

import Pkg; Pkg.activate(@__DIR__)
# Pkg.instantiate() # Once per project, to install dependencies

using CairoMakie
using GroundHeatExchangerANN

# Parameters (within the training ranges of both networks)
rb = 0.08         # Borehole radius [m]
ri = 0.017        # Inner pipe radius [m]
ro = 0.022        # Outer pipe radius [m]
H  = 150.0        # Borehole length [m]
s  = 0.05         # Shank spacing [m]
V̇  = 30 / 6e4     # Flow rate, 30 L/min [m³/s]
ks = 3.0          # Ground thermal conductivity [W/mK]
Cs = 2.11e6       # Ground volumetric heat capacity [J/m³K]
kg = 1.6          # Grout thermal conductivity [W/mK]
Cg = 2.0e6        # Grout volumetric heat capacity [J/m³K]
kp = 0.4          # Pipe thermal conductivity [W/mK]
Cp = 1.9e6        # Pipe volumetric heat capacity [J/m³K]
Cf = 4.2e6        # Fluid volumetric heat capacity [J/m³K]

day = 86400.0

# Log-spaced time vectors: 1 min → horizon of each network (7 and 21 days). `min.` guards the
# last value against round-off past the horizon (which would trigger a clamp warning).
t_pub  = min.(exp10.(range(log10(60.0), log10(7 * day); length = 200)), 7 * day)
t_deep = min.(exp10.(range(log10(60.0), log10(21 * day); length = 200)), 21 * day)

# Interpolated onto any t (PCHIP)
_, g_pub  = ann(PublishedANN(), t_pub,  rb, ri, ro, H, s, V̇, ks, Cs, kg, Cg, kp, Cp, Cf)
_, g_deep = ann(DeepANN(),      t_deep, rb, ri, ro, H, s, V̇, ks, Cs, kg, Cg, kp, Cp, Cf)

# Raw values on the native time nodes (85 and 95 nodes) — note the different argument order
ts_pub,  gn_pub  = ann_nodes(PublishedANN(), ks, Cs, kg, Cg, kp, Cp, Cf, ri, ro, rb, H, V̇, s)
ts_deep, gn_deep = ann_nodes(DeepANN(),      ks, Cs, kg, Cg, kp, Cp, Cf, ri, ro, rb, H, V̇, s)

# DeepANN sensitivity to the ground thermal conductivity
ks_values = [1.0, 2.0, 3.0, 4.0, 6.0]
g_ks = [ann(DeepANN(), t_deep, rb, ri, ro, H, s, V̇, k, Cs, kg, Cg, kp, Cp, Cf)[2]
        for k in ks_values]

# Figure
th = t -> t ./ 3600   # time in hours
colors = Makie.wong_colors()

fig = Figure(size = (1100, 450))

ax1 = Axis(fig[1, 1];
    title  = "PublishedANN vs DeepANN",
    xlabel = "t (h)", ylabel = "g  (-)", xscale = log10)
lines!(ax1, th(t_deep), g_deep; color = colors[2], linewidth = 3, label = "DeepANN — ann")
scatter!(ax1, th(ts_deep), gn_deep; color = colors[2], markersize = 8, marker = :rect,
    label = "DeepANN — ann_nodes")
lines!(ax1, th(t_pub), g_pub; color = colors[1], linewidth = 1.5, linestyle = :dash,
    label = "PublishedANN — ann")
scatter!(ax1, th(ts_pub), gn_pub; color = colors[1], markersize = 5,
    label = "PublishedANN — ann_nodes")
xlims!(ax1, th(60.0), th(21 * day))
axislegend(ax1; position = :lt)

ax2 = Axis(fig[1, 2];
    title  = "DeepANN — ground thermal conductivity",
    xlabel = "t (h)", ylabel = "g  (-)", xscale = log10)
for (i, (k, g)) in enumerate(zip(ks_values, g_ks))
    lines!(ax2, th(t_deep), g; color = colors[i], linewidth = 2, label = "ks = $k W/mK")
end
axislegend(ax2; position = :lt)

display(fig)
