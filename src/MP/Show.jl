function Base.show(io::IO, x::ParameterGroup)
    s1 = maximum(length.(string.(fieldnames(typeof(x)),"Variable")))
    vals = Dict{Symbol,Any}()
    desc = Dict{Symbol,Any}()
    for name in fieldnames(typeof(x))
        if typeof(getfield(x,name))<:AbstractParameter
            if typeof(getfield(getfield(x,name),:value)) <: Real 
                vals[name] = round.(getfield(getfield(x,name),:value),digits = 3)
                desc[name] =  getfield(getfield(x,name),:description)
            else
                vals[name] = getfield(getfield(x,name),:value)
                desc[name] =  getfield(getfield(x,name),:description)
            end
        else
            vals[name] = getfield(x,name)
            desc[name] = "No Description"
        end
    end
    s2 = maximum(length.(string.(values(desc))))
    s3 = length.(string.("Values      "))
    s3 = s3+s2+s1
    print(io,"$(rpad("Variable",s1," ")) | ")
    print(io,"$(rpad("Description",s2," ")) | ")
    print(io,"Value\n")
    print(io,rpad("-",s3,"-"),"\n")
    for name in fieldnames(typeof(x))
        if typeof(getfield(x,name))<:AbstractParameter
            print(io,rpad(name,s1," ")," | ")
            print(io,"$(rpad(getfield(getfield(x,name),:description),s2," ")) | ")
            print(IOContext(io, :compact => true,:displaysize => (1,2),:limit=>true),vals[name],"\n")
        else
            print(io,rpad(name,s1," ")," | ")
            print(io,"$(rpad("No Description",s2," ")) | ")
            print(IOContext(io, :compact => true,:displaysize => (1,2),:limit=>true),vals[name],"\n")
        end
    end
end


function Base.show(io::IO,::MIME"text/plain", x::ParameterGroup)
    s1 = maximum(length.(string.(fieldnames(typeof(x)),"Variable")))
    vals = Dict{Symbol,Any}()
    desc = Dict{Symbol,Any}()
    for name in fieldnames(typeof(x))
        if typeof(getfield(x,name))<:AbstractParameter
            if typeof(getfield(getfield(x,name),:value)) <: Real 
                vals[name] = round.(getfield(getfield(x,name),:value),digits = 3)
                desc[name] =  getfield(getfield(x,name),:description)
            else
                vals[name] = getfield(getfield(x,name),:value)
                desc[name] =  getfield(getfield(x,name),:description)
            end
        else
            vals[name] = getfield(x,name)
            desc[name] = "No Description"
        end
    end
    s2 = maximum(length.(string.(values(desc))))
    s3 = length.(string.("Values      "))
    s3 = s3+s2+s1
    print(io,"$(rpad("Variable",s1," ")) | ")
    print(io,"$(rpad("Description",s2," ")) | ")
    print(io,"Value\n")
    print(io,rpad("-",s3,"-"),"\n")
    for name in fieldnames(typeof(x))
        if typeof(getfield(x,name))<:AbstractParameter
            print(io,rpad(name,s1," ")," | ")
            print(io,"$(rpad(getfield(getfield(x,name),:description),s2," ")) | ")
            print(IOContext(io, :compact => true,:displaysize => (1,2),:limit=>true),vals[name],"\n")
        else
            print(io,rpad(name,s1," ")," | ")
            print(io,"$(rpad("No Description",s2," ")) | ")
            print(IOContext(io, :compact => true,:displaysize => (1,2),:limit=>true),vals[name],"\n")
        end
    end
end

function Base.show(io::IO,::MIME"text/plain", x::ParameterSpace)
    for str in fieldnames(typeof(x))
        println(io,"Parameters for ",typeof(getfield(x,str)),":")
        println(io,getfield(x,str))
    end
end

function Base.show(io::IO, x::ParameterSpace)
    for str in fieldnames(typeof(x))
        println(io,"Parameters for ",typeof(getfield(x,str)),":")
        println(io,getfield(x,str))
    end
end
