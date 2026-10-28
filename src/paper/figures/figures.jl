# Generic LaTeX Figure Generation Functions
# Functions for creating publication-ready PGFPlots figures

"""
    initialize_pgfplots() -> nothing

Documentation function. PGFPlotsX setup (color definitions, cycle lists) is added to
`PGFPlotsX.CUSTOM_PREAMBLE` when EconTools is loaded (pgfplots_setup.jl).

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
                 standalone=false) -> String

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

# Returns
- `String`: the path of the written `.tex` file.

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
    save_pgfplot_simple(plot, filename, caption, label; kwargs...) -> String

Simplified wrapper for save_pgfplot compatible with identification_summary.jl.

# Arguments
- `plot`: PGFPlotsX plot object
- `filename::String`: Filename without .tex extension
- `caption::String`: Figure caption
- `label::String`: LaTeX label (without fig: prefix)
- `width::String="0.8\\\\textwidth"`: Figure width
- `height::String="0.5\\\\textwidth"`: Figure height

# Returns
- `String`: the path of the written `.tex` file.

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

# House-style line plots: plain very thick lines without markers, no grid, the palette
# below, legend centered below the figure. Colors are defined in pgfplots_pre.

"""Line colors in order: airforceblue, cadmiumorange, asparagus, amaranth (pgfplots_pre)."""
const PALETTE = ["airforceblue", "cadmiumorange", "asparagus", "amaranth"]

"""Color of data series in data-vs-model plots (`PALETTE[1]`)."""
const DATA_COLOR = PALETTE[1]

"""Color of model series in data-vs-model plots (`PALETTE[2]`)."""
const MODEL_COLOR = PALETTE[2]

## Series i's x values: a shared vector, or one vector per series
series_x(x, i) = eltype(x) <: AbstractVector ? x[i] : x

## Axis option keys from keywords: underscores become spaces (x_tick_label_style → "x tick label style")
option_key(k::Symbol) = replace(string(k), "_" => " ")

function series_plots(x, ys, labels, colors)
    plots = Any[]
    for (i, y) in enumerate(ys)
        push!(plots, @pgf PlotInc({no_marks, very_thick, color = colors[i]}, Coordinates(series_x(x, i), y)))
        isempty(labels) || push!(plots, LegendEntry(labels[i]))
    end
    return plots
end

"""
    line_plot(x, ys; labels=String[], xlabel="", ylabel="", colors=PALETTE,
              width="0.6*\\\\textwidth", height=nothing, legend_columns=length(ys),
              legend_y=-0.25, options...) -> Axis

Single axis with one line per element of `ys`, in the house style: no markers, very
thick lines, no grid, `colors[i]` for series i, legend centered below the axis.

# Arguments
- `x`: x values shared by all series, or a vector with one x vector per series (e.g.
  data and model observed at different ages).
- `ys`: vector of y vectors, one per series.
- `labels`: legend entries, one per series; empty for no legend.
- `colors`: colors defined in `pgfplots_pre` (`PALETTE`, `DATA_COLOR`, `MODEL_COLOR`).
- `width`, `height`: axis size (the axis box itself: `scale only axis`); `height`
  `nothing` keeps the pgfplots aspect ratio.
- `legend_columns`: entries per legend row.
- `legend_y`: legend's vertical position as a fraction of the axis height below its
  bottom edge (more negative with rotated tick labels).
- `options...`: any other axis option, underscores for spaces (`ymin=0`, `title="HS"`,
  `xtick=[20, 30, 40]`, `x_tick_label_style="{rotate=45}"`).

# Example
```julia
ax = line_plot([ages_data, ages_model], [lfp_data, lfp_model];
               labels=["Data", "Model"], xlabel="Age", ylabel="LFP (\\\\%)", ymin=0)
save_figure(ax, "figures/lfp_age")
```
"""
function line_plot(x, ys; labels=String[], xlabel="", ylabel="", colors=PALETTE,
                   width="0.6*\\textwidth", height=nothing, legend_columns=length(ys),
                   legend_y=-0.25, options...)
    @assert isempty(labels) || length(labels) == length(ys) "one label per series"
    @assert length(colors) >= length(ys) "$(length(ys)) series but $(length(colors)) colors"
    ax = @pgf Axis({
        xlabel = xlabel,
        ylabel = ylabel,
        width = width,
        scale_only_axis,
        legend_style = {at = Coordinate(0.5, legend_y), anchor = "north", legend_columns = legend_columns, draw = "none"},
    }, series_plots(x, ys, labels, colors)...)
    isnothing(height) || (ax["height"] = height)
    for (k, v) in options
        ax[option_key(k)] = v
    end
    return ax
end

"""
    group_line_plot(panels; layout=(1, length(panels)), titles=String[], labels=String[],
                    xlabel="", ylabel="", colors=PALETTE, width="0.3*\\\\textwidth",
                    height=nothing, horizontal_sep="44pt", vertical_sep="50pt",
                    legend_columns=nothing, options...) -> TikzPicture

