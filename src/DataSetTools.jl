using JuliaDB, Stats
import JuliaDB: DNextTable

"""
    descriptive_stats(table::DNextTable,var::String,by::Tuple;weight="None")
Returns a new table containing  the mean, standard deviation, 1st, 2nd and 3rd quantiles of
variable `var` by a selection of tuple of columns `by`. Weights are optional and if specified,
the function returns the weighted descriptive statistics.
"""
function descriptive_stats(table::DNextTable,var::String,by::Tuple;weight="None")
    if weight=="None"
        y= groupby(@NT(
        avg=mean,
        std1=std,
        q25=z->quantile(z,0.25),
        median1 = median,
        q75=z->quantile(z,0.25)
        ),
        table,by,select=Symbol(var))
    else
        y= groupby(@NT(
        avg=z->mean(column(z,Symbol(var)),weights(column(z,Symbol(weight)))),
        std1=z->std(column(z,Symbol(var)),weights(column(z,Symbol(weight)))),
        q25=z->quantile(column(z,Symbol(var)),0.25),
        median1=z->median(column(z,Symbol(var)),weights(column(z,Symbol(weight)))),
        q75=z->quantile(column(z,Symbol(var)),0.75)
        ),
        table,by,select=(Symbol(var),Symbol(weight)))
    end
    return y
end

"""
    save_csv(path::String,table::DNextTable)
    Saves table as CSV at the specified path
"""
function save_csv(path::String,table::DNextTable)
    open(path,"w") do fid
        println(fid,join(colnames(table),','))
        for i in collect(table)
            println(fid,join(i,','))
        end
    end
end
