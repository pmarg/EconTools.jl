module EconTools

using Statistics, Distributions, StatsFuns



include("QuantTools.jl")
include("Utilities.jl")
include("Grids.jl")

export expspace, tauchen, indices, simulate_markov_shocks
end # module
