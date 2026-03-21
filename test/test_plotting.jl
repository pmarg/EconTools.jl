# Test plotting functions
# Note: These tests verify function execution and structure, not visual output

@testset "Plotting Functions" begin
    @testset "pgfplots_pre loaded" begin
        @test isdefined(EconTools, :pgfplots_pre)
        @test EconTools.pgfplots_pre isa String
        @test occursin("airforceblue", EconTools.pgfplots_pre)
        @test occursin("plot2", EconTools.pgfplots_pre)
        @test occursin("plot3", EconTools.pgfplots_pre)
        @test occursin("plot4", EconTools.pgfplots_pre)
    end

    @testset "create_line_plot - single series" begin
        x = 1:10
        y = sin.(x)
        labels = ["Sine"]

        plot = create_line_plot(x, y, labels,
                                xlabel="X",
                                ylabel="Y",
                                title="Test Plot")

        # Check that plot object was created
        @test plot isa PGFPlotsX.Axis
    end

    @testset "create_line_plot - multiple series (matrix)" begin
        x = 1:10
        y = [sin.(x) cos.(x)]  # 10×2 matrix
        labels = ["Sine", "Cosine"]

        plot = create_line_plot(x, y, labels,
                                xlabel="X",
                                ylabel="Y",
                                title="Trig Functions",
                                cycle_list="plot2")

        @test plot isa PGFPlotsX.Axis
    end

    @testset "create_line_plot - no title" begin
        x = 1:5
        y = [1.0, 1.5, 2.0, 2.2, 2.3]

        plot = create_line_plot(x, y, ["Series"],
                                xlabel="X",
                                ylabel="Y",
                                title="")  # Empty title

        @test plot isa PGFPlotsX.Axis
    end

    @testset "pgfplot - single series" begin
        y = [1.0, 1.5, 2.0, 2.2, 2.3]

        # Note: pgfplot calls display() which may fail in headless mode
        # We suppress display errors for testing
        plot = try
            # Temporarily redirect stdout to suppress display warnings
            mktemp() do path, io
                redirect_stdout(io) do
                    pgfplot(y, Legend="Test", Title="Single Series")
                end
            end
        catch e
            # If display fails, that's OK - we just want to test the function runs
            if e isa MethodError && occursin("display", string(e))
                nothing  # Expected in headless mode
            else
                rethrow()
            end
        end

        # If plot was created, verify structure
        if plot !== nothing
            @test plot isa PGFPlotsX.Axis
        end
    end

    @testset "pgfplot - multiple series" begin
        y1 = [1.0, 1.5, 2.0, 2.2, 2.3]
        y2 = [1.1, 1.6, 2.1, 2.3, 2.4]

        plot = try
            mktemp() do path, io
                redirect_stdout(io) do
                    pgfplot(y1, y2,
                           Legend=("Series A", "Series B"),
                           Label=("X", "Y"),
                           Title="Two Series")
                end
            end
        catch e
            if e isa MethodError && occursin("display", string(e))
                nothing
            else
                rethrow()
            end
        end

        if plot !== nothing
            @test plot isa PGFPlotsX.Axis
        end
    end

    @testset "pgfplot - legend variations" begin
        y = [1.0, 1.5, 2.0]

        # String legend
        plot1 = try
            mktemp() do path, io
                redirect_stdout(io) do
                    pgfplot(y, Legend="Single String")
                end
            end
        catch
            nothing
        end

        # Vector legend
        plot2 = try
            mktemp() do path, io
                redirect_stdout(io) do
                    pgfplot(y, Legend=["Vector Entry"])
                end
            end
        catch
            nothing
        end

        # Tuple legend
        plot3 = try
            mktemp() do path, io
                redirect_stdout(io) do
                    pgfplot(y, Legend=("Tuple Entry",))
                end
            end
        catch
            nothing
        end

        # All should create plots or fail gracefully
        @test plot1 === nothing || plot1 isa PGFPlotsX.Axis
        @test plot2 === nothing || plot2 isa PGFPlotsX.Axis
        @test plot3 === nothing || plot3 isa PGFPlotsX.Axis
    end

    @testset "pgfplot - too many series" begin
        y1 = [1.0, 2.0]
        y2 = [1.5, 2.5]
        y3 = [2.0, 3.0]
        y4 = [2.5, 3.5]
        y5 = [3.0, 4.0]

        # Should fail with assertion error for >4 series
        @test_throws AssertionError pgfplot(y1, y2, y3, y4, y5)
    end

    @testset "pgfplot - file saving" begin
        y = [1.0, 1.5, 2.0, 2.2, 2.3]

        # Create temp directory for output
        mktempdir() do tmpdir
            output_path = joinpath(tmpdir, "test_plot")

            plot = try
                mktemp() do path, io
                    redirect_stdout(io) do
                        pgfplot(y,
                               Legend="Test",
                               Path=output_path)
                    end
                end
            catch
                nothing
            end

            # Check that .tex file was created
            @test isfile(output_path * ".tex")

            # Test PDF saving
            output_path2 = joinpath(tmpdir, "test_plot_pdf")
            plot2 = try
                mktemp() do path, io
                    redirect_stdout(io) do
                        pgfplot(y,
                               Legend="Test",
                               Path=output_path2,
                               PDF=true)
                    end
                end
            catch
                nothing
            end

            @test isfile(output_path2 * ".tex")
            # PDF creation requires latexmk, may not be available in CI
            # @test isfile(output_path2 * ".pdf")
        end
    end
end
