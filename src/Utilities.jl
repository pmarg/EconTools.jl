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
