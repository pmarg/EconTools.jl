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

# Quantitative Methods Tools
# Functions for simulating stochastic processes and parameter interpolation

"""
    calc_markov_shock_from_uniform_rv(u::Float64, Pz_cdf::Vector{Float64}) -> Int

Find next Markov state using inverse CDF method.

Given a uniform random draw and cumulative transition probabilities, determines
the next state index. This is the core function for simulating discrete Markov chains.

# Arguments
- `u::Float64`: Uniform random draw in [0, 1]
- `Pz_cdf::Vector{Float64}`: Cumulative transition probabilities (length n_states)
  Must be sorted and sum to 1.0

# Returns
- `Int`: Next state index (1-based)

# Algorithm
Finds smallest index j where u < Pz_cdf[j]. This implements the inverse CDF
(quantile) method for discrete distributions.

# Example
```julia
## Transition from state 2 in 3-state chain
Pz = [0.7 0.2 0.1;
      0.2 0.6 0.2;
      0.1 0.2 0.7]
Pz_cdf = cumsum(Pz, dims=2)

## From state 2, CDF is [0.2, 0.8, 1.0]
u = 0.5  ## Random draw
next_state = calc_markov_shock_from_uniform_rv(u, Pz_cdf[2, :])  ## Returns 2
```

# Notes
- Internal function used by `simulate_markov_shocks`
- O(n_states) complexity - could be optimized with binary search for large state spaces
"""
function calc_markov_shock_from_uniform_rv(u::Float64, Pz_cdf::Vector{Float64})
    i_z_next = 0
    done = false

    while !done
        i_z_next += 1
        done = (u < Pz_cdf[i_z_next])
    end

    return i_z_next
end


"""
    simulate_markov_shocks(N::Int64, sim_z::Vector{Int}, Pz_cdf::Matrix{Float64}, rng)

Simulate next-period Markov states using inverse CDF method.

Given current states and transition probabilities, simulates the next period states
for N individuals. Uses uniform random draws to determine transitions.

# Arguments
- `N::Int64`: Number of individuals/simulations
- `sim_z::Vector{Int}`: Current state indices (length N), values in 1:n_states
- `Pz_cdf::Matrix{Float64}`: Cumulative transition probability matrix (n_states × n_states)
  - Row i contains CDF for transitions from state i
  - Each row must be sorted and end at 1.0
- `rng`: Random number generator (use StableRNG for reproducibility)

# Returns
- `Vector{Int}`: Next period state indices (length N)

# Example
```julia
using StableRNGs, Statistics

## 3-state Markov chain with persistence
Pz = [0.7 0.2 0.1;    ## Transitions from state 1
      0.2 0.6 0.2;    ## Transitions from state 2
      0.1 0.2 0.7]    ## Transitions from state 3

Pz_cdf = cumsum(Pz, dims=2)  ## Convert to CDF

rng = StableRNG(123)
current_states = fill(2, 1000)  ## All start in state 2
next_states = simulate_markov_shocks(1000, current_states, Pz_cdf, rng)

## Check transition frequencies match Pz[2, :]
mean(next_states .== 1)  ## Should be ≈ 0.2
mean(next_states .== 2)  ## Should be ≈ 0.6
mean(next_states .== 3)  ## Should be ≈ 0.2
```

# Notes
- Requires Pz_cdf (not Pz) for efficiency - convert once, use many times
- Uses inverse CDF method: for each individual, finds smallest j where U < CDF[current_state, j]
- O(N × n_states) complexity
- Common in dynamic programming for simulating income shocks, health transitions, etc.
"""
function simulate_markov_shocks(N::Int64, sim_z::Vector{Int}, Pz_cdf::Matrix{Float64}, rng)
    sim_z_next = zeros(Int, N)
    u = rand(rng, N)

    for i = 1:N
        sim_z_next[i] = calc_markov_shock_from_uniform_rv(u[i], Pz_cdf[sim_z[i], :])
    end

    return sim_z_next
end


