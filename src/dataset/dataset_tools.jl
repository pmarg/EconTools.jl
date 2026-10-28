
"""
    pivot_longer(df, bycol, cols; period=:Period, separator=true) -> DataFrame

Reshape a wide panel, with one column per variable and year such as `income1990`,
`income1992`, into long format with one row per `bycol` × period.

For each stem in `cols`, every column whose name matches `<stem><digits>` is stacked:
the digits become the period and the values a column named after the stem. The
stems are then joined on `[bycol, period]` (outer join, so unbalanced panels are kept).

# Arguments
- `df::AbstractDataFrame`: wide data.
- `bycol::Symbol`: identifier column, copied to every row (e.g. `:id`).
- `cols::Vector{Symbol}`: variable stems to reshape (e.g. `[:income, :bmi]`).

# Keywords
- `period::Symbol=:Period`: name of the period column in the result. Periods are
  `String`s (the digits of the original column names).
- `separator::Bool=true`: currently has no effect; both settings use the pattern
  `<stem><digits>`.

# Returns
- `DataFrame` with columns `bycol`, `period` and one column per stem, or `nothing` if
  no stem could be reshaped. A stem that fails is skipped with a warning.

# Examples
```julia
wide = DataFrame(id=[1, 2], income1990=[10, 20], income1992=[11, 21])
pivot_longer(wide, :id, [:income]; period=:year)
# 4×3 DataFrame: id, year ("1990", "1992"), income
```
"""
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


"""
    reshape_results!(mc, D) -> DataFrame

Convert a simulation results struct into a long `DataFrame` with one column per field.

Every field of `mc` must be an `N × J` array (agents × ages); each is flattened with
`vec` (column-major), so row `(j - 1) * N + i` holds agent `i` at age `j`.

# Arguments
- `mc`: struct whose fields are all `D.N × D.J` arrays (e.g. Monte Carlo output).
- `D`: any object with fields `N` (number of agents) and `J` (number of ages).

# Returns
- `DataFrame` with `D.N * D.J` rows and one column per field of `mc`, in field order.

Despite the `!`, `mc` is not modified.
"""
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



"""
    create_age_groups(start_age, end_age, interval) -> Vector{Tuple}

Split the ages `start_age:end_age` into consecutive groups of `interval` years.

# Returns
- Vector of `(first_age, last_age)` tuples, both inclusive. The last group is cut at
  `end_age` if the range does not divide evenly.

# Examples
```julia
create_age_groups(25, 36, 5)  # [(25, 29), (30, 34), (35, 36)]
```

See also [`assign_age_groups`](@ref), [`assign_groups!`](@ref).
"""
function create_age_groups(start_age, end_age, interval)
  age_groups = []
  current_age = start_age
  while current_age <= end_age
    group_end_age = current_age + interval - 1
    if group_end_age > end_age
      group_end_age = end_age
    end
    group = (current_age, group_end_age)
    push!(age_groups, group)
    current_age += interval
  end
  return age_groups
end

"""
    assign_age_groups(df, age, name, start_age, end_age, interval) -> DataFrame

Add a categorical column `name` to `df` labelling each row's age group as `"first-last"`
(e.g. `"25-29"`), using the groups of [`create_age_groups`](@ref).

# Arguments
- `df::DataFrame`: data, modified in place.
- `age::Symbol`: age column.
- `name::Symbol`: new column to create.
- `start_age`, `end_age`, `interval`: passed to `create_age_groups`.

# Returns
- `df`, with the new column. Rows whose age falls outside `start_age:end_age` get
  `missing`.
"""
function assign_age_groups(df, age, name, start_age, end_age, interval)
  age_groups = create_age_groups(start_age, end_age, interval)
  df[!, name] = CategoricalArray(undef, nrow(df))

  for i in 1:nrow(df)
    for group in age_groups
      if df[i, age] >= group[1] && df[i, age] <= group[2]
        df[i, name] = "$(group[1])-$(group[2])"
        break
      end
    end
  end

  return df
end


