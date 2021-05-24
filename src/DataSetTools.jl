
function pivot_longer(df::AbstractDataFrame,bycol::Symbol,cols::Vector{Symbol};period = :Period, separator = true)
    # temp = nothing
     df_longer = nothing
     m = nothing
    @inbounds for col ∈ cols
        try
        temp = select(df,Regex(String(col)))
        @inbounds for colname ∈ names(temp)
          if separator
              m = match(Regex("($(col))(?<Value>\\d+)"),String(colname))
          else
              m = match(Regex("($(col))(?<Value>\\d+)"),String(colname))
          end
          if m == nothing
            println("Column $(col) has no regex match")
          else
            rename!(temp,colname=>Symbol(m[2]))
          end
        end
        temp[!,bycol] = df[!,bycol]
        temp = stack(temp,Not(bycol),variable_eltype=String)
        rename!(temp,:variable => period, :value => Symbol(m[1]))
        if df_longer == nothing
            df_longer = temp
        else
            df_longer = outerjoin(df_longer, temp, on = [bycol,period],makeunique=true)
        end
        catch
            @warn "Problem with column $col"
        end
    end
    return df_longer
end


match(r"(age)(?<Value>\d+)",String(:age67))

function reshape_results!(mc,D)
  N = D.N
  J = D.J
  temp = zeros(D.N*D.J)
  Data = DataFrame(temp = temp)
  for i in fieldnames(typeof(mc))
   Data[!,i] = vec(getfield(mc,i))
  end
  select!(Data,Not(:temp))
  return Data
end

function print_struct(S)
  s = maximum(length.(string.(fieldnames(typeof(S)))))
  for i in fieldnames(typeof(S))
  @info "$(rpad(i,s," ")) = $(round.(getfield(S,i),digits=2))"
  end
end

function print_parameters(P)
  for i ∈ fieldnames(typeof(P))
    println("--------------------")
    @info typeof(getfield(P,i))
    println("--------------------")
    print_struct(getfield(P,i))
  end
end

