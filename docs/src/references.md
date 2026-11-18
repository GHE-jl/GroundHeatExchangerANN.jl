# References

The networks implemented in this package are drawn from the following sources.

- **Pasquier, P., Zarrella, A., & Labib, R.** (2018). Application of artificial neural networks to
  near-instant construction of short-term g-functions. *Applied Thermal Engineering*, 143, 910–921.
  <https://doi.org/10.1016/j.applthermaleng.2018.07.137>
  The [`PublishedANN`](@ref) network (85 nodes, 7-day horizon).

- **Pasquier, P., & Marcotte, D.** (2020). Robust identification of volumetric heat capacity and
  analysis of thermal response tests by Bayesian inference with correlated residuals. *Applied
  Energy*, 261, 114394. <https://doi.org/10.1016/j.apenergy.2019.114394>
  The [`DeepANN`](@ref) network (95 nodes, 21-day horizon, wider validity ranges).
