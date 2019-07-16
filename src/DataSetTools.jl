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
   Data[i] = vec(getfield(mc,i))
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
       (p1 = quantile(df[variable],pctls[1]),p2 = quantile(df[variable],pctls[2]))
    end
    data = join(data,temp,on = by_variable)
    name = Symbol("bin_$variable")
    data[name] = 0
    for i ∈ eachindex(data[variable])
      if data[variable][i] <= data[:p1][i]
         data[name][i] = 1
      elseif data[variable][i]> data[:p1][i] && data[variable][i]<= data[:p2][i]
         data[name][i] = 2
      elseif data[variable][i] > data[:p2][i]
         data[name][i] = 3
      end
    end
    rename!(data,:p1 => Symbol("$(variable)_p1"),:p2 => Symbol("$(variable)_p2"))
  elseif length(pctls) == 3
     temp = by(data, by_variable) do df
        (p1 = quantile(df[variable],pctls[1]),p2 = quantile(df[variable],pctls[2]), p3 = quantile(df[variable],pctls[3]))
     end
     data = join(data,temp,on = by_variable)
     name = Symbol("bin_$variable")
     data[name] = 0
     for i ∈ eachindex(data[variable])
       if data[variable][i] <= data[:p1][i]
          data[name][i] = 1
       elseif data[variable][i]> data[:p1][i] && data[variable][i]<= data[:p2][i]
          data[name][i] = 2
       elseif data[variable][i]> data[:p2][i] && data[variable][i]<= data[:p3][i]
          data[name][i] = 3
       elseif data[variable][i] > data[:p3][i]
          data[name][i] = 4
       end
     end
     rename!(data,:p1 => Symbol("$(variable)_p1"),:p2 => Symbol("$(variable)_p2"),:p3 => Symbol("$(variable)_p3"))
  elseif length(pctls) == 4
    temp = by(data, by_variable) do df
       (p1 = quantile(df[variable],pctls[1]),p2 = quantile(df[variable],pctls[2]), p3 = quantile(df[variable],pctls[3]), p4 = quantile(df[variable],pctls[4]))
    end
    data = join(data,temp,on = by_variable)
    name = Symbol("bin_$variable")
    data[name] = 0
    for i ∈ eachindex(data[variable])
      if data[variable][i] <= data[:p1][i]
         data[name][i] = 1
      elseif data[variable][i]> data[:p1][i] && data[variable][i]<= data[:p2][i]
         data[name][i] = 2
      elseif data[variable][i]> data[:p2][i] && data[variable][i]<= data[:p3][i]
         data[name][i] = 3
      elseif data[variable][i] > data[:p3][i]  && data[variable][i]<= data[:p4][i]
         data[name][i] = 4
      elseif data[variable][i] > data[:p4][i]
        data[name][i] = 5
      end
    end
    rename!(data,:p1 => Symbol("$(variable)_p1"),:p2 => Symbol("$(variable)_p2"),:p3 => Symbol("$(variable)_p3"),:p4 => Symbol("$(variable)_p4"))
  elseif length(pctls) == 9
    temp = by(data, by_variable) do df
       (p1 = quantile(df[variable],pctls[1]),p2 = quantile(df[variable],pctls[2]), p3 = quantile(df[variable],pctls[3]), p4 = quantile(df[variable],pctls[4]), p5 = quantile(df[variable],pctls[5]),
       p6 = quantile(df[variable],pctls[6]),p7 = quantile(df[variable],pctls[7]), p8 = quantile(df[variable],pctls[8]), p9 = quantile(df[variable],pctls[9]))
    end
    data = join(data,temp,on = by_variable)
    name = Symbol("bin_$variable")
    data[name] = 0
    for i ∈ eachindex(data[variable])
      if data[variable][i] <= data[:p1][i]
        data[name][i] = 1
      elseif data[variable][i]> data[:p1][i] && data[variable][i]<= data[:p2][i]
        data[name][i] = 2
      elseif data[variable][i]> data[:p2][i] && data[variable][i]<= data[:p3][i]
        data[name][i] = 3
      elseif data[variable][i] > data[:p3][i]  && data[variable][i]<= data[:p4][i]
        data[name][i] = 4
      elseif data[variable][i] > data[:p4][i]  && data[variable][i]<= data[:p5][i]
        data[name][i] = 5
      elseif data[variable][i] > data[:p5][i]  && data[variable][i]<= data[:p6][i]
        data[name][i] = 6
      elseif data[variable][i] > data[:p6][i]  && data[variable][i]<= data[:p7][i]
        data[name][i] = 7
      elseif data[variable][i] > data[:p7][i]  && data[variable][i]<= data[:p8][i]
        data[name][i] = 8
      elseif data[variable][i] > data[:p8][i]  && data[variable][i]<= data[:p9][i]
        data[name][i] = 9
      elseif data[variable][i] > data[:p9][i]
        data[name][i] = 10
      end
    end
    rename!(data,:p1 => Symbol("$(variable)_p1"),:p2 => Symbol("$(variable)_p2"),:p3 => Symbol("$(variable)_p3"),:p4 => Symbol("$(variable)_p4"),:p5 => Symbol("$(variable)_p5"),
    :p6 => Symbol("$(variable)_p6"),:p7 => Symbol("$(variable)_p7"),:p8 => Symbol("$(variable)_p8"),:p9 => Symbol("$(variable)_p9"))
    else
    error("Function supports 2, 3, 4 and 9 number of percentiles")
  end
  return data
end