"""
```
percentiles!(data,by_variable,variable;pctls = [0.05, 0.5, 0.95])
```

Example:

data = percentiles!(df,:age,:income,pctls = [0.1,0.9])

Returns additional columns:

data[:income_p1, :income_p2]

data[:bin_income] # with values 1, 2, 3

"""
function percentiles!(data,by_variable,variable;pctls = [0.05, 0.5, 0.95])
  if length(pctls) == 2
    temp = combine(groupby(data,by_variable), variable => (x -> [quantile(x, pctls)]) => [:pctl1, :pctl2])
    data = innerjoin(data,temp,on = by_variable)
    name = Symbol("bin_$variable")
    data[!,name].= 0
    for i ∈ eachindex(data[!,variable])
      if data[i,variable] <= data[i,:pctl1]
         data[i,name] = 1
      elseif data[i,variable]> data[i,:pctl1] && data[i,variable]<= data[i,:pctl2]
         data[i,name] = 2
      elseif data[i,variable] > data[i,:pctl2]
         data[i,name] = 3
      end
    end
    rename!(data,:pctl1 => Symbol("$(variable)_p1"),:pctl2 => Symbol("$(variable)_p2"))
  elseif length(pctls) == 3
     temp = combine(groupby(data,by_variable), variable => (x -> [quantile(x, pctls)]) => [:pctl1, :pctl2, :pctl3])
     data = innerjoin(data,temp,on = by_variable)
     name = Symbol("bin_$variable")
     data[!,name].= 0
     for i ∈ eachindex(data[!,variable])
       if data[i,variable] <= data[i,:pctl1]
          data[i,name] = 1
       elseif data[i,variable]> data[i,:pctl1] && data[i,variable]<= data[i,:pctl2]
          data[i,name] = 2
       elseif data[i,variable]> data[i,:pctl2] && data[i,variable]<= data[i,:pctl3]
          data[i,name] = 3
       elseif data[i,variable] > data[i,:pctl3]
          data[i,name] = 4
       end
     end
     rename!(data,:pctl1 => Symbol("$(variable)_p1"),:pctl2 => Symbol("$(variable)_p2"),:pctl3 => Symbol("$(variable)_p3"))
  elseif length(pctls) == 4
    temp = combine(groupby(data,by_variable), variable => (x -> [quantile(x, pctls)]) => [:pctl1, :pctl2, :pctl3, :pctl4])
    data = innerjoin(data,temp,on = by_variable)
    name = Symbol("bin_$variable")
    data[!,name].= 0
    for i ∈ eachindex(data[!,variable])
      if data[i,variable] <= data[i,:pctl1]
         data[i,name] = 1
      elseif data[i,variable]> data[i,:pctl1] && data[i,variable]<= data[i,:pctl2]
         data[i,name] = 2
      elseif data[i,variable]> data[i,:pctl2] && data[i,variable]<= data[i,:pctl3]
         data[i,name] = 3
      elseif data[i,variable] > data[i,:pctl3]  && data[i,variable]<= data[i,:pctl4]
         data[i,name] = 4
      elseif data[i,variable] > data[i,:pctl4]
        data[i,name] = 5
      end
    end
    rename!(data,:pctl1 => Symbol("$(variable)_p1"),:pctl2 => Symbol("$(variable)_p2"),:pctl3 => Symbol("$(variable)_p3"),:pctl4 => Symbol("$(variable)_p4"))
  elseif length(pctls) == 9
    temp = combine(groupby(data,by_variable), variable => (x -> [quantile(x, pctls)]) => [:pctl1, :pctl2, :pctl3, :pctl4, :pctl5, :pctl6, :pctl7, :pctl8, :pctl9])

    data = innerjoin(data,temp,on = by_variable)
    name = Symbol("bin_$variable")
    data[!,name].= 0
    for i ∈ eachindex(data[!,variable])
      if data[i,variable] <= data[i,:pctl1]
        data[i,name] = 1
      elseif data[i,variable]> data[i,:pctl1] && data[i,variable]<= data[i,:pctl2]
        data[i,name] = 2
      elseif data[i,variable]> data[i,:pctl2] && data[i,variable]<= data[i,:pctl3]
        data[i,name] = 3
      elseif data[i,variable] > data[i,:pctl3]  && data[i,variable]<= data[i,:pctl4]
        data[i,name] = 4
      elseif data[i,variable] > data[i,:pctl4]  && data[i,variable]<= data[i,:pctl5]
        data[i,name] = 5
      elseif data[i,variable] > data[i,:pctl5]  && data[i,variable]<= data[i,:pctl6]
        data[i,name] = 6
      elseif data[i,variable] > data[i,:pctl6]  && data[i,variable]<= data[i,:pctl7]
        data[i,name] = 7
      elseif data[i,variable] > data[i,:pctl7]  && data[i,variable]<= data[i,:pctl8]
        data[i,name] = 8
      elseif data[i,variable] > data[i,:pctl8]  && data[i,variable]<= data[i,:pctl9]
        data[i,name] = 9
      elseif data[i,variable] > data[i,:pctl9]
        data[i,name] = 10
      end
    end
    rename!(data,:pctl1 => Symbol("$(variable)_p1"),:pctl2 => Symbol("$(variable)_p2"),:pctl3 => Symbol("$(variable)_p3"),:pctl4 => Symbol("$(variable)_p4"),:pctl5 => Symbol("$(variable)_p5"),
    :pctl6 => Symbol("$(variable)_p6"),:pctl7 => Symbol("$(variable)_p7"),:pctl8 => Symbol("$(variable)_p8"),:pctl9 => Symbol("$(variable)_p9"))
    else
    error("Function supports 2, 3, 4 and 9 number of percentiles")
  end
  return data
end

