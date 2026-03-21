"""
Abstract supertype for parameters. Currently, the subtypes are `Parameters` and `BoundedParameter`.
"""
abstract type AbstractParameter end
"""
Abstract supertype for different definitions of parameter sets. Currently the subtypes are `ParameterGroup` and `ParameterSpace`. 
"""
abstract type AbstractParameterSet end
"""
Abstract supertype for structs that contain multiple `Parameters` and/or `BoundedParameters`. Useful for printing a single struct that holds parameters.
"""
abstract type ParameterGroup <: AbstractParameterSet end
"""
Abstract supertype that contains all the parameters in the model. Useful for printing the parameter space.
"""
abstract type ParameterSpace <: AbstractParameterSet end
"""
A simple wrapper that contains the value of the parameter and a description.
"""
struct Parameter{T,S<:String} <: AbstractParameter
    value::T
    description::S
end
"""
A simple wrapper that contains the value of the parameter, the lower and upper bounds, and a description.
"""
struct BoundedParameter{T,S<:String} <: AbstractParameter
    value::T
    lb::T
    ub::T
    description::S
end
"""
    Base.getproperty(name::ParameterGroup, val::Symbol)

Extension of `getproperty` function in order to call the value of an `AbstractParameter` within a `ParameterGroup` as T.x instead of T.x.value
"""
function Base.getproperty(name::ParameterGroup, val::Symbol)
    if typeof(getfield(name, val)) <: AbstractParameter
        return getfield(getfield(name, val), :value)
    else
        return getfield(name, val)
    end
end
"""
A function that returns the description of an `AbstractParameter` within a `ParameterGroup`. This is necessary because of the definition of getproperty for `ParameterGroup` that returns the value of the parameter instead of `AbstractParameter`. For example, T.x returns x.value and not x, which contains the description in the wrapper.
"""
function description(name::ParameterGroup, val::Symbol)
    if typeof(getfield(name, val)) <: AbstractParameter
        return getfield(getfield(name, val), :description)
    else
        @warn "No description provided"
        return nothing
    end
end