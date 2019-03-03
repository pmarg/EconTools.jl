using JuliaDB, Statistics, StatsBase

function summarise(table,var::Symbol,by::Symbol;path = "None")
  y = groupby((Mean =  mean,
              STD = std,
              Q25 = z->quantile(z,0.25),
              Median = z->quantile(z,0.5),
              Q75 = z->quantile(z,0.75)),
              table, by, select=var)
end
function summarise(table,var::Symbol,by::Symbol,weight::Symbol;path = "None")
  y = groupby((Mean = z-> mean(getfield(columns(z),var),weights(getfield(columns(z),weight))),
              STD = z->std(getfield(columns(z),var),weights(getfield(columns(z),weight))),
              Q25 = z->quantile(getfield(columns(z),var),weights(getfield(columns(z),weight)),0.25),
              Median = z->quantile(getfield(columns(z),var),weights(getfield(columns(z),weight)),0.5),
              Q75 = z->quantile(getfield(columns(z),var),weights(getfield(columns(z),weight)),0.75)),
              table, by, select=(var,weight))
end

function summarise(table,var::Symbol,by::Tuple;path = "None")
  y = groupby((Mean = mean,
              STD = std,
              Q25 = z->quantile(z,0.25),
              Median = z->quantile(z,0.5),
              Q75 = z->quantile(z,0.75)),
              table, by, select=var)
end
function summarise(table,var::Symbol,by::Tuple,weight::Symbol;path = "None")
  y = groupby((Mean = z-> mean(getfield(columns(z),var),weights(getfield(columns(z),weight))),
              STD = z->std(getfield(columns(z),var),weights(getfield(columns(z),weight))),
              Q25 = z->quantile(getfield(columns(z),var),weights(getfield(columns(z),weight)),0.25),
              Median = z->quantile(getfield(columns(z),var),weights(getfield(columns(z),weight)),0.5),
              Q75 = z->quantile(getfield(columns(z),var),weights(getfield(columns(z),weight)),0.75)),
              table, by, select=(var,weight))
end
