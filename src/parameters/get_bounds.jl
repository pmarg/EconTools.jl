"""
    get_initial_guess(parameters)

Returns the values of parameter vector. Useful for initial guess for optimization.
"""
function get_initial_guess(parameters)
    initial_guess = zeros(size(parameters, 1))
    for i ∈ 1:size(parameters, 1)
        initial_guess[i] = parameters[i].value
    end
    return initial_guess
end
"""
    get_lower_bounds(parameters::Array{Float64)

Returns the lower bounds of parameter vector. Useful for constrained optimization.
"""
function get_lower_bounds(parameters)
    lower_bound = zeros(size(parameters, 1))
    for i ∈ 1:size(parameters, 1)
        lower_bound[i] = parameters[i].lb
    end
    return lower_bound
end
"""
    get_upper_bounds(parameters::Array{Float64)

Returns the upper bounds of parameter vector. Useful for constrained optimization.
"""
function get_upper_bounds(parameters)
    upper_bound = zeros(size(parameters, 1))
    for i ∈ 1:size(parameters, 1)
        upper_bound[i] = parameters[i].ub
    end
    return upper_bound
end
"""
    get_bounds(name::ParameterGroup, val::Symbol)

Returns the lower and upper bound of a single parameter withing a `ParameterGroup`. Useful for constrained optimization.
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