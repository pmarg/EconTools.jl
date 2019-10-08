"""
    function indices(n_a, n_h, n_zl, n_zh,ind)
"""
function indices(n_a, n_h, n_zl, n_zh,ind)
    i_a  = convert(Int, floor((ind-0.05)/(n_h*n_zl*n_zh)))+1;
    i_h  = convert(Int, mod(floor((ind-0.05)/(n_zl*n_zh)),n_h))+1;
    i_zl = convert(Int, mod(floor((ind-0.05)/n_zh),n_zl))+1
    i_zh = convert(Int, mod(floor(ind-0.05),n_zh))+1

    return i_a, i_h, i_zl, i_zh
end

function indices(n_a, n_h, n_zl, n_zh, n_zm,ind)
    i_a  = convert(Int, floor((ind-0.05)/(n_h*n_zl*n_zh*n_zm)))+1;
    i_h  = convert(Int, mod(floor((ind-0.05)/(n_zl*n_zh*n_zm)),n_h))+1;
    i_zl = convert(Int, mod(floor((ind-0.05)/(n_zh*n_zm)),n_zl))+1
    i_zh = convert(Int, mod(floor((ind-0.05)/n_zm),n_h))+1
    i_zm = convert(Int, mod(floor(ind-0.05),n_zm))+1

    return i_a, i_h, i_zl, i_zh, i_zm
end

const to = TimerOutput()


function prettytime(t::Int)
    if t < 1e3
        value, units = t, "ns"
    elseif t < 1e6
        value, units = t / 1e3, "μs"
    elseif t < 1e9
        value, units = t / 1e6, "ms"
    else
        if t / 1e9 < 60
          value, units = t / 1e9, "s"
        elseif t / 1e9 < 3600
          value, units = t / (1e9*60), "m"
        else
          value, units = t / (1e9*60*60), "h"
        end
    end

    if round(value) >= 100
        str = string(@sprintf("%.0f", value), units)
    elseif round(value * 10) >= 100
        str = string(@sprintf("%.1f", value), units)
    else
        str = string(@sprintf("%.2f", value), units)
    end
    return lpad(str, 6, " ")
end
function prettytime(t::AbstractFloat)
    if t < 1e3
        value, units = t, "ns"
    elseif t < 1e6
        value, units = t / 1e3, "μs"
    elseif t < 1e9
        value, units = t / 1e6, "ms"
    else
        if t / 1e9 < 60
          value, units = t / 1e9, "s"
        elseif t / 1e9 < 3600
          value, units = t / (1e9*60), "m"
        else
          value, units = t / (1e9*60*60), "h"
        end
    end

    if round(value) >= 100
        str = string(@sprintf("%.0f", value), units)
    elseif round(value * 10) >= 100
        str = string(@sprintf("%.1f", value), units)
    else
        str = string(@sprintf("%.2f", value), units)
    end
    return lpad(str, 6, " ")
end

function PGFplot(x)
   x_axis = 1:length(x)
   figure=@pgf PGFPlotsX.Axis({
     },
     PlotInc(Table(x=x_axis,y = x))
   )
   return figure
end

function PGFplot(x1,x2)
   x1_axis = 1:length(x1)
   x2_axis = 1:length(x2)
   figure=@pgf PGFPlotsX.Axis({
    cycle_list_name = "edu2",
     },
     PlotInc(Table(x=x1_axis,y = x1)),
     PlotInc(Table(x=x2_axis,y = x2))
   )
   return figure
end

function PGFplot(x1,x2,x3)
   x1_axis = 1:length(x1)
   x2_axis = 1:length(x2)
   x3_axis = 1:length(x3)
   figure=@pgf PGFPlotsX.Axis({
     },
     PlotInc(Table(x=x1_axis,y = x1)),
     PlotInc(Table(x=x2_axis,y = x2)),
     PlotInc(Table(x=x3_axis,y = x3))
   )
   return figure
end
function PGFplot(x1,x2,x3,x4)
   x1_axis = 1:length(x1)
   x2_axis = 1:length(x2)
   x3_axis = 1:length(x3)
   x4_axis = 1:length(x4)
   figure=@pgf PGFPlotsX.Axis({
     },
     PlotInc(Table(x=x1_axis,y = x1)),
     PlotInc(Table(x=x2_axis,y = x2)),
     PlotInc(Table(x=x3_axis,y = x3)),
     PlotInc(Table(x=x4_axis,y = x4))
   )
   return figure
end

pgfplots_pre = "\\definecolor{airforceblue}{rgb}{0.36, 0.54, 0.66}
  \\definecolor{amaranth}{rgb}{0.9, 0.17, 0.31}
\\definecolor{asparagus}{rgb}{0.53, 0.66, 0.42}
\\definecolor{cadmiumorange}{rgb}{0.93, 0.53, 0.18}
\\pgfplotscreateplotcyclelist{edu2}{%
no marks,very thick,dashed,color = asparagus\\\\%1
no marks,very thick,color = airforceblue\\\\%2
no marks,very thick,dotted,color = cadmiumorange\\\\%3
}
\\pgfplotscreateplotcyclelist{edu2}{%
no marks,very thick,color = airforceblue\\\\%1
no marks,very thick,dotted,color = cadmiumorange\\\\%2
}
\\pgfplotscreateplotcyclelist{edu4}{%
no marks,very thick,dashed,color = asparagus\\\\%1
no marks,very thick,dotted,color = cadmiumorange\\\\%2
no marks,thick,dashed,color = asparagus!65!black\\\\%3
no marks,thick ,dotted,color = cadmiumorange!65!black\\\\%4
}"
push!(PGFPlotsX.CUSTOM_PREAMBLE, pgfplots_pre)
