function initialize_pgfplots()

    pgfplots_pre = "\\definecolor{airforceblue}{rgb}{0.36, 0.54, 0.66}
    \\definecolor{amaranth}{rgb}{0.9, 0.17, 0.31}
    \\definecolor{asparagus}{rgb}{0.53, 0.66, 0.42}
    \\definecolor{cadmiumorange}{rgb}{0.93, 0.53, 0.18}
    \\pgfplotscreateplotcyclelist{edu2}{%
    no marks,very thick,color = airforceblue\\\\%1
    no marks,very thick,color = cadmiumorange\\\\%2
    }
    \\pgfplotscreateplotcyclelist{edu3}{%
    no marks,very thick,color = airforceblue\\\\%1
    no marks,very thick,color = cadmiumorange\\\\%2
    no marks,very thick,color = asparagus\\\\%3
    }
    \\pgfplotscreateplotcyclelist{edu4}{%
    no marks,very thick,color = airforceblue\\\\%1
    no marks,very thick,color = cadmiumorange\\\\%2
    no marks,very thick,color = asparagus\\\\%3
    no marks,very thick,color = amaranth\\\\%4
    }"
    push!(PGFPlotsX.CUSTOM_PREAMBLE, pgfplots_pre)

end

function pgfplot(y; Legend = "y1", Label =("x","y"), Title = "Figure", Path = "NA", Width = "0.6*\\textwidth", Legend_pos = "outer north east", PDF = false )
    x = 1:size(y,1)
    p = @pgf Axis({
        xlabel = Label[1],
        ylabel = Label[2],
        title = Title,
        width = Width,
        legend_pos = Legend_pos,
        cycle_list_name = "edu2",
        xmin = extrema(x)[1],
        xmax = extrema(x)[2],
        },
            PlotInc(Table([:x => x, :y => y])),
            LegendEntry(Legend),
        )
        if Path != "NA"
            pgfsave(Path*".tex", p, include_preamble = false)
            if PDF
                pgfsave(Path*".pdf", p)
            end  
        end
        display("image/png",p)
end

function pgfplot(y1,y2; Legend = ("y1","y2"), Label =("x","y"),Title = "Figure", Path = "NA", Width = "0.6*\\textwidth", Legend_pos = "outer north east", PDF = false)
    x1 = 1:size(y1,1)
    x2 = 1:size(y2,1)

    p = @pgf Axis({
        xlabel = Label[1],
        ylabel = Label[2],
        title = Title,
        width = Width,
        legend_pos = Legend_pos,
        cycle_list_name = "edu2",
        xmin = extrema(x1)[1],
        xmax = extrema(x1)[2],

        },
            Plot(Table([:x => x1, :y => y1])),
            LegendEntry(Legend[1]),
            Plot(Table([:x => x2, :y => y2])),
            LegendEntry(Legend[2])
        )
        if Path != "NA"
            pgfsave(Path*".tex", p, include_preamble = false)
            if PDF
                pgfsave(Path*".pdf", p)
            end  
        end
        display("image/png",p)
end

function pgfplot(y1,y2,y3; Legend = ("y1","y2","y3"), Label = ("x","y"), Title = "Figure", Path = "NA", Width = "0.6*\\textwidth", Legend_pos = "outer north east", PDF = false)
    x1 = 1:size(y1,1)
    x2 = 1:size(y2,1)
    x3 = 1:size(y3,1)
    p = @pgf Axis({
        xlabel = Label[1],
        ylabel = Label[2],
        title = Title,
        width = Width,
        legend_pos = Legend_pos,
        cycle_list_name = "edu3",
        xmin = extrema(x1)[1],
        xmax = extrema(x1)[2],

        },
            PlotInc(Table([:x => x1, :y => y1])),
            LegendEntry(Legend[1]),
            PlotInc(Table([:x => x2, :y => y2])),
            LegendEntry(Legend[2]),
            PlotInc(Table([:x => x3, :y => y3])),
            LegendEntry(Legend[3])
        )
        if Path != "NA"
            pgfsave(Path*".tex", p, include_preamble = false)
            if PDF
                pgfsave(Path*".pdf", p)
            end  
        end
        display("image/png",p)
end

function pgfplot(y1,y2,y3,y4; Legend = ("y1","y2","y3","y4"), Label =("x","y"), Title = "Figure", Path = "NA", Width = "0.6*\\textwidth", Legend_pos = "outer north east", PDF = false)
    x1 = 1:size(y1,1)
    x2 = 1:size(y2,1)
    x3 = 1:size(y3,1)
    x4 = 1:size(y4,1)
    p = @pgf Axis({
        xlabel = Label[1],
        ylabel = Label[2],
        title = Title,
        width = Width,
        legend_pos = Legend_pos,
        cycle_list_name = "edu4",
        xmin = extrema(x1)[1],
        xmax = extrema(x1)[2],
        },
            Plot(Table([:x => x1, :y => y1])),
            LegendEntry(Legend[1]),
            Plot(Table([:x => x2, :y => y2])),
            LegendEntry(Legend[2]),
            Plot(Table([:x => x3, :y => y3])),
            LegendEntry(Legend[3]),
            Plot(Table([:x => x4, :y => y4])),
            LegendEntry(Legend[4])
        )
        if Path != "NA"
            pgfsave(Path*".tex", p, include_preamble = false)
            if PDF
                pgfsave(Path*".pdf", p)
            end  
        end
        display("image/png",p)
end



