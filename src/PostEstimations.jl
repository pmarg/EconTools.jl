function df_means(data::DataFrame, by, wt::Symbol, path::String)
    gdf = groupby(data, by)
    df = combine(gdf, nrow, vcat.(valuecols(gdf), wt) .=> [(x, w) -> mean(x, weights(w))])
    rename!(df, names(df)[3:end] .=> valuecols(gdf))
    writeGzip(df, path)
end

function df_means(data::DataFrame, by, path::String)
    gdf = groupby(data, by)
    df = combine(gdf, nrow, vcat.(valuecols(gdf)) .=> [x -> mean(x)])
    rename!(df, names(df)[3:end] .=> valuecols(gdf))
    writeGzip(df, path)
end

function df_vars(data::DataFrame, by, path::String)
    gdf = groupby(data, by)
    df = combine(gdf, nrow, vcat.(valuecols(gdf)) .=> [x -> var(x)])
    rename!(df, names(df)[3:end] .=> valuecols(gdf))
    writeGzip(df, path)
end

function df_vars(data::DataFrame, by, wt::Symbol, path::String)
    gdf = groupby(data, by)
    df = combine(gdf, nrow, vcat.(valuecols(gdf), wt) .=> [(x, w) -> var(x, weights(w))])
    rename!(df, names(df)[3:end] .=> valuecols(gdf))
    writeGzip(df, path)
end

function df_medians(data::DataFrame, by, path::String)
    gdf = groupby(data, by)
    df = combine(gdf, nrow, vcat.(valuecols(gdf)) .=> [x -> median(x)])
    rename!(df, names(df)[3:end] .=> valuecols(gdf))
    writeGzip(df, path)
end

function df_medians(data::DataFrame, by, wt::Symbol, path::String)
    gdf = groupby(data, by)
    df = combine(gdf, nrow, vcat.(valuecols(gdf), wt) .=> [(x, w) -> median(x, weights(w))])
    rename!(df, names(df)[3:end] .=> valuecols(gdf))
    writeGzip(df, path)
end

function df_quantiles(data::DataFrame, by, p, path::String)
    gdf = groupby(data, by)
    df = combine(gdf, nrow, vcat.(valuecols(gdf)) .=> [x -> quantile(x,p)])
    rename!(df, names(df)[3:end] .=> valuecols(gdf))
    writeGzip(df, path)
end

function df_quantiles(data::DataFrame, by, wt::Symbol,p, path::String)
    gdf = groupby(data, by)
    df = combine(gdf, nrow, vcat.(valuecols(gdf), wt) .=> [(x, w) -> quantile(x, weights(w),p)])
    rename!(df, names(df)[3:end] .=> valuecols(gdf))
    writeGzip(df, path)
end