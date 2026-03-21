# Test LaTeX output functions

@testset "LaTeX Table Generation" begin
    @testset "save_latex_table - basic" begin
        df = DataFrame(
            Cluster = ["Hot", "Neutral", "Cold"],
            HS = [29.31, 29.11, 28.48],
            College = [28.11, 27.45, 26.95]
        )

        mktempdir() do tmpdir
            filepath = joinpath(tmpdir, "test_table.tex")

            save_latex_table(df, filepath,
                           caption="Test Table",
                           label="test_tab",
                           format_cols=[2, 3])

            @test isfile(filepath)

            # Read and check content
            content = read(filepath, String)
            @test occursin("\\begin{table}", content)
            @test occursin("\\caption{Test Table}", content)
            @test occursin("\\label{tab:test_tab}", content)
            @test occursin("\\begin{threeparttable}", content)
            @test occursin("Hot", content)
            @test occursin("29.31", content)
        end
    end

    @testset "save_latex_table - with notes and source" begin
        df = DataFrame(
            Variable = ["Mean", "Median", "SD"],
            Value = [28.5, 28.2, 3.4]
        )

        mktempdir() do tmpdir
            filepath = joinpath(tmpdir, "test_notes.tex")

            save_latex_table(df, filepath,
                           caption="Summary Statistics",
                           label="summary",
                           notes=["Sample restricted to ages 25-65."],
                           source="HRS (1998-2018)",
                           format_cols=[2])

            @test isfile(filepath)

            content = read(filepath, String)
            @test occursin("\\begin{tablenotes}", content)
            @test occursin("Sample restricted", content)
            @test occursin("\\emph{Source:} HRS", content)
        end
    end

    @testset "save_latex_table - nested headers" begin
        df = DataFrame(
            Type = ["Type 1", "Type 2"],
            HS_Model = [28.5, 29.1],
            HS_Data = [28.3, 28.9],
            College_Model = [26.5, 27.1],
            College_Data = [26.3, 26.9]
        )

        mktempdir() do tmpdir
            filepath = joinpath(tmpdir, "test_nested.tex")

            save_latex_table(df, filepath,
                           caption="Model vs Data",
                           label="comparison",
                           header_groups=[
                               (label="High School", span=2),
                               (label="College", span=2)
                           ],
                           format_cols=[2, 3, 4, 5])

            @test isfile(filepath)

            content = read(filepath, String)
            @test occursin("\\multicolumn{2}{c}{High School}", content)
            @test occursin("\\multicolumn{2}{c}{College}", content)
            @test occursin("\\cmidrule", content)
        end
    end

    @testset "save_latex_table - custom alignment" begin
        df = DataFrame(
            A = ["x", "y"],
            B = [1, 2],
            C = [3, 4]
        )

        mktempdir() do tmpdir
            filepath = joinpath(tmpdir, "test_align.tex")

            save_latex_table(df, filepath,
                           caption="Custom Alignment",
                           label="align",
                           col_align="lrr")

            @test isfile(filepath)

            content = read(filepath, String)
            @test occursin("lrr", content)
        end
    end

    @testset "save_latex_table_simple" begin
        df = DataFrame(
            X = [1, 2, 3],
            Y = [4.5, 5.5, 6.5]
        )

        mktempdir() do tmpdir
            filepath = joinpath(tmpdir, "simple_table")

            save_latex_table_simple(df, filepath,
                                  "Simple Table",
                                  "simple",
                                  format_cols=[2])

            # Should auto-add .tex extension
            @test isfile(filepath * ".tex")

            content = read(filepath * ".tex", String)
            @test occursin("Simple Table", content)
            @test occursin("tab:simple", content)
        end
    end

    @testset "format_number" begin
        # Test basic formatting
        @test format_number(1234.567, decimals=2) == "1,234.57"
        @test format_number(0.12345, decimals=4) == "0.1235"
        @test format_number(999.9, decimals=1) == "999.9"

        # Test thousands separator
        @test format_number(1000000.5, decimals=1) == "1,000,000.5"
        @test format_number(123, decimals=0) == "123"

        # Test missing values
        @test format_number(missing) == "--"

        # Test without thousands separator
        @test format_number(1234.5, decimals=1, thousands_sep=false) == "1234.5"
    end
end

@testset "LaTeX Figure Generation" begin
    @testset "save_pgfplot - basic" begin
        x = 1:5
        y = [1.0, 1.5, 2.0, 2.2, 2.3]
        plot = create_line_plot(x, y, ["Test"],
                               xlabel="X", ylabel="Y")

        mktempdir() do tmpdir
            filepath = joinpath(tmpdir, "test_fig.tex")

            save_pgfplot(plot, filepath,
                        caption="Test Figure",
                        label="test_fig",
                        standalone=false)

            @test isfile(filepath)

            content = read(filepath, String)
            # Non-standalone should just have the axis, no figure environment
            @test occursin("\\begin{axis}", content)
        end
    end

    @testset "save_pgfplot - standalone" begin
        x = 1:5
        y = [1.0, 1.5, 2.0, 2.2, 2.3]
        plot = create_line_plot(x, y, ["Test"],
                               xlabel="X", ylabel="Y")

        mktempdir() do tmpdir
            filepath = joinpath(tmpdir, "test_standalone.tex")

            save_pgfplot(plot, filepath,
                        caption="Standalone Figure",
                        label="standalone",
                        notes=["This is a note."],
                        source="Test data",
                        standalone=true)

            @test isfile(filepath)

            content = read(filepath, String)
            @test occursin("\\begin{figure}", content)
            @test occursin("\\caption{Standalone Figure}", content)
            @test occursin("\\label{fig:standalone}", content)
            @test occursin("This is a note", content)
            @test occursin("\\emph{Source:} Test data", content)
        end
    end

    @testset "save_pgfplot_simple" begin
        x = 1:3
        y = [1.0, 2.0, 3.0]
        plot = create_line_plot(x, y, ["Data"], xlabel="X", ylabel="Y")

        mktempdir() do tmpdir
            filepath = joinpath(tmpdir, "simple_fig")

            save_pgfplot_simple(plot, filepath,
                              "Simple Figure",
                              "simple_fig")

            # Should auto-add .tex extension
            @test isfile(filepath * ".tex")

            content = read(filepath * ".tex", String)
            # Simple version is non-standalone
            @test !occursin("\\begin{figure}", content)
            @test occursin("\\begin{axis}", content)
        end
    end
end
