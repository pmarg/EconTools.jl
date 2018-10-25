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
