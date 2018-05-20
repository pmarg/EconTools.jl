# Tests
x = rand(10)
y = rand(10)

@test scatterplot(x1,x2) isa(Plots.Plot)
