# Tests
x = rand(10)
y = rand(10)

@test scatterplot(x,y) isa(Plots.Plot)
