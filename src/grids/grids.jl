"""
    expspace(x_min::Float64, x_max::Float64, x_scale::Float64, n_x::Int64) -> Vector{Float64}

Grid of `n_x` points from `x_min` to `x_max` whose spacing is controlled by `x_scale`:
point `i` is `x_min + (x_max - x_min) * ((i - 1) / (n_x - 1))^x_scale`.

- `x_scale == 1`: evenly spaced (like `range`).
- `x_scale > 1`: points closer together near `x_min` (e.g. asset grids near zero).
- `0 < x_scale < 1`: points closer together near `x_max`.

With `n_x == 1` the grid is `[x_min]`.

# Examples
```julia
expspace(0.0, 100.0, 1.0, 5)  # [0.0, 25.0, 50.0, 75.0, 100.0]
expspace(0.0, 100.0, 2.0, 5)  # [0.0, 6.25, 25.0, 56.25, 100.0]
```
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
    tauchen(N::Integer=9, ρ::Real=0.96, σ::Real=0.045, μ::Real=0.0, n_std::Integer=4) -> (grid, Π, Π_cdf)

Tauchen's (1986) method for approximating the AR(1) process
```math
    y_t = \\mu + \\rho y_{t-1} + \\epsilon_t
```
where ``\\epsilon_t \\sim N(0, \\sigma^2)``, with an `N`-state Markov chain.

# Arguments
- `N::Integer=9`: number of grid points.
- `ρ::Real=0.96`: persistence.
- `σ::Real=0.045`: standard deviation of the innovation ``\\epsilon_t``.
- `μ::Real=0.0`: constant of the process (the unconditional mean is `μ / (1 - ρ)`).
- `n_std::Integer=4`: the grid spans `n_std` unconditional standard deviations on
  each side of the mean.

# Returns
- `grid`: `N` evenly spaced points (a range).
- `Π`: `N × N` transition matrix, `Π[i, j] = P(y′ = grid[j] | y = grid[i])`.
- `Π_cdf`: cumulative sums of `Π` along each row.

If `ρ ≤ 0`, `Π` and `Π_cdf` are instead the `N`-vector of i.i.d. probabilities. With
`N == 1`, `Π = Π_cdf = [1.0]`.

# Notes
- Adapted from QuantEcon.jl. For highly persistent processes or few points, prefer
  [`rouwenhorst`](@ref).

# Examples
```julia
z_grid, Π, Π_cdf = tauchen(9, 0.96, 0.045, 0.0, 4)
```
"""
function tauchen(N::Integer=9, ρ::Real=0.96, σ::Real=0.045, μ::Real=0.0, n_std::Integer=4)
    if N > 1
        a_bar = n_std * sqrt(σ^2 / (1 - ρ^2))
        y = range(-a_bar,stop= a_bar,length= N)
        d = y[2] - y[1]
    else
        a_bar = 0.0
        y = range(-a_bar,stop= a_bar,length= N)
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
            Π_cdf=cumsum(Π,dims=2)
        else
            Π = zeros(N)
            Π[1] = cdf(Normal(),(y[1] + d/2) / σ)
            Π[N] = 1 - cdf(Normal(),(y[N]  - d/2) / σ)
            for col=2:N-1
                Π[col] = (cdf(Normal(),(y[col]  + d/2) / σ) -
                       cdf(Normal(),(y[col] - d/2) / σ))
            end
            Π_cdf=cumsum(Π,dims=1)

        end
    else
        Π=[1.0]
        Π_cdf =[1.0]
    end


    return grid, Π, Π_cdf
end

