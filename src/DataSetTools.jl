#=
using JuliaDB, Stats

"""
    descriptive_stats(table,var::String,bycolumn::Tuple;weight="None")
Returns a new table containing  the mean, standard deviation, 1st, 2nd and 3rd quantiles of
variable `var` by a selection of tuple of columns `bycolumns`. Weights are optional and if specified,
the function returns the weighted descriptive statistics.

For example `descriptive_stats(data,"income",(:age,:gender),weight="sampling_weights")` returns
the descriptive statistics of income from table `data` by the columns name `age` and `gender`, weighted by the
sampling weights `sampling_weights`
"""
function descriptive_stats(table,var::String,bycolumns::Tuple;weight="None")
    if weight=="None"
        y= groupby(@NT(
        MEAN=mean,
        STD=std,
        Q25=z->quantile(z,0.25),
        MEDIAN = median,
        Q75=z->quantile(z,0.25)
        ),
        table,bycolumns,select=Symbol(var))
    else
        y= groupby(@NT(
        MEAN=z->mean(column(z,Symbol(var)),weights(column(z,Symbol(weight)))),
        STD=z->std(column(z,Symbol(var)),weights(column(z,Symbol(weight))), corrected=false),
        Q25=z->quantile(column(z,Symbol(var)),0.25),
        MEDIAN=z->median(column(z,Symbol(var)),weights(column(z,Symbol(weight)))),
        Q75=z->quantile(column(z,Symbol(var)),0.75)
        ),
        table,bycolumns,select=(Symbol(var),Symbol(weight)))
    end
    return y
end

function descriptive_stats(table,var::String,bycolumn::Symbol;weight="None")
    if weight=="None"
        y= groupby(@NT(
        MEAN=mean,
        STD=std,
        Q25=z->quantile(z,0.25),
        MEDIAN = median,
        Q75=z->quantile(z,0.25)
        ),
        table,bycolumn,select=Symbol(var))
    else
        y= groupby(@NT(
        MEAN=z->mean(column(z,Symbol(var)),weights(column(z,Symbol(weight)))),
        STD=z->std(column(z,Symbol(var)),weights(column(z,Symbol(weight))), corrected=false),
        Q25=z->quantile(column(z,Symbol(var)),0.25),
        MEDIAN=z->median(column(z,Symbol(var)),weights(column(z,Symbol(weight)))),
        Q75=z->quantile(column(z,Symbol(var)),0.75)
        ),
        table,bycolumn,select=(Symbol(var),Symbol(weight)))
    end
    return y
end



function descriptive_stats(table,var::String,bycolumns::Tuple,Parent::String,extra::String;weight="None")
    if weight=="None"
        y= groupby(@NT(
        MEAN=mean,
        STD=std,
        Q25=z->quantile(z,0.25),
        MEDIAN = median,
        Q75=z->quantile(z,0.25)
        ),
        table,bycolumns,select=Symbol(var))
    else
        y= groupby(@NT(
        MEAN=z->mean(column(z,Symbol(var)),weights(column(z,Symbol(weight)))),
        STD=z->std(column(z,Symbol(var)),weights(column(z,Symbol(weight))), corrected=false),
        Q25=z->quantile(column(z,Symbol(var)),0.25),
        MEDIAN=z->median(column(z,Symbol(var)),weights(column(z,Symbol(weight)))),
        Q75=z->quantile(column(z,Symbol(var)),0.75)
        ),
        table,bycolumns,select=(Symbol(var),Symbol(weight)))
    end
    Name = var*"_by_"
    for i=1:size(bycolumns,1)
        Name = Name*"_"*String(bycolumns[i])
    end
        Name = Name*"_"*extra*".csv"
    save_csv(joinpath(Parent,Name),y)
    return y
end

function descriptive_stats(table,var::String,bycolumn::Symbol,Parent::String,extra::String;weight="None")
    if weight=="None"
        y= groupby(@NT(
        MEAN=mean,
        STD=std,
        Q25=z->quantile(z,0.25),
        MEDIAN = median,
        Q75=z->quantile(z,0.25)
        ),
        table,bycolumn,select=Symbol(var))
    else
        y= groupby(@NT(
        MEAN=z->mean(column(z,Symbol(var)),weights(column(z,Symbol(weight)))),
        STD=z->std(column(z,Symbol(var)),weights(column(z,Symbol(weight))), corrected=false),
        Q25=z->quantile(column(z,Symbol(var)),0.25),
        MEDIAN=z->median(column(z,Symbol(var)),weights(column(z,Symbol(weight)))),
        Q75=z->quantile(column(z,Symbol(var)),0.75)
        ),
        table,bycolumn,select=(Symbol(var),Symbol(weight)))
    end
    Name = var*"_by_"*String(bycolumn)*"_"*extra*".csv"

    save_csv(joinpath(Parent,Name),y)
    return y
end

function descriptive_stats(table,var::String,bycolumn::Symbol,Parent::String;weight="None")
    if weight=="None"
        y= groupby(@NT(
        MEAN=mean,
        STD=std,
        Q25=z->quantile(z,0.25),
        MEDIAN = median,
        Q75=z->quantile(z,0.25)
        ),
        table,bycolumn,select=Symbol(var))
    else
        y= groupby(@NT(
        MEAN=z->mean(column(z,Symbol(var)),weights(column(z,Symbol(weight)))),
        STD=z->std(column(z,Symbol(var)),weights(column(z,Symbol(weight))), corrected=false),
        Q25=z->quantile(column(z,Symbol(var)),0.25),
        MEDIAN=z->median(column(z,Symbol(var)),weights(column(z,Symbol(weight)))),
        Q75=z->quantile(column(z,Symbol(var)),0.75)
        ),
        table,bycolumn,select=(Symbol(var),Symbol(weight)))
    end
    Name = var*"_by_"*String(bycolumn)*".csv"
    save_csv(joinpath(Parent,Name),y)
    return y
end

function descriptive_stats(table,var::String,bycolumns::Tuple,Parent::String;weight="None")
    if weight=="None"
        y= groupby(@NT(
        MEAN=mean,
        STD=std,
        Q25=z->quantile(z,0.25),
        MEDIAN = median,
        Q75=z->quantile(z,0.25)
        ),
        table,bycolumns,select=Symbol(var))
    else
        y= groupby(@NT(
        MEAN=z->mean(column(z,Symbol(var)),weights(column(z,Symbol(weight)))),
        STD=z->std(column(z,Symbol(var)),weights(column(z,Symbol(weight))), corrected=false),
        Q25=z->quantile(column(z,Symbol(var)),0.25),
        MEDIAN=z->median(column(z,Symbol(var)),weights(column(z,Symbol(weight)))),
        Q75=z->quantile(column(z,Symbol(var)),0.75)
        ),
        table,bycolumns,select=(Symbol(var),Symbol(weight)))
    end
    Name = var*"_by_"
    for i=1:size(bycolumns,1)
            Name = Name*"_"*String(bycolumns[i])
    end
    Name = Name*".csv"
    save_csv(joinpath(Parent,Name),y)
    return y
end

"""
    save_csv(path::String,table::DNextTable)
Saves table as CSV at the specified path.
For example `save_csv("Folder\\data.csv",t)` saves the table `t` in the
subfolder `Folder` under the name `data.csv`
"""
function save_csv(path::String,t)
    open(path,"w") do fid
        println(fid,join(colnames(t),','))
        for i in collect(t)
            println(fid,join(i,','))
        end
    end
end
=#
