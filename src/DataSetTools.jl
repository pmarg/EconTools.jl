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
  deletecols!(Data,temp)
  return Data
end
