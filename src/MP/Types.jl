abstract type AbstractParameter end
abstract type AbstractParameterSet end
abstract type ParameterSpace<:AbstractParameterSet end
abstract type ParameterGroup<:AbstractParameterSet end

struct Parameter{T,S<:String} <: AbstractParameter
    value::T
    description::S
end
struct BoundedParameter{T,S<:String} <: AbstractParameter
    value::T
    description::S
    lb::T
    ub::T
end

function Base.getproperty(name::ParameterGroup,val::Symbol)
    if typeof(getfield(name,val))<:AbstractParameter
        return getfield(getfield(name,val),:value)
    else
        return getfield(name,val)
    end
end

function description(name::ParameterGroup,val::Symbol)
    if typeof(getfield(name,val))<:AbstractParameter
        return getfield(getfield(name,val),:description)
    else
        @warn "No description provided"
        return nothing
    end
end

function bounds(name::ParameterGroup,val::Symbol)
    if typeof(getfield(name,val))<:BoundedParameter
        return getfield(getfield(name,val),:lb), getfield(getfield(name,val),:ub)
    else
        @warn "No bounds defined"
        return nothing
    end
end
