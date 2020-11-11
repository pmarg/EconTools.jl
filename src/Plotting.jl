function pgfplot(y; leg = "y1", lab =("x","y"),tlt = "Figure")
    x = 1:size(y,1)
    p = @pgf Axis({
        xlabel = lab[1],
        ylabel = lab[2],
        title = tlt,
        width="0.6*\\textwidth",
        legend_pos="outer north east",
        cycle_list_name = "edu2",
        xmin = extrema(x)[1],
        xmax = extrema(x)[2],
        },
            PlotInc(Table([:x => x, :y => y])),
            LegendEntry(leg),
        )
    display("image/png",p)
end

function pgfplot(y1,y2; leg = ("y1","y2"), lab =("x","y"),tlt = "Figure", path = "NA")
    x1 = 1:size(y1,1)
    x2 = 1:size(y2,1)

    p = @pgf Axis({
        xlabel = lab[1],
        ylabel = lab[2],
        title = tlt,
        width="0.6*\\textwidth",
        legend_pos="outer north east",
        cycle_list_name = "edu2",
        xmin = extrema(x1)[1],
        xmax = extrema(x1)[2],

        },
            Plot(Table([:x => x1, :y => y1])),
            LegendEntry(leg[1]),
            Plot(Table([:x => x2, :y => y2])),
            LegendEntry(leg[2])
        )
        if path == "NA"
            display("image/png",p)
        else
            pgfsave(path, p, include_preamble = false)
        end
end

function pgfplot(y1,y2,y3; leg = ("y1","y2","y3"), lab =("x","y"),tlt = "Figure")
    x1 = 1:size(y1,1)
    x2 = 1:size(y2,1)
    x3 = 1:size(y3,1)
    p = @pgf Axis({
        xlabel = lab[1],
        ylabel = lab[2],
        title = tlt,
        width="0.6*\\textwidth",
        legend_pos="outer north east",
        cycle_list_name = "edu3",
        xmin = extrema(x1)[1],
        xmax = extrema(x1)[2],

        },
            PlotInc(Table([:x => x1, :y => y1])),
            LegendEntry(leg[1]),
            PlotInc(Table([:x => x2, :y => y2])),
            LegendEntry(leg[2]),
            PlotInc(Table([:x => x3, :y => y3])),
            LegendEntry(leg[3])
        )
    display("image/png",p)
end

function pgfplot(y1,y2,y3,y4; leg = ("y1","y2","y3","y4"), lab =("x","y"),tlt = "Figure")
    x1 = 1:size(y1,1)
    x2 = 1:size(y2,1)
    x3 = 1:size(y3,1)
    x4 = 1:size(y4,1)
    p = @pgf Axis({
        xlabel = lab[1],
        ylabel = lab[2],
        title = tlt,
        width="0.6*\\textwidth",
        legend_pos="outer north east",
        cycle_list_name = "edu4",
        xmin = extrema(x1)[1],
        xmax = extrema(x1)[2],
        },
            Plot(Table([:x => x1, :y => y1])),
            LegendEntry(leg[1]),
            Plot(Table([:x => x2, :y => y2])),
            LegendEntry(leg[2]),
            Plot(Table([:x => x3, :y => y3])),
            LegendEntry(leg[3]),
            Plot(Table([:x => x4, :y => y4])),
            LegendEntry(leg[4])
        )
    display("image/png",p)
end