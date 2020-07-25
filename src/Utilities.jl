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