"""
    simulate_markov_shocks(N::Int64, Pz_initial_cdf::Vector{Float64}, rng)

Simulate initial Markov states from initial distribution.

Draws initial states for N individuals from a given initial distribution.

# Arguments
- `N::Int64`: Number of individuals
- `Pz_initial_cdf::Vector{Float64}`: Cumulative initial state distribution (length n_states)
  - Must be sorted and end at 1.0
  - Element j is P(initial state ≤ j)
- `rng`: Random number generator

# Returns
- `Vector{Int}`: Initial state indices (length N)

# Example
```julia
using StableRNGs

## Initial distribution: 30% state 1, 50% state 2, 20% state 3
Pz_initial = [0.3, 0.5, 0.2]
Pz_initial_cdf = cumsum(Pz_initial)  ## [0.3, 0.8, 1.0]

rng = StableRNG(456)
initial_states = simulate_markov_shocks(10000, Pz_initial_cdf, rng)

## Check frequencies match initial distribution
mean(initial_states .== 1)  ## Should be ≈ 0.3
mean(initial_states .== 2)  ## Should be ≈ 0.5
mean(initial_states .== 3)  ## Should be ≈ 0.2
```

# Notes
- Use this for period 1 initialization
- Use the other method (with `sim_z` argument) for period 2 onwards
"""
function simulate_markov_shocks(N::Int64, Pz_initial_cdf::Vector{Float64}, rng)
    sim_z = zeros(Int, N)
    u = rand(rng, N)

    for i = 1:N
        sim_z[i] = calc_markov_shock_from_uniform_rv(u[i], Pz_initial_cdf)
    end

    return sim_z
end


# Interpolation Functions
# Numerical interpolation methods for value functions and policy functions

"""
    bilerp_flat(aG, bG, M, a, b)

Fast bilinear interpolation for 2D grids with flat indexing.

Performs bilinear interpolation on a 2D matrix M with grid points defined by vectors aG and bG.
The function finds the four surrounding grid points and computes the weighted average.

# Arguments
- `aG::Vector`: Grid points for first dimension (e.g., assets)
- `bG::Vector`: Grid points for second dimension (e.g., BMI)
- `M::Matrix`: Matrix of values to interpolate (size: length(aG) × length(bG))
- `a::Real`: Point in first dimension to interpolate at
- `b::Real`: Point in second dimension to interpolate at

# Returns
- Interpolated value at point (a, b)

# Algorithm
1. Finds bracketing indices for both dimensions using binary search
2. Computes interpolation weights based on relative position
3. Returns weighted average of four corner values

# Example
```julia
# Create a simple 2D value function
assets = [0.0, 1.0, 2.0, 3.0]
bmi = [20.0, 25.0, 30.0, 35.0]
V = rand(4, 4)  # Value function matrix

# Interpolate at (a=1.5, bmi=27.5)
v_interp = bilerp_flat(assets, bmi, V, 1.5, 27.5)
```

# Notes
- Efficient for repeated interpolation on same grid
- Handles boundary cases by clamping to grid edges
- Commonly used in dynamic programming for value function interpolation
"""
function bilerp_flat(aG, bG, M, a, b)
    na = length(aG)
    nb = length(bG)

    ## Find bracketing indices for a
    if a <= aG[1]
        ia = 1
        ia_next = 1
        wa = 0.0
    elseif a >= aG[end]
        ia = na
        ia_next = na
        wa = 0.0
    else
        ia = searchsortedlast(aG, a)
        ia_next = ia + 1
        wa = (a - aG[ia]) / (aG[ia_next] - aG[ia])
    end

    ## Find bracketing indices for b
    if b <= bG[1]
        ib = 1
        ib_next = 1
        wb = 0.0
    elseif b >= bG[end]
        ib = nb
        ib_next = nb
        wb = 0.0
    else
        ib = searchsortedlast(bG, b)
        ib_next = ib + 1
        wb = (b - bG[ib]) / (bG[ib_next] - bG[ib])
    end

    ## Bilinear interpolation
    v11 = M[ia, ib]
    v21 = M[ia_next, ib]
    v12 = M[ia, ib_next]
    v22 = M[ia_next, ib_next]

    v1 = (1 - wa) * v11 + wa * v21
    v2 = (1 - wa) * v12 + wa * v22

    return (1 - wb) * v1 + wb * v2
end

