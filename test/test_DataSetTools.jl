using JuliaDB

t=table([1.0,2.0,3.0], [1.0,1.0,1.0], [1.0,1.0,1.0],[1.0,1.0,1.0],names=[:x,:y,:z,:w]);
d_t = descriptive_stats(t,"x",(:y,:z))
d_t_w = descriptive_stats(t,"x",(:y,:z),weight="w")

d = descriptive_stats(t,"x",:z)

d_w = descriptive_stats(t,"x",:z,weight="w")

@test select(d_t,:avg) == [2.0]

@test select(d_t_w,:avg) == [2.0]

@test select(d,:avg) == [2.0]

@test select(d_w,:avg) == [2.0]
