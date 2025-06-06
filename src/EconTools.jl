module EconTools

using Statistics, Distributions, StatsFuns, Interpolations,  Statistics, StatsBase, ModelParameters, Parameters, StableRNGs
using PGFPlotsX,  DataFrames, TimerOutputs, Printf, Mmap, CodecZlib, CSV,CategoricalArrays

import TimerOutputs:prettytime
## Model Parameters
import Base.getproperty
import Base.show
include(joinpath("MP","Types.jl"))
include(joinpath("MP","Set.jl"))
include(joinpath("MP","Show.jl"))




include("QuantTools.jl")
include("Utilities.jl")
include("Grids.jl")
include("DataSetTools.jl")
include("Plotting.jl")
include("PostEstimations.jl")

export expspace, tauchen, indices, simulate_markov_shocks, interpolate_params
export reshape_results!, print_struct, print_parameters
export to, prettytime, @timeit, print_timer
export show, pivot_longer,tab
export writeGzip, readGzip
export pgfplot, initialize_pgfplots
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
       show,
       set

export df_means, df_var, df_medians, df_quantiles

export create_age_groups, assign_groups!

end # module
