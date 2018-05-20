using Plots
import StatsBase: dof_residual
import GLM: lm, @formula, coef, stderror
import Distributions: FDist, ccdf
import DataFrames: DataFrame


"""
    scatterplot(x,y)
Returns a scatter plot with a fitted line. The estimation uses GLM.jl
"""
function scatterplot(x,y)

    data=DataFrame(X=x,Y=x)
    ols = lm(@formula(Y ~ X), data)
    α = round(coef(ols)[1],2)
    β = round(coef(ols)[2],2)
    σ= stderror(ols)[2]
    t = β/σ
    Pval = round(ccdf.(FDist(1, dof_residual(ols)), abs2.(t)),3)
    fitted(α,β,x) = α + β*x
    X = linspace(minimum(x),maximum(x),2)
    p1 = scatter(x,y,label="")
    p1 = plot!(X,fitted(α,β,X),label="$α +$β*X \n (Pval=$Pval)")
    return p1
end