function percentiles!(data,variable;pctls = [0.05, 0.5, 0.95])
  if length(pctls) == 2
      for i ∈ 1: length(pctls)
          data[!,Symbol("pctl$i")] .= quantile(data[!,variable],pctls[i])
      end
      name = Symbol("bin_$variable")
      data[!,Symbol("bin_$variable")].= 0
    for i ∈ eachindex(data[!,variable])
      if data[i,variable] <= data[i,:pctl1]
         data[i,name] = 1
      elseif data[i,variable]> data[i,:pctl1] && data[i,variable]<= data[i,:pctl2]
         data[i,name] = 2
      elseif data[i,variable] > data[i,:pctl2]
         data[i,name] = 3
      end
    end
    rename!(data,:pctl1 => Symbol("$(variable)_p1"),:pctl2 => Symbol("$(variable)_p2"))
  elseif length(pctls) == 3
      for i ∈ 1: length(pctls)
          data[!,Symbol("pctl$i")] .= quantile(data[!,variable],pctls[i])
      end
      name = Symbol("bin_$variable")
      data[!,Symbol("bin_$variable")].= 0
     for i ∈ eachindex(data[!,variable])
       if data[i,variable] <= data[i,:pctl1]
          data[i,name] = 1
       elseif data[i,variable]> data[i,:pctl1] && data[i,variable]<= data[i,:pctl2]
          data[i,name] = 2
       elseif data[i,variable]> data[i,:pctl2] && data[i,variable]<= data[i,:pctl3]
          data[i,name] = 3
       elseif data[i,variable] > data[i,:pctl3]
          data[i,name] = 4
       end
     end
     rename!(data,:pctl1 => Symbol("$(variable)_p1"),:pctl2 => Symbol("$(variable)_p2"),:pctl3 => Symbol("$(variable)_p3"))
  elseif length(pctls) == 4
      for i ∈ 1: length(pctls)
          data[!,Symbol("pctl$i")] .= quantile(data[!,variable],pctls[i])
      end
      name = Symbol("bin_$variable")
      data[!,Symbol("bin_$variable")].= 0
    for i ∈ eachindex(data[!,variable])
      if data[i,variable] <= data[i,:pctl1]
         data[i,name] = 1
      elseif data[i,variable]> data[i,:pctl1] && data[i,variable]<= data[i,:pctl2]
         data[i,name] = 2
      elseif data[i,variable]> data[i,:pctl2] && data[i,variable]<= data[i,:pctl3]
         data[i,name] = 3
      elseif data[i,variable] > data[i,:pctl3]  && data[i,variable]<= data[i,:pctl4]
         data[i,name] = 4
      elseif data[i,variable] > data[i,:pctl4]
        data[i,name] = 5
      end
    end
    rename!(data,:pctl1 => Symbol("$(variable)_p1"),:pctl2 => Symbol("$(variable)_p2"),:pctl3 => Symbol("$(variable)_p3"),:pctl4 => Symbol("$(variable)_p4"))
  elseif length(pctls) == 9
      for i ∈ 1: length(pctls)
          data[!,Symbol("pctl$i")] .= quantile(data[!,variable],pctls[i])
      end
      name = Symbol("bin_$variable")
      data[!,Symbol("bin_$variable")].= 0
    for i ∈ eachindex(data[!,variable])
      if data[i,variable] <= data[i,:pctl1]
        data[i,name] = 1
      elseif data[i,variable]> data[i,:pctl1] && data[i,variable]<= data[i,:pctl2]
        data[i,name] = 2
      elseif data[i,variable]> data[i,:pctl2] && data[i,variable]<= data[i,:pctl3]
        data[i,name] = 3
      elseif data[i,variable] > data[i,:pctl3]  && data[i,variable]<= data[i,:pctl4]
        data[i,name] = 4
      elseif data[i,variable] > data[i,:pctl4]  && data[i,variable]<= data[i,:pctl5]
        data[i,name] = 5
      elseif data[i,variable] > data[i,:pctl5]  && data[i,variable]<= data[i,:pctl6]
        data[i,name] = 6
      elseif data[i,variable] > data[i,:pctl6]  && data[i,variable]<= data[i,:pctl7]
        data[i,name] = 7
      elseif data[i,variable] > data[i,:pctl7]  && data[i,variable]<= data[i,:pctl8]
        data[i,name] = 8
      elseif data[i,variable] > data[i,:pctl8]  && data[i,variable]<= data[i,:pctl9]
        data[i,name] = 9
      elseif data[i,variable] > data[i,:pctl9]
        data[i,name] = 10
      end
    end
    rename!(data,:pctl1 => Symbol("$(variable)_p1"),:pctl2 => Symbol("$(variable)_p2"),:pctl3 => Symbol("$(variable)_p3"),:pctl4 => Symbol("$(variable)_p4"),:pctl5 => Symbol("$(variable)_p5"),
    :pctl6 => Symbol("$(variable)_p6"),:pctl7 => Symbol("$(variable)_p7"),:pctl8 => Symbol("$(variable)_p8"),:pctl9 => Symbol("$(variable)_p9"))
    else
    error("Function supports 2, 3, 4 and 9 number of percentiles")
  end
  return data
