
function stata_coordinates(D::DataFrame;thousands=false,millions=false)
    nr = convert(Int,(size(D)[2]-1)/2)
    nc = size(D)[1]
    y = zeros(nc,nr)
    x = collect(skipmissing(D[1]))
    c = Array{Any}(undef,nr)
    for i=1:nr
        if thousands==true
                y[:,i] = collect(skipmissing(D[2*i]))./1000
        elseif millions==true
                y[:,i] = collect(skipmissing(D[2*i]))./1000000
        else
                y[:,i] = collect(skipmissing(D[2*i]))
        end
        c[i] = Coordinates(x,y[:,i])
    end
    return c
end
