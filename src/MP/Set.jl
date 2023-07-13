# function set(str,var,val)
#     !any(i->i==var, fieldnames(typeof(str))) && @warn "\n No field in struct $(typeof(str)) is named $(var)!\n Fields are $(fieldnames(typeof(str)))"
#     dict = Dict{Symbol,Any}()
#     for (i,name) in enumerate(fieldnames(typeof(str)))
#         if typeof(getfield(str,name))<:Parameter && name == var
#             dict[name] = Parameter(val,getfield(getfield(str,name),:description))
#         elseif typeof(getfield(str,name))<:Parameter
#             dict[name] = Parameter(getfield(getfield(str,name),:value),getfield(getfield(str,name),:description))
#         elseif typeof(getfield(str,name))<:BoundedParameter && name == var
#             dict[name] = BoundedParameter(val,getfield(getfield(str,name),:description),getfield(getfield(str,name),:lb),getfield(getfield(str,name),:ub))
#         elseif typeof(getfield(str,name))<:BoundedParameter
#             dict[name] = BoundedParameter(getfield(getfield(str,name),:value),getfield(getfield(str,name),:description),getfield(getfield(str,name),:lb),getfield(getfield(str,name),:ub))
#         elseif name == var
#             dict[name] = val
#         else
#             dict[name] = getfield(str,name)
#         end
#     end
#     x = NamedTuple{Tuple(keys(dict))}(values(dict))
#     str = typeof(str)(;x...)
# end

function set(str, var, val)
    dict = Dict{Symbol,Any}()
    for (i, name) in enumerate(fieldnames(typeof(str)))
        if typeof(getfield(str, name)) <: Param && name == var
            nt = (val=val,)
            if length(keys(getfield(str, name))) > 1
                nt2 = delete(parent(getfield(str, name)), :val)
                nt = merge(nt, nt2)
            end
            dict[name] = Param(nt)
        elseif typeof(getfield(str, name)) <: Param
            dict[name] = getfield(str, name)
        elseif name == var
            dict[name] = val
        else
            dict[name] = getfield(str, name)
        end
    end
    x = NamedTuple{Tuple(keys(dict))}(values(dict))
    str = typeof(str)(; x...)
end


function set(str, tpl::Tuple)
    if typeof(values(tpl)[1]) ≠ Symbol
        for value in values(tpl)
            str = set(str, value[1], value[2])
        end
    else
        str = set(str, tpl[1], tpl[2])
    end
    return str
end

function (←)(str,tpl::Tuple)
    if typeof(values(tpl)[1]) ≠ Symbol
        for value in values(tpl)
            str = set(str,value[1],value[2])
        end
    else
        str = set(str,tpl[1],tpl[2])
    end
    return str
end
