"""
    AbstractParameter

Abstract supertype for a single model parameter. Subtypes: [`Parameter`](@ref) and
[`BoundedParameter`](@ref).
"""
abstract type AbstractParameter end
"""
    AbstractParameterSet

Abstract supertype for collections of parameters. Subtypes: [`ParameterGroup`](@ref)
and [`ParameterSpace`](@ref).
"""
abstract type AbstractParameterSet end
"""
    ParameterGroup <: AbstractParameterSet

Abstract supertype for a struct whose fields are parameters (`Parameter`,
`BoundedParameter` or plain values). Subtypes get field access that returns the value
(`g.x` instead of `g.x.value`, see `getproperty`), [`description`](@ref),
[`get_bounds`](@ref) and a table display (`show`).
"""
abstract type ParameterGroup <: AbstractParameterSet end
"""
    ParameterSpace <: AbstractParameterSet

Abstract supertype for a struct whose fields are `ParameterGroup`s, i.e. all the
parameters of a model. Its `show` method prints every group.
"""
abstract type ParameterSpace <: AbstractParameterSet end
"""
    Parameter(value, description)

A parameter value with a text description.

# Fields
- `value::T`: the value (any type).
- `description::String`: what the parameter is, shown when the group is printed.

# Examples
```julia
β = Parameter(0.96, "Discount factor")
```
"""
struct Parameter{T,S<:String} <: AbstractParameter
    value::T
    description::S
end
"""
    BoundedParameter(value, lb, ub, description)

A parameter value with lower and upper bounds (e.g. for estimation) and a text
description.

# Fields
- `value::T`: the value.
- `lb::T`, `ub::T`: lower and upper bounds, same type as `value`.
- `description::String`: what the parameter is, shown when the group is printed.

# Examples
```julia
σ = BoundedParameter(2.0, 0.5, 5.0, "Risk aversion")
```
"""
struct BoundedParameter{T,S<:String} <: AbstractParameter
    value::T
    lb::T
    ub::T
    description::S
end
"""
    getproperty(g::ParameterGroup, name::Symbol)

Field access for parameter groups: `g.x` returns the value of an `AbstractParameter`
field (`g.x.value`), and the field itself for any other field. Use `getfield(g, :x)`
to get the `Parameter` wrapper, or [`description`](@ref) for its description.
"""
function Base.getproperty(name::ParameterGroup, val::Symbol)
    if typeof(getfield(name, val)) <: AbstractParameter
        return getfield(getfield(name, val), :value)
    else
        return getfield(name, val)
    end
end
"""
    description(g::ParameterGroup, name::Symbol) -> Union{String,Nothing}

Description of parameter `name` in group `g`. Needed because `g.name` returns the
value, not the wrapper that holds the description.

# Returns
- The description, or `nothing` (with a warning) if the field is not an
  `AbstractParameter`.
"""
function description(name::ParameterGroup, val::Symbol)
    if typeof(getfield(name, val)) <: AbstractParameter
        return getfield(getfield(name, val), :description)
    else
        @warn "No description provided"
        return nothing
    end
end