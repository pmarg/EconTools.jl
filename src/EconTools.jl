module EconTools

using Statistics, Distributions, StatsFuns, Interpolations,  Statistics, StatsBase
using PGFPlotsX,  DataFrames, TimerOutputs, Printf, Mmap, CodecZlib, CSV
import TimerOutputs:prettytime
## Model Parameters
import Base.getproperty
import Base.show
include(joinpath("MP","Types.jl"))
include(joinpath("MP","Set.jl"))
include(joinpath("MP","Show.jl"))



include("logging.jl")
include("QuantTools.jl")
include("Utilities.jl")
include("Grids.jl")
include("DataSetTools.jl")
include("Plotting.jl")


export expspace, tauchen, indices, simulate_markov_shocks, interpolate_params
export reshape_results!, print_struct, print_parameters, percentiles!, at_percentiles!
export to, prettytime, @timeit, print_timer
export show, pivot_longer,tab
export writeGzip, readGzip
export pgfplot
# Model Parameters
export AbstractParameter,
       AbstractParameterSet,
       ParameterGroup,
       ParameterSpace,
       Parameter,
       BoundedParameter,
       getproperty,
       description,
       bounds,
       set,
       ←,
       show
end

end # module
