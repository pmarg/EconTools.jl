# Generic LaTeX Figure Generation Functions
# Functions for creating publication-ready PGFPlots figures

"""
    initialize_pgfplots()

Documentation function. PGFPlotsX setup (color definitions, cycle lists) is
automatically loaded when EconTools is imported via pgfplots_setup.jl.

# Available Cycle Lists

- `plot2`, `plot3`, `plot4`: General purpose 2-4 series
- `pgs3`: 3 PGS types (Low/Med/High)
- `edu2`: 2 education levels (HS/College)
- `grayscale`: 4 grayscale series with solid/dashed styles

# Colors Defined

- `airforceblue`: RGB(0.36, 0.54, 0.66)
- `amaranth`: RGB(0.9, 0.17, 0.31)
- `asparagus`: RGB(0.53, 0.66, 0.42)
- `cadmiumorange`: RGB(0.93, 0.53, 0.18)
- `color1-4`: Grayscale colors

# Usage

No action required - setup happens automatically at module load.
"""
initialize_pgfplots() = nothing

"""
    save_pgfplot(plot, filepath;
                 caption="",
                 label="",
                 notes=String[],
                 source="",
                 width="0.8\\\\textwidth",
                 height="0.5\\\\textwidth",
                 standalone=false)

Save a PGFPlots object as a LaTeX figure file.

# Arguments
- `plot`: PGFPlotsX plot object (Axis, GroupPlot, etc.)
- `filepath::String`: Full path including .tex extension
- `caption::String=""`: Figure caption
- `label::String=""`: LaTeX label (without fig: prefix)
- `notes::Vector{String}=[]`: Vector of note strings
- `source::String=""`: Source note (if provided, added as last note)
- `width::String="0.8\\\\textwidth"`: Figure width
- `height::String="0.5\\\\textwidth"`: Figure height
- `standalone::Bool=false`: If true, wraps in figure environment with caption/label

# Example
```julia
fig = @pgf Axis({xlabel="Age", ylabel="BMI"},
    Plot(Table([25, 30, 35], [28.5, 29.1, 29.8])))

save_pgfplot(
    fig, "paper/figures/bmi_age.tex",
    caption="BMI by Age",
    label="bmi_age",
    notes=["Sample restricted to working-age males."],
    source="HRS (1998-2018)",
    standalone=true
)
```
"""
function save_pgfplot(plot, filepath;
                     caption="",
                     label="",
                     notes=String[],
                     source="",
                     width="0.8\\\\textwidth",
                     height="0.5\\\\textwidth",
                     standalone=false)

    ## Build notes section
    all_notes = copy(notes)
    if !isempty(source)
        push!(all_notes, "\\emph{Source:} $source")
    end

    if standalone
        ## Full figure environment with caption, label, and notes
        ## First save the plot to a temp file, then embed in figure environment
        mktempdir() do tmpdir
            temp_plot_path = joinpath(tmpdir, "temp_plot.tex")
            pgfsave(temp_plot_path, plot, include_preamble=false)
            plot_content = read(temp_plot_path, String)

            open(filepath, "w") do io
                println(io, "\\begin{figure}[!htbp]")
                println(io, "\\centering")

                ## Write the plot content
                print(io, plot_content)

                println(io, "\\caption{$caption}\\label{fig:$label}")

                ## Add notes if provided
                if !isempty(all_notes)
                    println(io, "\\begin{minipage}{\\textwidth}")
                    println(io, "\\footnotesize")
                    for note in all_notes
                        if !occursin("\\emph", note)
                            println(io, "\\emph{Notes:} $note \\\\")
                        else
                            println(io, "$note \\\\")
                        end
                    end
                    println(io, "\\end{minipage}")
                end

                println(io, "\\end{figure}")
            end
        end
    else
        ## Just save the plot without figure environment (for \\input{} in main document)
        pgfsave(filepath, plot, include_preamble=false)
    end

    println("✓ Saved PGFPlot figure: $filepath")
    return filepath
end


