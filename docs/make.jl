using GroundHeatExchangerANN
using Documenter

# Make `using GroundHeatExchangerANN` available to every doctest in docstrings and pages.
DocMeta.setdocmeta!(
    GroundHeatExchangerANN,
    :DocTestSetup,
    :(using GroundHeatExchangerANN);
    recursive = true,
)

makedocs(;
    modules = [GroundHeatExchangerANN],
    authors = "Gabriel-Dion <dion.gabriel100@gmail.com>",
    sitename = "GroundHeatExchangerANN.jl",
    format = Documenter.HTML(;
        canonical = "https://GHE-jl.github.io/GroundHeatExchangerANN.jl",
        edit_link = "main",
        assets = String[],
        mathengine = Documenter.KaTeX(),
        sidebar_sitename = false,
    ),
    pages = [
        "Home" => "index.md",
        "API reference" => "api.md",
        "References" => "references.md",
    ],
    checkdocs = :exports,
)

deploydocs(;
    repo = "github.com/GHE-jl/GroundHeatExchangerANN.jl",
    devbranch = "main",
)