"""
    rouwenhorst(N::Integer, ρ::Real, σ::Real, μ::Real=0.0) -> (grid, Π, Π_cdf)

Rouwenhorst's (1995) method for approximating an AR(1) process with a finite Markov chain
```math
    y_t = \\mu + \\rho y_{t-1} + \\epsilon_t
```
where \$\\epsilon_t \\sim N (0, \\sigma^2)\$. Unlike Tauchen's method, the chain matches the
unconditional variance \$\\sigma^2/(1-\\rho^2)\$ and the first-order autocorrelation \$\\rho\$
exactly for any `N`, which makes it the preferred method for highly persistent
processes (ρ close to 1) and for few grid points (Kopecky and Suen, 2010).
# Arguments
- `N::Integer`: number of grid points.
- `ρ::Real`: persistence.
- `σ::Real`: standard deviation of the innovation.
- `μ::Real=0.0`: constant of the process (the unconditional mean is `μ / (1 - ρ)`).

# Returns
- `grid::Vector`: `N` evenly spaced points over ±σ_y√(N-1) around `μ / (1 - ρ)`,
  where σ_y = σ / √(1 - ρ²).
- `Π`: `N × N` transition matrix, `Π[i, j] = P(y′ = grid[j] | y = grid[i])`.
- `Π_cdf`: cumulative sums of `Π` along each row.

# Notes
- The stationary distribution is Binomial(N-1, 1/2) over the grid points.

# Examples
```julia
z_grid, Π, Π_cdf = rouwenhorst(5, 0.97, 0.1)
```
"""
function rouwenhorst(N::Integer, ρ::Real, σ::Real, μ::Real=0.0)
    N == 1 && return [μ / (1 - ρ)], ones(1, 1), ones(1, 1)
    p = (1 + ρ) / 2
    Π = [p 1-p; 1-p p]
    for n in 3:N
        z = zeros(n - 1)
        Π = p .* [Π z; z' 0] .+ (1 - p) .* [z Π; 0 z'] .+
            (1 - p) .* [z' 0; Π z] .+ p .* [0 z'; z Π]
        Π[2:end-1, :] ./= 2  # interior rows were counted twice
    end
    ψ = sqrt(N - 1) * σ / sqrt(1 - ρ^2)
    grid = collect(range(-ψ, ψ, length=N)) .+ μ / (1 - ρ)
    return grid, Π, cumsum(Π, dims=2)
end

# Simulation of discrete random variables and Markov chains (inverse-CDF method)

"""
    draw_from_cdf(u::Real, cdf::AbstractVector{<:Real}) -> Int

State drawn by the uniform number `u` from a discrete distribution with cumulative
probabilities `cdf`: the smallest `j` with `cdf[j] ≥ u` (binary search).

If rounding leaves `cdf[end]` slightly below 1, a draw above it returns the last state.

# Arguments
- `u::Real`: uniform draw in [0, 1].
- `cdf::AbstractVector{<:Real}`: nondecreasing cumulative probabilities, ending at 1.

# Returns
- `Int`: state index in `1:length(cdf)`.

# Examples
```julia
draw_from_cdf(0.5, [0.2, 0.8, 1.0])  # 2
```
"""
@inline function draw_from_cdf(u::Real, cdf::AbstractVector{<:Real})::Int
    return min(searchsortedfirst(cdf, u), length(cdf))
end

"""
    simulate_markov_shocks(N::Integer, cdf::AbstractVector{<:Real}, rng) -> Vector{Int}
    simulate_markov_shocks(N::Integer, i_current::AbstractVector{<:Integer}, cdf::AbstractMatrix{<:Real}, rng) -> Vector{Int}

Draw `N` states by the inverse-CDF method, using `N` uniform draws from `rng`.

- With a vector `cdf`: `N` independent draws from one distribution (e.g. initial
  states or an i.i.d. shock).
- With current states `i_current` and a transition CDF matrix `cdf` (row `i` is the
  CDF of next period's state given state `i`, e.g. `cumsum(Π, dims=2)`): next
  period's state of each of the `N` agents.

To draw from probabilities rather than a CDF, use [`simulate_from_pdf`](@ref).

# Arguments
- `N::Integer`: number of draws (agents).
- `cdf`: cumulative probabilities, a vector or an `n × n` matrix with one CDF per row.
- `i_current::AbstractVector{<:Integer}`: current state of each agent (length `N`).
- `rng`: random number generator (e.g. `StableRNG(123)` for reproducibility).

# Returns
- `Vector{Int}`: `N` state indices.

# Examples
```julia
using StableRNGs
rng = StableRNG(123)
s0 = simulate_markov_shocks(1000, cumsum([0.3, 0.5, 0.2]), rng)
Π = [0.7 0.2 0.1; 0.2 0.6 0.2; 0.1 0.2 0.7]
s1 = simulate_markov_shocks(1000, s0, cumsum(Π, dims=2), rng)
```
"""
function simulate_markov_shocks(N::Integer, cdf::AbstractVector{<:Real}, rng)::Vector{Int}
    draws = rand(rng, N)
    return [draw_from_cdf(u, cdf) for u in draws]
