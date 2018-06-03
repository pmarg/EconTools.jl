import Distributions:cdf, Normal

"""
    expspace(x_min::Float64, x_max::Float64)::Array{Float64}, x_scale::Float64,n_x::Int64)
This generates a vector of length n_x between x_min and x_max,
where the spacing is controlled by x_scale.  When x_scale == 1,
this is equivalent to linspace.  When x_scale > 1, the points
are closer together near x_min.  When 0 < x_scale < 1,
the points are closer together near x_max.
"""
function expspace(x_min::Float64, x_max::Float64, x_scale::Float64,n_x::Int64)::Array{Float64}
    x_vec=zeros(n_x)
    if n_x>1
        step=(x_max-x_min)/(n_x-1)^x_scale
    else
        step=0.0
    end

    for i=1:n_x
        x_vec[i]=x_min+step*(i-1)^x_scale
    end

    return x_vec
end

"""
    tauchen(N::Integer=18, ρ::Real=0.96, σ::Real=0.045, μ::Real=0.0, n_std::Integer=4)
Tauchen's (1996) method for approximating AR(1) process with a finite markov chain
```math
    y_t = \\mu + \\rho y_{t-1} + \\epsilon_t
```
where ``\\epsilon_t \\sim N (0, \\sigma^2)``
##### Arguments
- `N::Integer`: Number of points in markov process
- `ρ::Real` : Persistence parameter in AR(1) process
- `σ::Real` : Standard deviation of random component of AR(1) process
- `μ::Real(0.0)` : Mean of AR(1) process
- `n_std::Integer(4)` : The number of standard deviations to each side the process
  should span
##### Returns
- `grid, Π, Π_cdf` : The grid, the transition matrix and CDF of transition matrix
##### Notes
- This function has been modified by QuantEcon.jl
"""
function tauchen(N::Integer=9, ρ::Real=0.96, σ::Real=0.045, μ::Real=0.0, n_std::Integer=4)
    if N > 1
        a_bar = n_std * sqrt(σ^2 / (1 - ρ^2))
        y = linspace(-a_bar, a_bar, N)
        d = y[2] - y[1]
    else
        a_bar = 0.0
        y = linspace(-a_bar, a_bar, N)
    end
    # Construct grid

    grid = y .+ μ / (1 - ρ)

    # Get transition probabilities
    if N > 1
        if ρ > 0.0
            Π = zeros(N, N)
            for row = 1:N
    # Do end points first
            Π[row, 1] = cdf(Normal(),(y[1] - ρ*y[row] + d/2) / σ)
            Π[row, N] = 1 - cdf(Normal(),(y[N] - ρ*y[row] - d/2) / σ)

    # fill in the middle columns
                for col = 2:N-1
                Π[row, col] = (cdf(Normal(),(y[col] - ρ*y[row] + d/2) / σ) -
                           cdf(Normal(),(y[col] - ρ*y[row] - d/2) / σ))
                end
            end
            Π_cdf=cumsum(Π,2)
        else
            Π = zeros(N)
            Π[1] = cdf(Normal(),(y[1] + d/2) / σ)
            Π[N] = 1 - cdf(Normal(),(y[N]  - d/2) / σ)
            for col=2:N-1
                Π[col] = (cdf(Normal(),(y[col]  + d/2) / σ) -
                       cdf(Normal(),(y[col] - d/2) / σ))
            end
            Π_cdf=cumsum(Π,1)

        end
    else
        Π=[1.0]
        Π_cdf =[1.0]
    end


    return grid, Π, Π_cdf
end
