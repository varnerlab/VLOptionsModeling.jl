using Documenter
using VLOptionsModeling

makedocs(
    sitename = "Model",
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true"
    ),
    modules = [VLOptionsModeling],
    pages = [
        "Home" => "index.md",
    ],
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/varnerlab/VLOptionsModeling.jl.git",
    devurl = "stable",
    devbranch = "main",
)
