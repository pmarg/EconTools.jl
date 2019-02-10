module EconTools

using Statistics, Distributions, StatsFuns, Interpolations



include("QuantTools.jl")
include("Utilities.jl")
include("Grids.jl")

export expspace, tauchen, indices, simulate_markov_shocks, stata_coordinates, interpolate_params
end # module