end

function simulate_markov_shocks(N::Integer, i_current::AbstractVector{<:Integer}, cdf::AbstractMatrix{<:Real}, rng)::Vector{Int}
    draws = rand(rng, N)
    return [draw_from_cdf(draws[i], view(cdf, i_current[i], :)) for i in 1:N]
end

"""
    simulate_from_pdf(N::Integer, pdf::AbstractVector{<:Real}, rng) -> Vector{Int}

Draw `N` states from a discrete distribution given by its probabilities `pdf` (which
should sum to one). Same draws as `simulate_markov_shocks(N, cumsum(pdf), rng)`.

# Examples
```julia
marry = simulate_from_pdf(1, [1 - p, p], rng)[1] == 2
```
"""
simulate_from_pdf(N::Integer, pdf::AbstractVector{<:Real}, rng)::Vector{Int} =
    simulate_markov_shocks(N, cumsum(pdf), rng)


# Interpolation Functions

"""
    bilerp_flat(aG::AbstractVector, bG::AbstractVector, M::AbstractMatrix, a::Real, b::Real) -> Real

Bilinear interpolation of the values `M[i, j]`, defined on the grid points
`(aG[i], bG[j])`, at the point `(a, b)`.

Points outside the grid are clamped to its edges (no extrapolation). Repeated grid
points (a zero-width cell) are allowed. Each grid needs at least two points.

# Arguments
- `aG`, `bG`: increasing grids of the first and second dimensions (e.g. assets, BMI).
- `M::AbstractMatrix`: values, size `length(aG) × length(bG)`.
- `a`, `b`: point at which to interpolate.

# Returns
- The interpolated value, of the element type of `M` (promoted with `a` and `b`).

# Examples
```julia
aG = [0.0, 1.0, 2.0]; bG = [10.0, 20.0]
M = [1.0 2.0; 3.0 4.0; 5.0 6.0]
bilerp_flat(aG, bG, M, 0.5, 15.0)  # 2.5
bilerp_flat(aG, bG, M, 9.0, 99.0)  # 6.0 (clamped to the corner)
```
"""
@inline function bilerp_flat(aG::AbstractVector, bG::AbstractVector, M::AbstractMatrix, a::Real, b::Real)
    @inbounds begin
        ia = clamp(searchsortedlast(aG, a), 1, length(aG) - 1)
        ib = clamp(searchsortedlast(bG, b), 1, length(bG) - 1)
        a0, a1 = aG[ia], aG[ia+1]
        b0, b1 = bG[ib], bG[ib+1]
        da = a1 - a0
        db = b1 - b0
        ta = clamp((a - a0) / (da == 0 ? one(da) : da), 0, 1)
        tb = clamp((b - b0) / (db == 0 ? one(db) : db), 0, 1)
        return (1 - ta) * (1 - tb) * M[ia, ib] + ta * (1 - tb) * M[ia+1, ib] +
               (1 - ta) * tb * M[ia, ib+1] + ta * tb * M[ia+1, ib+1]
    end
end
