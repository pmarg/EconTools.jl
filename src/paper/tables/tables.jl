# Generic LaTeX Table Generation Functions
# Functions for creating publication-ready LaTeX tables with threeparttable formatting

"""
    save_latex_table(df, filepath;
                     caption="",
                     label="",
                     notes=String[],
                     source="",
                     format_cols=nothing,
                     col_align=nothing,
                     header_groups=nothing,
                     num_format="%.2f")

Save a DataFrame as a publication-ready LaTeX table with threeparttable formatting.

# Arguments
- `df::DataFrame`: Data to save
- `filepath::String`: Full path including .tex extension
- `caption::String=""`: Table caption
- `label::String=""`: LaTeX label (without tab: prefix)
- `notes::Vector{String}=[]`: Vector of note strings (e.g., ["Notes: Sample restricted...", "Source: HRS 2022"])
- `source::String=""`: Shorthand for source note (if provided, added as last note)
- `format_cols::Union{Nothing, Vector{Int}}=nothing`: Column indices to format as numbers
- `col_align::Union{Nothing, String}=nothing`: Custom column alignment (e.g., "lcccc"), defaults to left for first, center for rest
- `header_groups::Union{Nothing, Vector{NamedTuple}}=nothing`: For nested headers, vector of (label, span) tuples
- `num_format::String="%.2f"`: Printf format string for numeric columns

# Example
```julia
df = DataFrame(cluster=["Hot", "Neutral", "Cold"], hs=[29.31, 29.11, 28.48], college=[28.11, 27.45, 26.95])
save_latex_table(
    df, "paper/tables/bmi_cluster.tex",
    caption="BMI by Cluster and Education",
    label="bmi_cluster",
    notes=["Average BMI by cluster and education for working-age males."],
    source="CPS-ATUS (2010-2018)",
    format_cols=[2, 3]
)
```

# Example with nested headers
```julia
save_latex_table(
    df, "paper/tables/bmi_comparison.tex",
    caption="BMI by Cluster and Education",
    label="bmi_comparison",
    header_groups=[
        (label="High School", span=2),
        (label="College", span=2),
        (label="Average", span=2)
    ],
    notes=["Simulation results and data for average BMI."],
    source="Simulation results and CPS-ATUS (2010-2018)",
    format_cols=[2,3,4,5,6,7]
)
```
"""
function save_latex_table(df, filepath;
                         caption="",
                         label="",
                         notes=String[],
                         source="",
                         format_cols=nothing,
                         col_align=nothing,
                         header_groups=nothing,
                         num_format="%.2f")

    ncols = ncol(df)

    ## Default alignment: left for first column, center for rest
    if col_align === nothing
        col_align = "l" * repeat("c", ncols - 1)
    end

    ## Build notes section
    all_notes = copy(notes)
    if !isempty(source)
        push!(all_notes, "\\emph{Source:} $source")
    end

    open(filepath, "w") do io
        ## Table environment
        println(io, "\\begin{table}[!htbp]")
        println(io, "\\centering")
        println(io, "\\caption{$caption}\\label{tab:$label}")
        println(io, "\\begin{threeparttable}")

        ## Tabular with full width and extra column separation
        println(io, "\\begin{tabular*}{\\textwidth}{@{\\extracolsep{\\fill}}$col_align@{}}")
        println(io, "\\toprule[1pt]\\midrule[0.3pt]")

        ## Header groups (if nested headers)
        if header_groups !== nothing
            ## First header row: group labels with multicolumn
            header_line = ""
            pos = 2  # Start from column 2 (column 1 is row labels)
            for (i, group) in enumerate(header_groups)
                if i > 1
                    header_line *= " &"
                end
                header_line *= "\\multicolumn{$(group.span)}{c}{$(group.label)}"
                pos += group.span
            end
            println(io, "&$header_line \\\\ \\\\")

            ## cmidrule spanning the data columns (skip first column)
            cmidrule_start = 2
            cmidrule_end = sum(g.span for g in header_groups) + 1
            println(io, "\\cmidrule{$cmidrule_start-$cmidrule_end}")
        end

        ## Column headers
        headers = names(df)
        ## Capitalize and clean up header names
        headers_formatted = [replace(string(h), "_" => " ") |> titlecase for h in headers]
        if header_groups !== nothing
            ## For nested tables, skip first column name in subheader, print actual column names
            println(io, "&" * join(headers_formatted[2:end], " &"), " \\\\ \\\\")
        else
            println(io, join(headers_formatted, " &"), " \\\\")
        end
        println(io, "\\cmidrule{1-$ncols}")

        ## Data rows
        for row in eachrow(df)
            formatted_row = String[]
            for (i, val) in enumerate(row)
                if ismissing(val)
                    push!(formatted_row, "--")
                elseif format_cols !== nothing && i in format_cols
                    if val isa Number
                        push!(formatted_row, @eval @sprintf($num_format, $val))
                    else
                        push!(formatted_row, string(val))
                    end
                else
                    push!(formatted_row, string(val))
                end
            end
            println(io, join(formatted_row, " & "), " \\\\")
        end

        ## Bottom rules
        println(io, "\\midrule[0.3pt]\\bottomrule[1pt]")
        println(io, "\\end{tabular*}")

        ## Table notes
        if !isempty(all_notes)
            println(io, "\\begin{tablenotes}")
            for note in all_notes
                ## Check if note already has \emph formatting
                if !occursin("\\emph", note)
                    println(io, "\t\\item \\footnotesize \\emph{Notes:} $note")
                else
                    println(io, "\t\\item \\footnotesize $note")
                end
            end
            println(io, "\\end{tablenotes}")
        end

        println(io, "\\end{threeparttable}")
        println(io, "\\end{table}")
    end

    println("✓ Saved LaTeX table: $filepath")
    return filepath
