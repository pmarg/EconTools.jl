using Documenter, PACKAGE_NAME

makedocs()
deploydocs(
    deps   = Deps.pip("mkdocs", "python-markdown-math"),
    repo = "github.com/pmarg/EconTools.jl.git",
    julia  = "0.6"
)