"""
    save_pgfplot_simple(plot, filename, caption, label; kwargs...)

Simplified wrapper for save_pgfplot compatible with identification_summary.jl.

# Arguments
- `plot`: PGFPlotsX plot object
- `filename::String`: Filename without .tex extension
- `caption::String`: Figure caption
- `label::String`: LaTeX label (without fig: prefix)
- `width::String="0.8\\\\textwidth"`: Figure width
- `height::String="0.5\\\\textwidth"`: Figure height

# Example
```julia
save_pgfplot_simple(
    bmi_plot,
    "figure01_bmi_age_profiles",
    "BMI Age Profiles by PGS Type",
    "bmi_age_profiles",
    width="0.9\\\\textwidth"
)
```
"""
function save_pgfplot_simple(plot, filename, caption, label;
                            width="0.8\\\\textwidth",
                            height="0.5\\\\textwidth")
    if !endswith(filename, ".tex")
        filename = filename * ".tex"
    end

    save_pgfplot(
        plot, filename,
        caption=caption,
        label=label,
        width=width,
        height=height,
        standalone=false
    )
end


"""
    create_line_plot(x, y, labels;
                     xlabel="",
                     ylabel="",
                     title="",
                     legend_pos="north east",
                     cycle_list=nothing,
                     width="0.8\\\\textwidth",
                     height="0.5\\\\textwidth")

Create a simple line plot with PGFPlotsX.

# Arguments
- `x`: Vector or matrix of x values
- `y`: Vector or matrix of y values (if matrix, one series per column)
- `labels`: Vector of legend labels
- `xlabel::String=""`: X-axis label
- `ylabel::String=""`: Y-axis label
- `title::String=""`: Plot title
- `legend_pos::String="north east"`: Legend position
- `cycle_list::Union{Nothing,String}=nothing`: Color cycle list name (auto-selected if not provided)
- `width::String="0.8\\\\textwidth"`: Plot width
- `height::String="0.5\\\\textwidth"`: Plot height

# Returns
PGFPlotsX Axis object

# Example
```julia
ages = 25:5:65
bmi_low = [27.5, 28.2, 28.9, 29.4, 29.6, 29.5, 29.2, 28.8, 28.3]
bmi_high = [29.1, 30.0, 30.8, 31.4, 31.7, 31.6, 31.2, 30.6, 29.9]

fig = create_line_plot(
    ages, [bmi_low bmi_high],
    ["Low BMI PGS", "High BMI PGS"],
    xlabel="Age",
    ylabel="BMI",
    title="BMI Trajectories by PGS Type"
)
```
"""
function create_line_plot(x, y, labels;
                         xlabel="",
                         ylabel="",
                         title="",
                         legend_pos="north east",
                         cycle_list=nothing,  # Auto-select if not provided
                         width="0.8\\\\textwidth",
                         height="0.5\\\\textwidth")

    ## Determine number of series
    n_series = y isa AbstractMatrix ? size(y, 2) : 1

    ## Auto-select cycle list if not provided
    if isnothing(cycle_list)
        cycle_list = n_series == 1 ? "plot2" : "plot$min(n_series, 4)"
    end

    ## Handle matrix y (multiple series)
    plots = Any[]  # Use Any[] to allow mixed Plot and LegendEntry

    if y isa AbstractMatrix
        for i in 1:n_series
            push!(plots, Plot(Table(x, y[:, i])))
            if !isempty(labels) && i <= length(labels)
                push!(plots, LegendEntry(labels[i]))
            end
        end
    else
        push!(plots, Plot(Table(x, y)))
        if !isempty(labels) && length(labels) >= 1
            push!(plots, LegendEntry(labels[1]))
        end
    end

    ## Build axis options (conditionally include title)
    if !isempty(title)
        axis_options = @pgf {
            width = width,
            height = height,
            xlabel = xlabel,
            ylabel = ylabel,
            title = title,
            legend_pos = legend_pos,
            cycle_list_name = cycle_list,
        }
    else
        axis_options = @pgf {
            width = width,
            height = height,
            xlabel = xlabel,
            ylabel = ylabel,
            legend_pos = legend_pos,
            cycle_list_name = cycle_list,
        }
    end

    return @pgf Axis(axis_options, plots...)
end

# PGFPlotsX Wrapper Functions
# Functions for creating publication-ready LaTeX plots

