#=
function summarise(table,var::Symbol,by::Symbol)
  y = groupby((Mean =  mean,
              STD = std,
              Q25 = z->quantile(z,0.25),
              Median = z->quantile(z,0.5),
              Q75 = z->quantile(z,0.75)),
              table, by, select=var)
end
function summarise(table,var::Symbol,by::Symbol,weight::Symbol)
  y = groupby((Mean = z-> mean(getfield(columns(z),var),weights(getfield(columns(z),weight))),
              STD = z->std(getfield(columns(z),var),weights(getfield(columns(z),weight))),
              Q25 = z->quantile(getfield(columns(z),var),weights(getfield(columns(z),weight)),0.25),
              Median = z->quantile(getfield(columns(z),var),weights(getfield(columns(z),weight)),0.5),
              Q75 = z->quantile(getfield(columns(z),var),weights(getfield(columns(z),weight)),0.75)),
              table, by, select=(var,weight))
end

function summarise(table,var::Symbol,by::Tuple)
  y = groupby((Mean = mean,
              STD = std,
              Q25 = z->quantile(z,0.25),
              Median = z->quantile(z,0.5),
              Q75 = z->quantile(z,0.75)),
              table, by, select=var)
end
function summarise(table,var::Symbol,by::Tuple,weight::Symbol)
  y = groupby((Mean = z-> mean(getfield(columns(z),var),weights(getfield(columns(z),weight))),
              STD = z->std(getfield(columns(z),var),weights(getfield(columns(z),weight))),
              Q25 = z->quantile(getfield(columns(z),var),weights(getfield(columns(z),weight)),0.25),
              Median = z->quantile(getfield(columns(z),var),weights(getfield(columns(z),weight)),0.5),
              Q75 = z->quantile(getfield(columns(z),var),weights(getfield(columns(z),weight)),0.75)),
              table, by, select=(var,weight))
end
=#

function keep!(df::DataFrame,col::Array{Symbol})
  df = df[:,col]
end

function tabulate(table)
  y = freqtable(table)
  z = prop(y)
  y = hcat(y,z)
end

function reshape_results!(mc,D)
  N = D.N
  J = D.J
  temp = zeros(D.N*D.J)
  Data = DataFrame(temp = temp)
  for i in fieldnames(typeof(mc))
   Data[!,i] = vec(getfield(mc,i))
  end
  deletecols!(Data,:temp)
  return Data
end

function print_struct(S)
  for i in fieldnames(typeof(S))
   println(i ," = ", getfield(S,i))
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
    temp = by(data, by_variable) do df
       (pctl1 = quantile(df[!,variable],pctls[1]),pctl2 = quantile(df[!,variable],pctls[2]))
    end
    data = join(data,temp,on = by_variable)
    name = Symbol("bin_$variable")
    data[!,name].= 0
    for i ∈ eachindex(data[!,variable])
      if data[i,variable] <= data[i,:p1]
         data[i,name] = 1
      elseif data[i,variable]> data[i,:p1] && data[i,variable]<= data[i,:p2]
         data[i,name] = 2
      elseif data[i,variable] > data[i,:p2]
         data[i,name] = 3
      end
    end
    rename!(data,:pctl1 => Symbol("$(variable)_p1"),:pctl2 => Symbol("$(variable)_p2"))
  elseif length(pctls) == 3
     temp = by(data, by_variable) do df
        (pctl1 = quantile(df[!,variable],pctls[1]),pctl2 = quantile(df[!,variable],pctls[2]), pctl3 = quantile(df[!,variable],pctls[3]))
     end
     data = join(data,temp,on = by_variable)
     name = Symbol("bin_$variable")
     data[!,name].= 0
     for i ∈ eachindex(data[!,variable])
       if data[i,variable] <= data[i,:p1]
          data[i,name] = 1
       elseif data[i,variable]> data[i,:p1] && data[i,variable]<= data[i,:p2]
          data[i,name] = 2
       elseif data[i,variable]> data[i,:p2] && data[i,variable]<= data[i,:p3]
          data[i,name] = 3
       elseif data[i,variable] > data[i,:p3]
          data[i,name] = 4
       end
     end
     rename!(data,:pctl1 => Symbol("$(variable)_p1"),:pctl2 => Symbol("$(variable)_p2"),:pctl3 => Symbol("$(variable)_p3"))
  elseif length(pctls) == 4
    temp = by(data, by_variable) do df
       (pctl1 = quantile(df[!,variable],pctls[1]),pctl2 = quantile(df[!,variable],pctls[2]), pctl3 = quantile(df[!,variable],pctls[3]), pctl4 = quantile(df[!,variable],pctls[4]))
    end
    data = join(data,temp,on = by_variable)
    name = Symbol("bin_$variable")
    data[!,name].= 0
    for i ∈ eachindex(data[!,variable])
      if data[i,variable] <= data[i,:p1]
         data[i,name] = 1
      elseif data[i,variable]> data[i,:p1] && data[i,variable]<= data[i,:p2]
         data[i,name] = 2
      elseif data[i,variable]> data[i,:p2] && data[i,variable]<= data[i,:p3]
         data[i,name] = 3
      elseif data[i,variable] > data[i,:p3]  && data[i,variable]<= data[i,:p4]
         data[i,name] = 4
      elseif data[i,variable] > data[i,:p4]
        data[i,name] = 5
      end
    end
    rename!(data,:pctl1 => Symbol("$(variable)_p1"),:pctl2 => Symbol("$(variable)_p2"),:pctl3 => Symbol("$(variable)_p3"),:pctl4 => Symbol("$(variable)_p4"))
  elseif length(pctls) == 9
    temp = by(data, by_variable) do df
       (pctl1 = quantile(df[!,variable],pctls[1]),pctl2 = quantile(df[!,variable],pctls[2]), pctl3 = quantile(df[!,variable],pctls[3]), pctl4 = quantile(df[!,variable],pctls[4]), pctl5 = quantile(df[!,variable],pctls[5]),
       pctl6 = quantile(df[!,variable],pctls[6]),pctl7 = quantile(df[!,variable],pctls[7]), pctl8 = quantile(df[!,variable],pctls[8]), pctl9 = quantile(df[!,variable],pctls[9]))
    end
    data = join(data,temp,on = by_variable)
    name = Symbol("bin_$variable")
    data[!,name].= 0
    for i ∈ eachindex(data[!,variable])
      if data[i,variable] <= data[i,:p1]
        data[i,name] = 1
      elseif data[i,variable]> data[i,:p1] && data[i,variable]<= data[i,:p2]
        data[i,name] = 2
      elseif data[i,variable]> data[i,:p2] && data[i,variable]<= data[i,:p3]
        data[i,name] = 3
      elseif data[i,variable] > data[i,:p3]  && data[i,variable]<= data[i,:p4]
        data[i,name] = 4
      elseif data[i,variable] > data[i,:p4]  && data[i,variable]<= data[i,:p5]
        data[i,name] = 5
      elseif data[i,variable] > data[i,:p5]  && data[i,variable]<= data[i,:p6]
        data[i,name] = 6
      elseif data[i,variable] > data[i,:p6]  && data[i,variable]<= data[i,:p7]
        data[i,name] = 7
      elseif data[i,variable] > data[i,:p7]  && data[i,variable]<= data[i,:p8]
        data[i,name] = 8
      elseif data[i,variable] > data[i,:p8]  && data[i,variable]<= data[i,:p9]
        data[i,name] = 9
      elseif data[i,variable] > data[i,:p9]
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
