"""
    EconTools

A collection of reusable utilities for applied economics research, including:
- **Grid generation & numerical methods**: expspace, tauchen, bilerp_flat
- **Data manipulation**: pivot_longer, reshape_results!, tab, assign_quantile_groups
- **LaTeX output**: save_latex_table, save_pgfplot for publication-ready tables & figures
- **Parameter management**: Self-documenting parameter types with descriptions
- **R integration**: ensure_r_packages for RCall workflows
- **Performance profiling**: TimerOutputs integration

# Dependencies
- Core: DataFrames, Statistics, StatsBase, CategoricalArrays
- Numerical: Distributions, StatsFuns, Interpolations
- Plotting: PGFPlotsX
- I/O: CSV, CodecZlib, Mmap
- Other: Printf, TimerOutputs, ModelParameters, Parameters, StableRNGs
- Optional: GLM (for residualize_pgs), RCall (for ensure_r_packages)
"""
module EconTools

## Core dependencies
using Statistics, Distributions, StatsFuns, StatsBase, StableRNGs
using PGFPlotsX, DataFrames, Printf, CategoricalArrays

## Optional dependencies (needed for specific functions)
## GLM: Required for residualize_pgs()
## RCall: Required for ensure_r_packages()

## Model Parameters
import Base.getproperty
import Base.show
include(joinpath("parameters","types.jl"))
include(joinpath("parameters","set.jl"))
include(joinpath("parameters","show.jl"))
include(joinpath("parameters", "get_bounds.jl"))



## Core utilities
include("grids/grids.jl")
include("dataset/dataset_tools.jl")
include("simulations/simulations.jl")

## LaTeX output for papers
include(joinpath("paper", "tables", "tables.jl"))
include(joinpath("paper", "figures", "figures.jl"))
include(joinpath("paper", "figures", "pgfplots_setup.jl"))


## ============================================================================
## EXPORTS
## ============================================================================

## Grid generation and numerical methods
export expspace, tauchen
export bilerp_flat
export simulate_markov_shocks

## Data manipulation and transformation
export pivot_longer, reshape_results!
export assign_groups!, create_age_groups


## Plotting
export pgfplot, initialize_pgfplots

## Post-estimation analysis
## Note: Statistics functions (mean, var, median, quantile, std) are extended via multiple dispatch

## LaTeX output for papers
export save_latex_table, save_latex_table_simple, format_number
export save_pgfplot, save_pgfplot_simple, create_line_plot

## Model Parameters system
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

end # module EconTools
