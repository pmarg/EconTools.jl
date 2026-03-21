
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
    assign_groups!(df, var, varname, intervals; categories=[], topcoded=true, numerical_cat=true)

Function that assigns observations to groups based on the intervals provided. The intervals are inclusive on the left and exclusive on the right. The function can also assign names to the groups.

# Examples
```julia-repl
temp = DataFrame(age=[25, 32, 40, 55])
assign_groups(temp, :age, :agegroup5, (25:5:90))
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
# Compute and save grouped statistics from DataFrames
import Statistics: mean, var, median, quantile, quantile, std

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