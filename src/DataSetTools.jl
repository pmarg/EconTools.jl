
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
  if !isempty(categories)
    @assert num_intervals == length(categories) "Number of intervals must match the number of names."
    df[!, varname] = CategoricalArray(undef, nrow(df))
  else
    df[!, varname] .= 0 
  end

  

  for i in 1:nrow(df)
    for j in 1:num_intervals
      if j < num_intervals
        if df[i, var] >= intervals[j] && df[i, var] < intervals[j+1]
          if !isempty(categories)
            df[i, varname] = categories[j]
          else
            df[i, varname] = j
          end
          break
        end
      else
        if df[i, var] >= intervals[j]
          if topcoded
            if !isempty(categories)
              df[i, varname] = categories[num_intervals]
            else
              df[i, varname] = num_intervals
            end
          else
            df[i, varname] = -1
          end
        else
          df[i, varname] = 0
        end
      end
    end
  end

  if numerical_cat && !isempty(categories)
    df[!, varname] = levelcode.(df[!, varname])
  end
  return df
end