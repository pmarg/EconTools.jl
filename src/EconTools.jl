"""
    EconTools

A collection of reusable utilities for applied economics research, including:
- **Grid generation & numerical methods**: expspace, tauchen, rouwenhorst, bilerp_flat
- **Data manipulation**: pivot_longer, reshape_results!, tab, assign_quantile_groups
- **LaTeX output**: save_latex_table, save_pgfplot for publication-ready tables & figures
- **Parameter management**: Self-documenting parameter types with descriptions
- **R integration**: ensure_r_packages for RCall workflows
- **Performance profiling**: TimerOutputs integration
- **Literate rendering**: literate_render for one-command PDF generation from .jl scripts

# Dependencies
- Core: DataFrames, Statistics, StatsBase, CategoricalArrays
- Numerical: Distributions, StatsFuns, Interpolations
- Plotting: PGFPlotsX
- I/O: CSV, CodecZlib, Mmap
- Rendering: Literate (for literate_render)
- Other: Printf, TimerOutputs, ModelParameters, Parameters, StableRNGs
- Optional: GLM (for residualize_pgs), RCall (for ensure_r_packages)
"""
module EconTools

## Core dependencies
using Statistics, Distributions, StatsFuns, StatsBase, StableRNGs
using PGFPlotsX, DataFrames, Printf, CategoricalArrays
using Literate

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
__init__() = add_pgfplots_preamble()

## Literate rendering
include(joinpath("renderer", "literate_render.jl"))


## ============================================================================
## EXPORTS
## ============================================================================

## Grid generation and numerical methods
export expspace, tauchen, rouwenhorst
export bilerp_flat
export simulate_markov_shocks, simulate_from_pdf, draw_from_cdf

## Data manipulation and transformation
export pivot_longer, reshape_results!
export assign_groups!, create_age_groups


## Plotting
export pgfplot, initialize_pgfplots

## Post-estimation analysis
## DataFrame methods of the Statistics functions (dataset_tools.jl). Re-exported so
## `using EconTools` alone makes them available; same functions as Statistics.mean etc.
export mean, var, median, quantile, std

## LaTeX output for papers
export save_latex_table, save_latex_table_simple, format_number
export save_pgfplot, save_pgfplot_simple, create_line_plot
export line_plot, group_line_plot, save_figure, PALETTE, DATA_COLOR, MODEL_COLOR

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

## Literate rendering
export literate_render, literate_render_batch, literate_render_master

end # module EconTools