"""
    pgfplot(ys...;
            Legend=String[],
            Label=("x","y"),
            Title="Figure",
            Path="NA",
            Width="0.6*\\\\textwidth",
            Legend_pos="outer north east",
            PDF=false,
            Xtick=false,
            Xticklabels=false)

Create and optionally save a PGFPlots line plot with 1-4 series.

Generates publication-ready line plots using PGFPlotsX with automatic color cycling.
Supports saving as .tex (and optionally .pdf) files for inclusion in LaTeX documents.

# Arguments
- `ys...`: Variable number of y-value vectors (1-4 series supported)
- `Legend`: Vector of legend labels, tuple, or single string. Default: String[]
- `Label`: Tuple of (xlabel, ylabel). Default: ("x", "y")
- `Title`: Plot title. Default: "Figure"
- `Path`: Save path without extension, or "NA" to skip saving. Default: "NA"
- `Width`: Plot width in LaTeX units. Default: "0.6*\\\\textwidth"
- `Legend_pos`: Legend position. Default: "outer north east"
- `PDF`: If true, also save PDF version. Default: false
- `Xtick`: Custom x-tick values or false for automatic. Default: false
- `Xticklabels`: Custom x-tick labels or false for automatic. Default: false

# Returns
- PGFPlotsX Axis object (also displays plot)

# Example
```julia
using EconTools

# Single series
y1 = [1.0, 1.5, 2.0, 2.2, 2.3]
pgfplot(y1, Legend="GDP Growth", Title="Economic Growth", Path="output/growth")

# Multiple series
bmi_low = [27.5, 28.2, 28.9, 29.4, 29.6, 29.5]
bmi_high = [29.1, 30.0, 30.8, 31.4, 31.7, 31.6]

pgfplot(bmi_low, bmi_high,
        Legend=("Low BMI PGS", "High BMI PGS"),
        Label=("Age", "BMI"),
        Title="BMI Trajectories",
        Path="output/bmi_age",
        PDF=true)
```

# Notes
- PGFPlots setup is automatic (see `initialize_pgfplots()` for details)
- X-values are automatically 1:length(y) for each series
- Supports 1-4 series with automatic cycle list selection
- Creates directory for Path if it doesn't exist
"""
function pgfplot(ys...;
    Legend=String[],
    Label=("x", "y"),
    Title="Figure",
    Path="NA",
    Width="0.6*\\textwidth",
    Legend_pos="outer north east",
    PDF=false,
    Xtick=false,
    Xticklabels=false)

    n_series = length(ys)
    @assert 1 <= n_series <= 4 "pgfplot supports 1-4 series, got $n_series"

    ## Handle legend input (string, tuple, or vector)
    legend_vec = if Legend isa String
        [Legend]
    elseif Legend isa Tuple
        collect(Legend)
    else
        collect(Legend)
    end

    ## Auto-select cycle list based on number of series
    cycle_list = n_series == 1 ? "plot2" : "plot$n_series"

    ## Create x values (use first series length)
    x = 1:size(ys[1], 1)

    ## Build plot elements
    plot_elements = []
    for (i, y) in enumerate(ys)
        push!(plot_elements, Plot(Table(x, y)))
        if !isempty(legend_vec) && i <= length(legend_vec)
            push!(plot_elements, LegendEntry(legend_vec[i]))
        end
    end

    ## Build axis options
    axis_opts = Dict{Symbol,Any}(
        :xlabel => Label[1],
        :ylabel => Label[2],
        :title => Title,
        :width => Width,
        :legend_pos => Legend_pos,
        :cycle_list_name => cycle_list,
        :xmin => extrema(x)[1],
        :xmax => extrema(x)[2]
    )

    ## Add custom ticks if provided
    if Xtick !== false
        axis_opts[:xtick] = Xtick
        axis_opts[:xticklabels] = Xticklabels
    end

    ## Create plot
    p = @pgf Axis(axis_opts, plot_elements...)

    ## Save if requested
    if Path != "NA"
        ## Ensure directory exists
        dir = dirname(Path)
        if !isempty(dir) && !isdir(dir)
            mkpath(dir)
        end

        pgfsave(Path * ".tex", p, include_preamble=false)
        if PDF
            pgfsave(Path * ".pdf", p)
        end
    end

    return p
end