Grid of axes with the same series in each, in the house style of `line_plot`. The x
label is shown on the bottom row only, the y label on the left column only, and one
legend is centered below the whole figure, under the bottom row's tick and axis labels
(pgfplots `legend to name`, placed by a node after the group plot).

# Arguments
- `panels`: vector of `(x, ys)` tuples, one per panel, filled row by row; `x` and `ys`
  as in `line_plot`. Every panel has the same series in the same order.
- `layout`: `(rows, columns)`.
- `titles`: one title per panel; empty for none.
- `labels`: legend entries, one per series.
- `width`, `height`: size of each axis box (`scale only axis`).
- `horizontal_sep`, `vertical_sep`: gaps between axis boxes.
- `legend_columns`: entries per legend row (default: all series in one row).
- `options...`: axis options applied to every panel, underscores for spaces
  (`ymin=0`, `xtick=[1, 5, 10]`, `xticklabels=["18", "26", "36"]`,
  `x_tick_label_style="{rotate=45}"`).

# Example
```julia
gp = group_line_plot([(ages, [hs_data, hs_model]), (ages, [col_data, col_model])];
                     titles=["High School", "College"], labels=["Data", "Model"],
                     xlabel="Age", ylabel="LFP (\\\\%)", ymin=0)
save_figure(gp, "figures/lfp_age_by_edu")
```
"""
function group_line_plot(panels; layout=(1, length(panels)), titles=String[], labels=String[],
                         xlabel="", ylabel="", colors=PALETTE, width="0.3*\\textwidth",
                         height=nothing, horizontal_sep="44pt", vertical_sep="50pt",
                         legend_columns=nothing, options...)
    rows, cols = layout
    @assert rows * cols == length(panels) "layout $layout does not hold $(length(panels)) panels"
    @assert isempty(titles) || length(titles) == length(panels) "one title per panel"
    n_series = length(panels[1][2])
    @assert all(length(p[2]) == n_series for p in panels) "every panel needs the same series"
    @assert isempty(labels) || length(labels) == n_series "one label per series"
    @assert length(colors) >= n_series "$n_series series but $(length(colors)) colors"

    gp = @pgf GroupPlot({
        group_style = {group_size = "$cols by $rows", horizontal_sep = horizontal_sep, vertical_sep = vertical_sep},
        scale_only_axis,
        no_markers,  # also in the named legend, which ignores the plots' no marks
        width = width,
    })
    isnothing(height) || (gp.options["height"] = height)
    for (k, v) in options
        gp.options[option_key(k)] = v
    end

    legend_panel = (rows - 1) * cols + 1  # bottom-left
    ## Unique per figure, as legend names are global in a LaTeX document
    legend_name = "legend" * string(hash((panels, titles, labels, xlabel, ylabel)), base=36)
    for (k, (x, ys)) in enumerate(panels)
        row, col = divrem(k - 1, cols) .+ 1
        opts = @pgf {}
        isempty(titles) || (opts["title"] = titles[k])
        row == rows && (opts["xlabel"] = xlabel)
        col == 1 && (opts["ylabel"] = ylabel)
        show_legend = k == legend_panel && !isempty(labels)
        if show_legend
            opts["legend to name"] = legend_name
            opts["legend style"] = @pgf {legend_columns = something(legend_columns, n_series), draw = "none"}
        end
        push!(gp, opts, series_plots(x, ys, show_legend ? labels : String[], colors)...)
    end
    isempty(labels) && return TikzPicture(gp)
    ## Legend node: horizontally at the center of the bottom row of axis boxes (the
    ## bottom-left box's center plus (cols - 1)/2 box widths and gaps), vertically below
    ## that box's outer edge (tick labels and x label included)
    node = "\\node[anchor=north, yshift=-2pt, xshift={$((cols - 1) / 2)*$width+$((cols - 1) / 2)*$horizontal_sep}] " *
           "at (group c1r$rows.south |- group c1r$rows.outer south) {\\pgfplotslegendfromname{$legend_name}};"
    return TikzPicture(gp, node)
end

"""
    save_figure(fig, path)

Save an `Axis`, `GroupPlot` or `TikzPicture` as `path.tex` (a tikzpicture without preamble, for
`\\\\input`) and `path.pdf` (compiled with `pgfplots_pre`). A `.tex` or `.pdf` extension
on `path` is ignored; the directory is created if needed.
"""
function save_figure(fig, path::AbstractString)
    base, ext = splitext(path)
    ext in (".tex", ".pdf") || (base = path)
    mkpath(dirname(abspath(base)))
    pic = fig isa TikzPicture ? fig : TikzPicture(fig)
    pgfsave(base * ".tex", pic; include_preamble=false)
    pgfsave(base * ".pdf", TikzDocument(pic))
    return nothing
end
