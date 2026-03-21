# Test DataFrame manipulation and post-estimation functions

@testset "DataFrame Manipulation" begin
    @testset "pivot_longer" begin
        # Note: pivot_longer expects column patterns with numbers
        df_test = DataFrame(
            id = 1:2,
            income2010 = [50000, 60000],
            income2015 = [55000, 65000],
            income2020 = [60000, 70000]
        )

        result = pivot_longer(df_test, :id, [:income])

        @test "id" in names(result)
        @test "Period" in names(result)
        @test "income" in names(result)
        @test nrow(result) == 6  # 2 people × 3 periods
    end

    @testset "reshape_results!" begin
        # Create mock Monte Carlo results
        MockMC = @NamedTuple{a::Matrix{Float64}, b::Matrix{Float64}}
        mc = (a = rand(10, 5), b = rand(10, 5))

        MockD = @NamedTuple{N::Int, J::Int}
        D = (N = 10, J = 5)

        result = reshape_results!(mc, D)

        @test result isa DataFrame
        @test nrow(result) == 50  # N × J
        @test "a" in names(result)
        @test "b" in names(result)
    end

    @testset "create_age_groups" begin
        groups = create_age_groups(25, 75, 10)

        @test length(groups) == 6  # (25-34, 35-44, 45-54, 55-64, 65-74, 75)
        @test groups[1] == (25, 34)
        @test groups[end][1] == 75
    end

    @testset "assign_groups!" begin
        df = DataFrame(age = [25, 32, 40, 55, 67, 80, 92])

        # Test basic grouping (no categories)
        assign_groups!(df, :age, :age_group, 25:10:90, categories=[], numerical_cat=true)

        @test "age_group" in names(df)
        @test all(df.age_group .>= 1)

        # Test with numerical categories
        df3 = DataFrame(income=[20000.0, 50000.0, 80000.0, 120000.0, 25000.0, 30000.0, 40000.0])
        assign_groups!(df3, :income, :income_quartile, [2000.0, 50000.0, 13000.0, 26000.0],
                      categories=["Q1", "Q2", "Q3", "Q4"],
                      numerical_cat=true)

        @test all(df3.income_quartile .<= 4)
        @test all(df3.income_quartile .>= 1)
    end
end

# Note: Post-estimation functions have been replaced with multiple dispatch extensions
# of Statistics.jl functions (mean, var, median, quantile, std).
# See test_statistics_dispatch.jl for comprehensive tests of the new API.
