# Test multiple dispatch extensions of Statistics functions

@testset "Statistics Extensions" begin
    # Create test data
    df = DataFrame(
        type = repeat([1, 2, 3], inner=100),
        edu = repeat([1, 2], 150),
        bmi = vcat(randn(100) .+ 28, randn(100) .+ 29, randn(100) .+ 30),
        wealth = vcat(randn(100) .* 10 .+ 50, randn(100) .* 10 .+ 60, randn(100) .* 10 .+ 70),
        weight = rand(300) .+ 0.5
    )

    @testset "mean(DataFrame, Symbol)" begin
        # Unweighted, no grouping
        result = mean(df, :bmi)
        @test result isa Float64
        @test result ≈ 29.0 atol=1.0

        # Unweighted, single grouping variable
        result = mean(df, :bmi, by=:type)
        @test result isa DataFrame
        @test "type" in names(result)
        @test "bmi" in names(result)
        @test nrow(result) == 3
        @test result[result.type .== 1, :bmi][1] ≈ 28.0 atol=1.0
        @test result[result.type .== 2, :bmi][1] ≈ 29.0 atol=1.0
        @test result[result.type .== 3, :bmi][1] ≈ 30.0 atol=1.0

        # Unweighted, multiple grouping variables
        result = mean(df, :bmi, by=[:type, :edu])
        @test result isa DataFrame
        @test "type" in names(result)
        @test "edu" in names(result)
        @test "bmi" in names(result)
        @test nrow(result) == 6  # 3 types × 2 edu levels

        # Weighted, no grouping
        result = mean(df, :bmi, w=:weight)
        @test result isa Float64
        @test result ≈ 29.0 atol=1.0

        # Weighted, single grouping variable
        result = mean(df, :bmi, by=:type, w=:weight)
        @test result isa DataFrame
        @test "type" in names(result)
        @test "bmi" in names(result)
        @test nrow(result) == 3

        # Weighted, multiple grouping variables
        result = mean(df, :wealth, by=[:type, :edu], w=:weight)
        @test result isa DataFrame
        @test nrow(result) == 6
        @test "wealth" in names(result)
    end

    @testset "var(DataFrame, Symbol)" begin
        # Unweighted, no grouping
        result = var(df, :bmi)
        @test result isa Float64
        @test result > 0

        # Unweighted, single grouping variable
        result = var(df, :bmi, by=:type)
        @test result isa DataFrame
        @test "type" in names(result)
        @test "bmi" in names(result)
        @test nrow(result) == 3
        @test all(result.bmi .> 0)  # All variances should be positive

        # Unweighted, multiple grouping variables
        result = var(df, :bmi, by=[:type, :edu])
        @test result isa DataFrame
        @test nrow(result) == 6
        @test all(result.bmi .> 0)

        # Weighted, no grouping
        result = var(df, :bmi, w=:weight)
        @test result isa Float64
        @test result > 0

        # Weighted, single grouping variable
        result = var(df, :bmi, by=:type, w=:weight)
        @test result isa DataFrame
        @test nrow(result) == 3
        @test all(result.bmi .> 0)

        # Weighted, multiple grouping variables
        result = var(df, :wealth, by=[:type, :edu], w=:weight)
        @test result isa DataFrame
        @test nrow(result) == 6
        @test all(result.wealth .> 0)
    end

    @testset "std(DataFrame, Symbol)" begin
        # Unweighted, no grouping
        result = std(df, :bmi)
        @test result isa Float64
        @test result > 0

        # Unweighted, single grouping variable
        result = std(df, :bmi, by=:type)
        @test result isa DataFrame
        @test "type" in names(result)
        @test "bmi" in names(result)
        @test nrow(result) == 3
        @test all(result.bmi .> 0)

        # Unweighted, multiple grouping variables
        result = std(df, :bmi, by=[:type, :edu])
        @test result isa DataFrame
        @test nrow(result) == 6
        @test all(result.bmi .> 0)

        # Weighted, no grouping
        result = std(df, :bmi, w=:weight)
        @test result isa Float64
        @test result > 0

        # Weighted, single grouping variable
        result = std(df, :bmi, by=:type, w=:weight)
        @test result isa DataFrame
        @test nrow(result) == 3
        @test all(result.bmi .> 0)

        # Weighted, multiple grouping variables
        result = std(df, :wealth, by=[:type, :edu], w=:weight)
        @test result isa DataFrame
        @test nrow(result) == 6
        @test all(result.wealth .> 0)
    end

    @testset "median(DataFrame, Symbol)" begin
        # Unweighted, no grouping
        result = median(df, :bmi)
        @test result isa Float64
        @test result ≈ 29.0 atol=1.0

        # Unweighted, single grouping variable
        result = median(df, :bmi, by=:type)
        @test result isa DataFrame
        @test "types" in names(result)  # Note: renamed to "types"
        @test "bmi" in names(result)
        @test nrow(result) == 3

        # Unweighted, multiple grouping variables
        result = median(df, :bmi, by=[:type, :edu])
        @test result isa DataFrame
        @test "types_type" in names(result)  # Note: renamed
        @test "types_edu" in names(result)
        @test "bmi" in names(result)
        @test nrow(result) == 6

        # Weighted median warning
        @test_logs (:warn, "Weighted median not implemented. Returning unweighted median.") median(df, :bmi, w=:weight)
    end

    @testset "quantile(DataFrame, Symbol, Float64)" begin
        # Unweighted, no grouping
        result = quantile(df, :bmi, 0.75)
        @test result isa Float64
        @test result > mean(df, :bmi)

        # Unweighted, single grouping variable
        result = quantile(df, :bmi, 0.75, by=:type)
        @test result isa DataFrame
        @test "type" in names(result)
        @test "bmi" in names(result)
        @test nrow(result) == 3

        # Check that 75th percentile > mean
        means = mean(df, :bmi, by=:type)
        for i in 1:3
            @test result[i, :bmi] >= means[i, :bmi]
        end

        # Unweighted, multiple grouping variables
        result = quantile(df, :bmi, 0.5, by=[:type, :edu])
        @test result isa DataFrame
        @test nrow(result) == 6

        # Weighted, no grouping
        result = quantile(df, :bmi, 0.75, w=:weight)
        @test result isa Float64

        # Weighted, single grouping variable
        result = quantile(df, :bmi, 0.75, by=:type, w=:weight)
        @test result isa DataFrame
        @test nrow(result) == 3
        @test "bmi" in names(result)

        # Weighted, multiple grouping variables
        result = quantile(df, :wealth, 0.5, by=[:type, :edu], w=:weight)
        @test result isa DataFrame
        @test nrow(result) == 6

        # Test different quantiles
        for q in [0.25, 0.5, 0.75, 0.9]
            result = quantile(df, :bmi, q, by=:type)
            @test nrow(result) == 3
            @test all(.!ismissing.(result.bmi))
        end
    end

    @testset "Edge cases" begin
        # Single observation per group
        df_small = DataFrame(
            type = [1, 2, 3],
            value = [10.0, 20.0, 30.0],
            weight = [1.0, 1.0, 1.0]
        )

        result = mean(df_small, :value, by=:type)
        @test nrow(result) == 3
        @test result.value == [10.0, 20.0, 30.0]

        result = var(df_small, :value, by=:type)
        @test nrow(result) == 3
        @test all(isnan.(result.value))  # Variance undefined for single observation

        # Missing values - test that functions handle them appropriately
        df_missing = DataFrame(
            type = [1, 1, 2, 2],
            value = [1.0, 2.0, 3.0, 4.0]
        )

        result = mean(df_missing, :value, by=:type)
        @test result[1, :value] ≈ 1.5
        @test result[2, :value] ≈ 3.5
    end

    @testset "Consistency with Statistics.jl" begin
        # Test that our extensions produce same results as base Statistics
        x = df[df.type .== 1, :bmi]

        @test mean(df[df.type .== 1, :], :bmi) ≈ Statistics.mean(x)
        @test var(df[df.type .== 1, :], :bmi) ≈ Statistics.var(x)
        @test median(df[df.type .== 1, :], :bmi) ≈ Statistics.median(x)
        @test quantile(df[df.type .== 1, :], :bmi, 0.75) ≈ Statistics.quantile(x, 0.75)
        @test std(df[df.type .== 1, :], :bmi) ≈ Statistics.std(x)
    end

    @testset "Type stability" begin
        # Test that return types are consistent
        @test typeof(mean(df, :bmi)) == Float64
        @test typeof(mean(df, :bmi, by=:type)) == DataFrame

        @test typeof(var(df, :bmi)) == Float64
        @test typeof(var(df, :bmi, by=:type)) == DataFrame

        @test typeof(median(df, :bmi)) == Float64
        @test typeof(median(df, :bmi, by=:type)) == DataFrame

        @test typeof(quantile(df, :bmi, 0.5)) == Float64
        @test typeof(quantile(df, :bmi, 0.5, by=:type)) == DataFrame

        @test typeof(std(df, :bmi)) == Float64
        @test typeof(std(df, :bmi, by=:type)) == DataFrame
    end

    @testset "skipmissing functionality" begin
        # Create data with missing values
        df_miss = DataFrame(
            type = [1, 1, 1, 2, 2, 2, 3, 3, 3],
            value = [1.0, 2.0, missing, 4.0, missing, 6.0, 7.0, 8.0, 9.0],
            weight = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
        )

        # Test mean with skipmissing
        result_skip = mean(df_miss, :value, skipmissing=true)
        @test !ismissing(result_skip)
        @test result_skip ≈ mean([1.0, 2.0, 4.0, 6.0, 7.0, 8.0, 9.0])

        result_no_skip = mean(df_miss, :value, skipmissing=false)
        @test ismissing(result_no_skip)

        # Test mean with grouping and skipmissing
        result_group = mean(df_miss, :value, by=:type, skipmissing=true)
        @test nrow(result_group) == 3
        @test result_group[1, :value] ≈ 1.5  # (1.0 + 2.0) / 2
        @test result_group[2, :value] ≈ 5.0  # (4.0 + 6.0) / 2
        @test result_group[3, :value] ≈ 8.0  # (7.0 + 8.0 + 9.0) / 3

        # Test weighted mean with skipmissing
        result_weighted = mean(df_miss, :value, w=:weight, skipmissing=true)
        @test !ismissing(result_weighted)

        # Test var with skipmissing
        result_var = var(df_miss, :value, skipmissing=true)
        @test !ismissing(result_var)
        @test result_var > 0

        # Test median with skipmissing
        result_median = median(df_miss, :value, skipmissing=true)
        @test !ismissing(result_median)
        @test result_median ≈ 6.0

        # Test quantile with skipmissing
        result_q = quantile(df_miss, :value, 0.5, skipmissing=true)
        @test !ismissing(result_q)
        @test result_q ≈ 6.0

        # Test std with skipmissing
        result_std = std(df_miss, :value, skipmissing=true)
        @test !ismissing(result_std)
        @test result_std > 0

        # Test grouped operations with skipmissing
        for func in [var, std]
            result = func(df_miss, :value, by=:type, skipmissing=true)
            @test nrow(result) == 3
            @test all(.!ismissing.(result.value))
        end

        # Test grouped median with skipmissing
        result_med_group = median(df_miss, :value, by=:type, skipmissing=true)
        @test nrow(result_med_group) == 3
        @test all(.!ismissing.(result_med_group.value))

        # Test grouped quantile with skipmissing
        result_q_group = quantile(df_miss, :value, 0.75, by=:type, skipmissing=true)
        @test nrow(result_q_group) == 3
        @test all(.!ismissing.(result_q_group.value))
    end
end
