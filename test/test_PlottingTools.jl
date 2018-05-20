# Tests
using PGFPlotsX
x1 = linspace(1,10,10)
y1 = linspace(1,10,10)
y2 = linspace(10,0,10)

@test scatterplot(x1,y1) isa(Plots.Plot)
@test scatterplot(x1,y2) isa(Plots.Plot)

@test pgfplots_scatter(x1,y1) isa(PGFPlotsX.TikzPicture)
@test pgfplots_scatter(x1,y2) isa(PGFPlotsX.TikzPicture)