"""
    assign_groups!(df, var, varname, intervals; categories=[], topcoded=true, numerical_cat=true) -> DataFrame

Assign each row of `df` to a group by the value of `var`, using the thresholds in
`intervals`, and store the group in a new column `varname`.

Group `j` is `intervals[j] ≤ x < intervals[j+1]` (closed on the left, open on the
right). Values at or above the last threshold form the last group.

# Arguments
- `df::DataFrame`: data, modified in place.
- `var::Symbol`: column to group by.
- `varname::Symbol`: new column to create.
- `intervals`: increasing thresholds (e.g. `25:5:90`).

# Keywords
- `categories=[]`: optional group names, one per threshold. Without names, groups are
  the integers `1:length(intervals)`.
- `topcoded::Bool=true`: if `true`, values `≥ intervals[end]` get the last group; if
  `false`, they get `-1` (or `missing` with `categories`).
- `numerical_cat::Bool=true`: with `categories`, replace the names by their categorical
  level codes. Levels are the sorted names, so codes follow alphabetical order, not
  the order of `intervals`.

# Returns
- `df`, with the new column. Values below `intervals[1]` get `0` (or `missing` with
  `categories`).

# Examples
```julia
df = DataFrame(age=[25, 32, 40, 95])
assign_groups!(df, :age, :agegroup5, 25:5:90)
df.agegroup5  # [1, 2, 4, 14]: 95 is top-coded into the last group (90+)
```
"""
function assign_groups!(df, var, varname, intervals; categories=[], topcoded=true, numerical_cat=true)
  num_intervals = length(intervals)

  # Initialize column based on whether categories are provided
  if !isempty(categories)
    @assert num_intervals == length(categories) "Number of intervals must match the number of names."
    # Initialize with missing values for CategoricalArray
    df[!, varname] = Vector{Union{String, Missing}}(missing, nrow(df))
  else
    df[!, varname] .= 0
  end

  for i in 1:nrow(df)
    assigned = false
    for j in 1:num_intervals
      if j < num_intervals
        if df[i, var] >= intervals[j] && df[i, var] < intervals[j+1]
          if !isempty(categories)
            df[i, varname] = categories[j]
          else
            df[i, varname] = j
          end
          assigned = true
          break
        end
      else
        # Last interval - check if value is >= last threshold
        if df[i, var] >= intervals[j]
          if topcoded
            if !isempty(categories)
              df[i, varname] = categories[num_intervals]
            else
              df[i, varname] = num_intervals
            end
          else
            if !isempty(categories)
              df[i, varname] = missing  # For categorical, use missing
            else
              df[i, varname] = -1
            end
          end
          assigned = true
        end
      end
    end

    # Handle values below first threshold
    if !assigned
      if !isempty(categories)
        df[i, varname] = missing  # Use missing for categorical
      else
        df[i, varname] = 0
      end
    end
  end

  # Convert to categorical and optionally to numerical codes
  if !isempty(categories)
    df[!, varname] = categorical(df[!, varname])
    if numerical_cat
      df[!, varname] = levelcode.(df[!, varname])
    end
  end

  return df
end

# Post-Estimation Analysis Functions
# Methods of the Statistics functions for a DataFrame column, optionally weighted and
# by group. They extend Statistics.mean etc., so they are available wherever
# Statistics is loaded.
import Statistics: mean, var, median, quantile, std

"""
    mean(df::DataFrame, value_col::Symbol; by=nothing, w=nothing, skipmissing=false)

Mean of `df[!, value_col]`, optionally weighted and by group.

# Arguments
- `df::DataFrame`: data.
- `value_col::Symbol`: column to summarize.

# Keywords
- `by=nothing`: grouping column (`Symbol`) or columns (`Vector{Symbol}`).
- `w=nothing`: column of frequency weights (`StatsBase.fweights`).
- `skipmissing::Bool=false`: drop missing values of `value_col` (and their weights).

# Returns
- Without `by`: a number.
- With `by`: a `DataFrame` with the grouping column(s) and the statistic in a column
  named `value_col`.

# Examples
```julia
mean(df, :bmi)                                  # overall mean
mean(df, :income, by=:education, w=:weight)     # weighted mean by education
mean(df, :hours, by=[:edu, :age_group], skipmissing=true)
```
"""
function mean(df::DataFrame, value_col::Symbol; by::Union{Nothing,Symbol,Vector{Symbol}}=nothing, w::Union{Nothing,Symbol}=nothing, skipmissing::Bool=false)
  if isnothing(by)
    if isnothing(w)
      return skipmissing ? mean(Base.skipmissing(df[!, value_col])) : mean(df[!, value_col])
    else
      if skipmissing
        # Filter out missing values from both data and weights
        valid_idx = .!ismissing.(df[!, value_col])
        return mean(df[valid_idx, value_col], fweights(df[valid_idx, w]))
      else
        return mean(df[!, value_col], fweights(df[!, w]))
      end
    end
  else
    grouped = groupby(df, by)
    if isnothing(w)
      if skipmissing
        result = combine(grouped, value_col => (x -> mean(Base.skipmissing(x))) => value_col)
      else
        result = combine(grouped, value_col => mean => value_col)
      end
    else
      if skipmissing
        result = combine(grouped, [value_col, w] => ((x, w) -> begin
          valid_idx = .!ismissing.(x)
          mean(x[valid_idx], fweights(w[valid_idx]))
        end) => value_col)
      else
        result = combine(grouped, [value_col, w] => ((x, w) -> mean(x, fweights(w))) => value_col)
      end
    end
    return result
  end
