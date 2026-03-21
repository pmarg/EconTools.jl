"""
    set(str,var::Symbol,val)

Substitutes the value a single field `var` with `val`. Returns the modified `str`.
"""
function set(str, var::Symbol, val)
    !any(i -> i == var, fieldnames(typeof(str))) && @warn "\n No field in struct $(typeof(str)) is named $(var)!\n Fields are $(fieldnames(typeof(str)))"
    dict = Dict{Symbol,Any}()
    for (i, name) in enumerate(fieldnames(typeof(str)))
        if typeof(getfield(str, name)) <: Parameter && name == var
            dict[name] = Parameter(val, getfield(getfield(str, name), :description))
        elseif typeof(getfield(str, name)) <: Parameter
            dict[name] = Parameter(getfield(getfield(str, name), :value), getfield(getfield(str, name), :description))
        elseif typeof(getfield(str, name)) <: BoundedParameter && name == var
            dict[name] = BoundedParameter(val, getfield(getfield(str, name), :lb), getfield(getfield(str, name), :ub), getfield(getfield(str, name), :description))
        elseif typeof(getfield(str, name)) <: BoundedParameter
            dict[name] = BoundedParameter(getfield(getfield(str, name), :value), getfield(getfield(str, name), :lb), getfield(getfield(str, name), :ub), getfield(getfield(str, name), :description))
        elseif name == var
            dict[name] = val
        else
            dict[name] = getfield(str, name)
        end
    end
    x = NamedTuple{Tuple(keys(dict))}(values(dict))
    str = typeof(str)(; x...)
end
"""
    (←)(str, tpl::Tuple)

Substitutes the value of a single or multiple fields of struct `str`. The tuple has the form (field::Symbol, new_value). Returns the modified `str`.
"""
function (←)(str, tpl::Tuple)
    if typeof(values(tpl)[1]) ≠ Symbol
        for value in values(tpl)
            str = set(str, value[1], value[2])
        end
    else
        str = set(str, tpl[1], tpl[2])
    end
    return str
end