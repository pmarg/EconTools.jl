push!(LOAD_PATH,"../src/")

using Documenter, EconTools

makedocs(modules = [EconTools])

deploydocs(
    deps   = Deps.pip("mkdocs", "python-markdown-math"),
    repo = "github.com/pmarg/EconTools.jl.git",
    julia  = "0.6"
)