end

function at_percentiles!(data,by_variable,variable;pctls = [0.05, 0.5, 0.95])
  if length(pctls) == 2
    temp = by(data, by_variable) do df
       (pctl1 = quantile(df[!,variable],pctls[1]),pctl2 = quantile(df[!,variable],pctls[2]))
    end
    data = join(data,temp,on = by_variable)
    name = Symbol("bin_at_$variable")
    data[!,name].= 0
    for i ∈ eachindex(data[!,variable])
      if data[i,variable] ≈ data[i,:pctl1]
         data[i,name] = 1
      elseif data[i,variable]≈ data[i,:pctl2]
         data[i,name] = 2
      end
    end
    rename!(data,:pctl1 => Symbol("$(variable)_at_p1"),:pctl2 => Symbol("$(variable)_at_p2"))
  elseif length(pctls) == 3
     temp = by(data, by_variable) do df
        (pctl1 = quantile(df[!,variable],pctls[1]),pctl2 = quantile(df[!,variable],pctls[2]), pctl3 = quantile(df[!,variable],pctls[3]))
     end
     data = join(data,temp,on = by_variable)
     name = Symbol("bin_at_$variable")
     data[!,name].= 0
     for i ∈ eachindex(data[!,variable])
       if data[i,variable] ≈ data[i,:pctl1]
          data[i,name] = 1
       elseif  data[i,variable] ≈ data[i,:pctl2]
          data[i,name] = 2
       elseif data[i,variable]≈ data[i,:pctl3]
          data[i,name] = 3
       end
     end
     rename!(data,:pctl1 => Symbol("$(variable)_at_p1"),:pctl2 => Symbol("$(variable)_at_p2"),:pctl3 => Symbol("$(variable)_at_p3"))
  elseif length(pctls) == 4
    temp = by(data, by_variable) do df
       (pctl1 = quantile(df[!,variable],pctls[1]),pctl2 = quantile(df[!,variable],pctls[2]), pctl3 = quantile(df[!,variable],pctls[3]), pctl4 = quantile(df[!,variable],pctls[4]))
    end
    data = join(data,temp,on = by_variable)
    name = Symbol("bin_at_$variable")
    data[!,name].= 0
    for i ∈ eachindex(data[!,variable])
      if data[i,variable] ≈ data[i,:pctl1]
         data[i,name] = 1
      elseif data[i,variable] ≈ data[i,:pctl2]
         data[i,name] = 2
      elseif data[i,variable]≈ data[i,:pctl3]
         data[i,name] = 3
      elseif data[i,variable] ≈ data[i,:pctl4]
         data[i,name] = 4
      end
    end
    rename!(data,:pctl1 => Symbol("$(variable)_at_p1"),:pctl2 => Symbol("$(variable)_at_p2"),:pctl3 => Symbol("$(variable)_at_p3"),:pctl4 => Symbol("$(variable)_at_p4"))
  elseif length(pctls) == 9
    temp = by(data, by_variable) do df
       (pctl1 = quantile(df[!,variable],pctls[1]),pctl2 = quantile(df[!,variable],pctls[2]), pctl3 = quantile(df[!,variable],pctls[3]), pctl4 = quantile(df[!,variable],pctls[4]), pctl5 = quantile(df[!,variable],pctls[5]),
       pctl6 = quantile(df[!,variable],pctls[6]),pctl7 = quantile(df[!,variable],pctls[7]), pctl8 = quantile(df[!,variable],pctls[8]), pctl9 = quantile(df[!,variable],pctls[9]))
    end
    data = join(data,temp,on = by_variable)
    name = Symbol("bin_at_$variable")
    data[!,name].= 0
    for i ∈ eachindex(data[!,variable])
      if data[i,variable] ≈ data[i,:pctl1]
        data[i,name] = 1
      elseif data[i,variable] ≈ data[i,:pctl2]
        data[i,name] = 2
      elseif data[i,variable] ≈ data[i,:pctl3]
        data[i,name] = 3
      elseif data[i,variable] ≈ data[i,:pctl4]
        data[i,name] = 4
      elseif data[i,variable] ≈ data[i,:pctl5]
        data[i,name] = 5
      elseif data[i,variable] ≈ data[i,:pctl6]
        data[i,name] = 6
      elseif data[i,variable] ≈ data[i,:pctl7]
        data[i,name] = 7
      elseif data[i,variable] ≈ data[i,:pctl8]
        data[i,name] = 8
      elseif data[i,variable] ≈ data[i,:pctl9]
        data[i,name] = 9
      end
    end
    rename!(data,:pctl1 => Symbol("$(variable)_at_p1"),:pctl2 => Symbol("$(variable)_at_p2"),:pctl3 => Symbol("$(variable)_at_p3"),:pctl4 => Symbol("$(variable)_at_p4"),:pctl5 => Symbol("$(variable)_at_p5"),
    :pctl6 => Symbol("$(variable)_at_p6"),:pctl7 => Symbol("$(variable)_at_p7"),:pctl8 => Symbol("$(variable)_at_p8"),:pctl9 => Symbol("$(variable)_at_p9"))
    else
    error("Function supports 2, 3, 4 and 9 number of percentiles")
  end
  return data