end


"""
    save_latex_table_simple(df, filepath, caption, label; kwargs...)

Simplified wrapper for save_latex_table with fewer required arguments.
Compatible with the identification_summary.jl code.

# Arguments
- `df::DataFrame`: Data to save
- `filepath::String`: Filename without .tex extension (directory determined by context)
- `caption::String`: Table caption
- `label::String`: LaTeX label (without tab: prefix)
- `format_cols::Union{Nothing, Vector{Int}}=nothing`: Columns to format as numbers

# Example
```julia
save_latex_table_simple(
    moment1,
    "table01_bmi_wealth_correlation",
    "BMI-Wealth Correlation Within PGS Type",
    "bmi_wealth_corr",
    format_cols=[3, 4, 5]
)
```
"""
function save_latex_table_simple(df, filename, caption, label; format_cols=nothing, num_format="%.3f")
    ## For backward compatibility with identification_summary.jl
    ## This assumes the calling code sets up the directory path
    if !endswith(filename, ".tex")
        filename = filename * ".tex"
    end

    save_latex_table(
        df, filename,
        caption=caption,
        label=label,
        format_cols=format_cols,
        num_format=num_format
    )
end


"""
    format_number(x; decimals=2, thousands_sep=true)

Format a number for LaTeX tables with optional thousands separator.

# Example
```julia
format_number(1234.567, decimals=2)  # "1,234.57"
format_number(0.12345, decimals=4)   # "0.1235"
```
"""
function format_number(x; decimals=2, thousands_sep=true)
    if ismissing(x)
        return "--"
    end

    formatted = @eval @sprintf($"%.$(decimals)f", $x)

    if thousands_sep && abs(x) >= 1000
        ## Add thousands separator
        parts = split(formatted, ".")
        integer_part = parts[1]
        decimal_part = length(parts) > 1 ? "." * parts[2] : ""

        ## Insert commas
        chars = collect(integer_part)
        n = length(chars)
        result = String[]
        for (i, c) in enumerate(chars)
            push!(result, string(c))
            if (n - i) % 3 == 0 && i != n
                push!(result, ",")
            end
        end
        return join(result) * decimal_part
    end

    return formatted
end