end

"""
    var(df::DataFrame, value_col::Symbol; by=nothing, w=nothing, skipmissing=false)

Variance of `df[!, value_col]`, optionally weighted and by group. Weighted variances
use `StatsBase`'s frequency-weight formula.

# Arguments
- `df::DataFrame`: data.
- `value_col::Symbol`: column to summarize.

# Keywords
- `by=nothing`: grouping column (`Symbol`) or columns (`Vector{Symbol}`).
- `w=nothing`: column of frequency weights (`StatsBase.fweights`).
- `skipmissing::Bool=false`: drop missing values of `value_col` (and their weights).

# Returns
- Without `by`: a number.
- With `by`: a `DataFrame` with the grouping column(s) and the statistic in a column
  named `value_col`.

See also [`std`](@ref).
"""
function var(df::DataFrame, value_col::Symbol; by::Union{Nothing,Symbol,Vector{Symbol}}=nothing, w::Union{Nothing,Symbol}=nothing, skipmissing::Bool=false)
  if isnothing(by)
    if isnothing(w)
      return skipmissing ? var(Base.skipmissing(df[!, value_col])) : var(df[!, value_col])
    else
      if skipmissing
        valid_idx = .!ismissing.(df[!, value_col])
        return var(df[valid_idx, value_col], fweights(df[valid_idx, w]))
      else
        return var(df[!, value_col], fweights(df[!, w]))
      end
    end
  else
    grouped = groupby(df, by)
    if isnothing(w)
      if skipmissing
        result = combine(grouped, value_col => (x -> var(Base.skipmissing(x))) => value_col)
      else
        result = combine(grouped, value_col => var => value_col)
      end
    else
      if skipmissing
        result = combine(grouped, [value_col, w] => ((x, w) -> begin
          valid_idx = .!ismissing.(x)
          var(x[valid_idx], fweights(w[valid_idx]))
        end) => value_col)
      else
        result = combine(grouped, [value_col, w] => ((x, w) -> var(x, fweights(w))) => value_col)
      end
    end
    return result
  end
end

"""
    median(df::DataFrame, value_col::Symbol; by=nothing, w=nothing, skipmissing=false)

Median of `df[!, value_col]`, optionally by group.

Weights are not supported: with `w` and no `by`, a warning is issued and the
unweighted median returned; with `by`, `w` is ignored.

# Arguments
- `df::DataFrame`: data.
- `value_col::Symbol`: column to summarize.

# Keywords
- `by=nothing`: grouping column (`Symbol`) or columns (`Vector{Symbol}`).
- `w=nothing`: ignored (see above).
- `skipmissing::Bool=false`: drop missing values of `value_col`.

# Returns
- Without `by`: a number.
- With `by`: a `DataFrame` with the median in a column named `value_col`. Unlike the
  other methods, the grouping column is renamed `types` (or `types_<col>` for each
  column when `by` is a vector).
"""
function median(df::DataFrame, value_col::Symbol; by::Union{Nothing,Symbol,Vector{Symbol}}=nothing, w::Union{Nothing,Symbol}=nothing, skipmissing::Bool=false)
  if isnothing(by)
    if isnothing(w)
      return skipmissing ? median(Base.skipmissing(df[!, value_col])) : median(df[!, value_col])
    else
      @warn "Weighted median not implemented. Returning unweighted median."
      return skipmissing ? median(Base.skipmissing(df[!, value_col])) : median(df[!, value_col])
    end
  else
    grouped = groupby(df, by)
    if skipmissing
      result = combine(grouped, value_col => (x -> median(Base.skipmissing(x))) => value_col)
    else
      result = combine(grouped, value_col => median => value_col)
    end
    if isa(by, Symbol)
      rename!(result, by => "types")
    else
      for col in by
        rename!(result, col => "types_$(col)")
      end
    end
    return result
  end
