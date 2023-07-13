using EconTools
@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end

include("test_PlottingTools.jl")
include("test_DataSetTools.jl")