end



function tab(x)
  x = collect(skipmissing(x))
  temp = DataFrame(Variable = collect(extrema(unique(x))[1]:extrema(unique(x))[2]), Proportion = proportions(x,extrema(unique(x))[1]:extrema(unique(x))[2]))
  temp = temp[temp.Proportion.!=0.0,:]
  return temp
end

function tab(x,wt)
    df = DataFrame(x1 = x, wt1 = wt)
    dropmissing!(df)
    df.wt1 = weights(df.wt1)
  temp = DataFrame(Variable = collect(extrema(unique(df.x1))[1]:extrema(unique(df.x1))[2]), Proportion = proportions(df.x1,extrema(unique(df.x1))[1]:extrema(unique(df.x1))[2],df.wt1))
  temp = temp[temp.Proportion.!=0.0,:]
  return temp
end

function writeGzip(df,path)
  open(GzipCompressorStream, path, "w") do stream
      CSV.write(stream, df)
  end
end

function readGzip(path;head = 1)
  df = CSV.File(transcode(GzipDecompressor, Mmap.mmap(path)),header = head) |> DataFrame
end

function createAgeGroups(df::DataFrame,agemin::Int64,agemax::Int64,step::Int64,agevar::Symbol,varname::Symbol)
    agerange = collect(agemin:step:agemax)
    df[!,varname] .= missing
    N = length(agerange)
    for i in 1:nrow(df)
        for j in 1:N-1
            if !ismissing(df[i,agevar])
                if df[i,agevar] ≥ agerange[j]  && df[i,agevar] < agerange[j+1]
                    df[i,varname] = j
                end
            end
        end
    end
    return df
end