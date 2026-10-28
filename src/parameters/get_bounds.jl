"""
    get_initial_guess(parameters) -> Vector{Float64}

Values of a vector of parameters, e.g. as the starting point of an optimization.

# Arguments
- `parameters`: vector of `Parameter`s or `BoundedParameter`s.
"""
function get_initial_guess(parameters)
    initial_guess = zeros(size(parameters, 1))
    for i ∈ 1:size(parameters, 1)
        initial_guess[i] = parameters[i].value
    end
    return initial_guess
end
"""
    get_lower_bounds(parameters) -> Vector{Float64}

Lower bounds of a vector of `BoundedParameter`s, e.g. for constrained optimization.

See also [`get_upper_bounds`](@ref), [`get_bounds`](@ref).
"""
function get_lower_bounds(parameters)
    lower_bound = zeros(size(parameters, 1))
    for i ∈ 1:size(parameters, 1)
        lower_bound[i] = parameters[i].lb
    end
    return lower_bound
end
"""
    get_upper_bounds(parameters) -> Vector{Float64}

Upper bounds of a vector of `BoundedParameter`s, e.g. for constrained optimization.

See also [`get_lower_bounds`](@ref), [`get_bounds`](@ref).
"""
function get_upper_bounds(parameters)
    upper_bound = zeros(size(parameters, 1))
    for i ∈ 1:size(parameters, 1)
        upper_bound[i] = parameters[i].ub
    end
    return upper_bound
end
"""
    get_bounds(g::ParameterGroup, name::Symbol) -> Union{Tuple,Nothing}
    get_bounds(g) -> (lower::Vector{Float64}, upper::Vector{Float64})

Bounds of parameters in a `ParameterGroup`, e.g. for constrained optimization.

- With a field `name`: `(lb, ub)` of that `BoundedParameter`, or `nothing` (with a
  warning) if it has no bounds.
- Without: the lower and upper bounds of every field, in field order. A field that is
  not a `BoundedParameter` logs an error and gets bounds `0.0`.
"""
function get_bounds(name::ParameterGroup, val::Symbol)
    if typeof(getfield(name, val)) <: BoundedParameter
        x1 = getfield(getfield(name, val), :lb)
        x2 = getfield(getfield(name, val), :ub)
        return x1, x2
    else
        @warn "No bounds defined"
        return nothing
    end
end

function get_bounds(parameters)
    upper_bound = zeros(size(fieldnames(typeof(parameters)), 1))
    lower_bound = zeros(size(upper_bound, 1))
    for (i, name) in enumerate(fieldnames(typeof(parameters)))
        if typeof(getfield(parameters, name)) <: BoundedParameter
            upper_bound[i] = getfield(parameters, name).ub
            lower_bound[i] = getfield(parameters, name).lb
        else
            @error "Parameter $name doesn't have bounds"
        end
    end
    return lower_bound, upper_bound
end