end


"""
    quantile(df::DataFrame, value_col::Symbol, q::Float64; by=nothing, w=nothing, skipmissing=false)

Quantile `q` (between 0 and 1) of `df[!, value_col]`, optionally weighted and by group.
Weighted quantiles use `StatsBase.weights`.

# Arguments
- `df::DataFrame`: data.
- `value_col::Symbol`: column to summarize.
- `q::Float64`: probability, e.g. `0.25` for the first quartile.

# Keywords
- `by=nothing`: grouping column (`Symbol`) or columns (`Vector{Symbol}`).
- `w=nothing`: column of weights.
- `skipmissing::Bool=false`: drop missing values of `value_col` (and their weights).

# Returns
- Without `by`: a number.
- With `by`: a `DataFrame` with the grouping column(s) and the statistic in a column
  named `value_col`.

# Examples
```julia
quantile(df, :assets, 0.25, by=:edu, w=:weight)
```
"""
function quantile(df::DataFrame, value_col::Symbol, q::Float64; by::Union{Nothing,Symbol,Vector{Symbol}}=nothing, w::Union{Nothing,Symbol}=nothing, skipmissing::Bool=false)
  if isnothing(by)
    if isnothing(w)
      data = skipmissing ? Base.skipmissing(df[!, value_col]) : df[!, value_col]
      return quantile(data, q)
    else
      if skipmissing
        valid_idx = .!ismissing.(df[!, value_col])
        return quantile(df[valid_idx, value_col], weights(df[valid_idx, w]), q)
      else
        return quantile(df[!, value_col], weights(df[!, w]), q)
      end
    end
  else
    grouped = groupby(df, by)
    if isnothing(w)
      if skipmissing
        result = combine(grouped, value_col => (x -> quantile(Base.skipmissing(x), q)))
      else
        result = combine(grouped, value_col => x -> quantile(x, q))
      end
      rename!(result, Symbol("$(value_col)_function") => value_col)
    else
      if skipmissing
        result = combine(grouped, [value_col, w] => ((x, w) -> begin
          valid_idx = .!ismissing.(x)
          quantile(x[valid_idx], weights(w[valid_idx]), q)
        end))
      else
        result = combine(grouped, [value_col, w] => ((x, w) -> quantile(x, weights(w), q)))
      end
      rename!(result, Symbol("$(value_col)_$(w)_function") => value_col)
    end
    return result
  end
end

"""
    std(df::DataFrame, value_col::Symbol; by=nothing, w=nothing, skipmissing=false)

Standard deviation of `df[!, value_col]`, optionally weighted and by group. Weighted
values use `StatsBase`'s frequency-weight formula.

# Arguments
- `df::DataFrame`: data.
- `value_col::Symbol`: column to summarize.

# Keywords
- `by=nothing`: grouping column (`Symbol`) or columns (`Vector{Symbol}`).
- `w=nothing`: column of frequency weights (`StatsBase.fweights`).
- `skipmissing::Bool=false`: drop missing values of `value_col` (and their weights).

# Returns
- Without `by`: a number.
- With `by`: a `DataFrame` with the grouping column(s) and the statistic in a column
  named `value_col`.

See also [`var`](@ref).
"""
function std(df::DataFrame, value_col::Symbol; by::Union{Nothing,Symbol,Vector{Symbol}}=nothing, w::Union{Nothing,Symbol}=nothing, skipmissing::Bool=false)
  if isnothing(by)
    if isnothing(w)
      return skipmissing ? std(Base.skipmissing(df[!, value_col])) : std(df[!, value_col])
    else
      if skipmissing
        valid_idx = .!ismissing.(df[!, value_col])
        return std(df[valid_idx, value_col], fweights(df[valid_idx, w]))
      else
        return std(df[!, value_col], fweights(df[!, w]))
      end
    end
  else
    grouped = groupby(df, by)
    if isnothing(w)
      if skipmissing
        result = combine(grouped, value_col => (x -> std(Base.skipmissing(x))) => value_col)
      else
        result = combine(grouped, value_col => std => value_col)
      end
    else
      if skipmissing
        result = combine(grouped, [value_col, w] => ((x, w) -> begin
          valid_idx = .!ismissing.(x)
          std(x[valid_idx], fweights(w[valid_idx]))
        end) => value_col)
      else
        result = combine(grouped, [value_col, w] => ((x, w) -> std(x, fweights(w))) => value_col)
      end
    end
    return result
  end
end