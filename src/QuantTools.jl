"""
    function calc_markov_shock_from_uniform_rv(u::Float64, Pz_cdf::Array{Float64})
"""
function calc_markov_shock_from_uniform_rv(u::Float64, Pz_cdf::Array{Float64})
    done = false
    i_zn = 0

    while done==false
        i_zn = i_zn + 1;
        done = (u < Pz_cdf[i_zn]);
    end
    return i_zn
end

"""
    function simulate_markov_shocks(N::Int64, sim_z::Array{Int64}, Pz_cdf::Array{Float64})
"""
function simulate_markov_shocks(N::Int64, sim_z::Array{Int64}, Pz_cdf::Array{Float64})
    sim_zn=zeros(Int,N)

    u=rand(rng,N)
    for i = 1:N
        sim_zn[i] = calc_markov_shock_from_uniform_rv(u[i], Pz_cdf[sim_z[i],:]);
    end
    return sim_zn
end

function simulate_markov_shocks(N::Int64, Pz_initial_cdf::Array{Float64})
    sim_z=zeros(Int,N)
    u=rand(rng, N)

    for i = 1:N
        sim_z[i] = calc_markov_shock_from_uniform_rv(u[i], Pz_initial_cdf);
    end
    return sim_z
end

function interpolate_params(cohort,x,range)
    y1 = interpolate((cohort,),x,Gridded(Linear()))
    y2 = extrapolate(y1,Line())
    z=y2(range)
    return z
end
