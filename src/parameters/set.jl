"""
    set(str, var::Symbol, val)

Return a copy of the struct `str` with field `var` set to `val`; `str` itself is not
modified (it may be immutable).

If `var` is a `Parameter` or `BoundedParameter`, only its value changes; the
description and bounds are kept. All other fields are copied.

The struct is rebuilt with its keyword constructor, so its type must have one (e.g.
defined with `@kwdef` or `Parameters.@with_kw`). If `str` has no field `var`, a
warning lists the fields.

# Examples
```julia
D2 = set(D, :N, 1000)
```

See also [`←`](@ref).
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
    str ← (field, value)
    str ← ((field1, value1), (field2, value2), ...)

Return a copy of the struct `str` with one or several fields replaced, using
[`set`](@ref) for each.

# Examples
```julia
D2 = D ← (:J, 3)                  # one field
D3 = D ← ((:J, 3), (:N, 10))      # several fields
```
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