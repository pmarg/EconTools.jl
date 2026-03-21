using EconTools
using Test
using DataFrames
using StableRNGs
using Statistics
using LinearAlgebra

# Import necessary plotting types
using PGFPlotsX

@testset "EconTools.jl" begin
    include("test_grids.jl")
    include("test_dataset_tools.jl")
    include("test_statistics_dispatch.jl")
    include("test_plotting.jl")
    include("test_latex_output.jl")
end
