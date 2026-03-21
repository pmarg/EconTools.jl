# Test grid generation and numerical methods

@testset "Grid Generation" begin
    @testset "expspace" begin
        # Test basic functionality
        grid = expspace(0.0, 10.0, 1.0, 11)
        @test length(grid) == 11
        @test grid[1] ≈ 0.0
        @test grid[end] ≈ 10.0
        @test issorted(grid)

        # Test with scale > 1 (points closer at bottom)
        grid_dense_bottom = expspace(0.0, 10.0, 2.0, 11)
        @test grid_dense_bottom[2] - grid_dense_bottom[1] < grid_dense_bottom[end] - grid_dense_bottom[end-1]

        # Test with scale < 1 (points closer at top)
        grid_dense_top = expspace(0.0, 10.0, 0.5, 11)
        @test grid_dense_top[2] - grid_dense_top[1] > grid_dense_top[end] - grid_dense_top[end-1]

        # Test single point
        grid_single = expspace(5.0, 5.0, 1.0, 1)
        @test length(grid_single) == 1
        @test grid_single[1] ≈ 5.0
    end

    @testset "tauchen" begin
        # Test basic AR(1) discretization
        grid, P, P_cdf = tauchen(5, 0.9, 0.1, 0.0, 3)

        @test length(grid) == 5
        @test size(P) == (5, 5)
        @test size(P_cdf) == (5, 5)

        # Check transition matrix properties
        @test all(P .>= 0)  # Non-negative
        @test all(sum(P, dims=2) .≈ 1.0)  # Rows sum to 1
        @test all(P_cdf[:, end] .≈ 1.0)  # CDF ends at 1

        # Check persistence (diagonal should be large for high ρ)
        @test all(diag(P) .> 0.5)

        # Test single state (degenerate case)
        grid1, P1, P_cdf1 = tauchen(1, 0.9, 0.1)
        @test length(grid1) == 1
        @test P1 == [1.0]

        # Test with different mean parameter
        # Note: grid values are centered around μ/(1-ρ)
        grid_mean, P_mean, _ = tauchen(7, 0.95, 0.05, 2.0, 4)
        @test mean(grid_mean) ≈ 2.0 / (1 - 0.95) atol=5.0  # μ/(1-ρ) = 2.0/0.05 = 40
    end
end

@testset "Markov Chain Simulation" begin
    @testset "simulate_markov_shocks - initial distribution" begin
        rng = StableRNG(12345)

        # Test 3-state chain
        initial_dist = [0.3, 0.5, 0.2]
        initial_cdf = cumsum(initial_dist)

        N = 10000
        states = simulate_markov_shocks(N, initial_cdf, rng)

        @test length(states) == N
        @test all(states .>= 1)
        @test all(states .<= 3)

        # Check empirical distribution matches theoretical
        empirical = [mean(states .== i) for i in 1:3]
        @test empirical[1] ≈ 0.3 atol=0.02
        @test empirical[2] ≈ 0.5 atol=0.02
        @test empirical[3] ≈ 0.2 atol=0.02
    end

    @testset "simulate_markov_shocks - transitions" begin
        rng = StableRNG(54321)

        # Test 3-state persistent chain
        P = [0.7 0.2 0.1;
             0.2 0.6 0.2;
             0.1 0.2 0.7]
        P_cdf = cumsum(P, dims=2)

        # Start everyone in state 2
        N = 10000
        current_states = fill(2, N)
        next_states = simulate_markov_shocks(N, current_states, P_cdf, rng)

        @test length(next_states) == N
        @test all(next_states .>= 1)
        @test all(next_states .<= 3)

        # Check empirical transitions match P[2, :]
        empirical = [mean(next_states .== i) for i in 1:3]
        @test empirical[1] ≈ P[2, 1] atol=0.02
        @test empirical[2] ≈ P[2, 2] atol=0.02
        @test empirical[3] ≈ P[2, 3] atol=0.02
    end
end

@testset "Interpolation" begin
    @testset "bilerp_flat" begin
        # Create simple test grid
        a_grid = [0.0, 1.0, 2.0]
        b_grid = [10.0, 20.0, 30.0]
        M = [1.0 2.0 3.0;
             4.0 5.0 6.0;
             7.0 8.0 9.0]

        # Test corner points (should return exact values)
        @test bilerp_flat(a_grid, b_grid, M, 0.0, 10.0) ≈ 1.0
        @test bilerp_flat(a_grid, b_grid, M, 2.0, 30.0) ≈ 9.0
        @test bilerp_flat(a_grid, b_grid, M, 1.0, 20.0) ≈ 5.0

        # Test midpoint interpolation
        val = bilerp_flat(a_grid, b_grid, M, 1.0, 15.0)
        @test val ≈ 4.5  # average of M[2,1] and M[2,2]

        val2 = bilerp_flat(a_grid, b_grid, M, 0.5, 10.0)
        @test val2 ≈ 2.5  # average of M[1,1] and M[2,1]

        # Test out-of-bounds (should clamp to edges)
        @test bilerp_flat(a_grid, b_grid, M, -1.0, 10.0) ≈ M[1, 1]
        @test bilerp_flat(a_grid, b_grid, M, 5.0, 40.0) ≈ M[end, end]

        # Test general bilinear interpolation
        val3 = bilerp_flat(a_grid, b_grid, M, 1.5, 25.0)
        @test val3 > 0
        @test val3 < 10
    end
end
