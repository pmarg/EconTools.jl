using Plots, PGFPlotsX
import StatsBase: dof_residual
import GLM: lm, @formula, coef, stderror
import Distributions: FDist, ccdf
import DataFrames: DataFrame


"""
    scatterplot(x,y)
Returns a scatter plot with a fitted line. The estimation uses GLM.jl
"""
function scatterplot(x,y)

    data=DataFrame(X=x,Y=y)
    ols = lm(@formula(Y ~ X), data)
    α = round(coef(ols)[1],2)
    β = round(coef(ols)[2],2)
    σ= stderror(ols)[2]
    t = β/σ
    Pval = round(ccdf.(FDist(1, dof_residual(ols)), abs2.(t)),3)
    fitted(α,β,x) = α + β*x
    X = linspace(minimum(x),maximum(x),2)
    p1 = scatter(x,y,label="")
    if β>0
        p1 = plot!(X,fitted(α,β,X),label="y=$α +$β*x \n (Pval=$Pval)")
    else
        p1 = plot!(X,fitted(α,β,X),label="y=$α $β*x \n (Pval=$Pval)")
    end
    return p1
end


"""
    pgfplots_scatter(x,y;Title="Title",x_label="X",y_label="Y")
Returns a PGFPlots scatter plot with a fitted line. The estimation uses GLM.jl
"""
function pgfplots_scatter(x,y;Title="Title",x_label="X",y_label="Y")
    data=DataFrame(X=x,Y=y)
    ols = lm(@formula(Y ~ X), data)
    α = round(coef(ols)[1],2)
    β = round(coef(ols)[2],2)
    σ= stderror(ols)[2]
    t = β/σ
    Pval = round(ccdf.(FDist(1, dof_residual(ols)), abs2.(t)),3)
    X = linspace(minimum(x),maximum(x),2)
    c=Coordinates(x,y)
    min=minimum(x)
    max=maximum(x)
    if β>0
        figure=@pgf TikzPicture(
            Axis(
                {
                title = Title,
                xlabel= x_label,
                ylabel=y_label,
                },
                PlotInc({domain = "$min:$max"},Expression("$α +($β)*x")),
                LegendEntry("y=$α+($β)x (Pval=$Pval)"),
                PlotInc({scatter,"only marks","mark options={scale=0.5,solid,black}"},c)
                ))
            else
                figure=@pgf TikzPicture(
                    Axis(
                        {
                        title = Title,
                        xlabel= x_label,
                        ylabel=y_label,
                        },
                        PlotInc({domain = "$min:$max"},Expression("$α +($β)*x")),
                        LegendEntry("y=$α ($β)x (Pval=$Pval)"),
                        PlotInc({scatter,"only marks","mark options={scale=0.5,solid},black"},c)
                        ))
            end
            return figure

end


function plot_descriptive(table,var::String,bycolumns::Tuple;weight="None",select="MEAN")
    if weight=="None"
        y= groupby(@NT(
        MEAN=mean,
        STD=std,
        Q25=z->quantile(z,0.25),
        MEDIAN = median,
        Q75=z->quantile(z,0.25)
        ),
        table,bycolumns,select=Symbol(var))
    else
        y= groupby(@NT(
        MEAN=z->mean(column(z,Symbol(var)),weights(column(z,Symbol(weight)))),
        STD=z->std(column(z,Symbol(var)),weights(column(z,Symbol(weight))), corrected=false),
        Q25=z->quantile(column(z,Symbol(var)),0.25),
        MEDIAN=z->median(column(z,Symbol(var)),weights(column(z,Symbol(weight)))),
        Q75=z->quantile(column(z,Symbol(var)),0.75)
        ),
        table,bycolumns,select=(Symbol(var),Symbol(weight)))
    end
    x = select(y,Symbol(select))
    plot(x)
end

function plot_descriptive(table,var::String,bycolumn::Symbol;weight="None")
    if weight=="None"
        y= groupby(@NT(
        MEAN=mean,
        STD=std,
        Q25=z->quantile(z,0.25),
        MEDIAN = median,
        Q75=z->quantile(z,0.25)
        ),
        table,bycolumn,select=Symbol(var))
    else
        y= groupby(@NT(
        MEAN=z->mean(column(z,Symbol(var)),weights(column(z,Symbol(weight)))),
        STD=z->std(column(z,Symbol(var)),weights(column(z,Symbol(weight))), corrected=false),
        Q25=z->quantile(column(z,Symbol(var)),0.25),
        MEDIAN=z->median(column(z,Symbol(var)),weights(column(z,Symbol(weight)))),
        Q75=z->quantile(column(z,Symbol(var)),0.75)
        ),
        table,bycolumn,select=(Symbol(var),Symbol(weight)))
    end
    x = select(y,:MEAN)
    plot(x)
end

function plot_descriptive!(table,var::String,bycolumns::Tuple;weight="None")
    if weight=="None"
        y= groupby(@NT(
        MEAN=mean,
        STD=std,
        Q25=z->quantile(z,0.25),
        MEDIAN = median,
        Q75=z->quantile(z,0.25)
        ),
        table,bycolumns,select=Symbol(var))
    else
        y= groupby(@NT(
        MEAN=z->mean(column(z,Symbol(var)),weights(column(z,Symbol(weight)))),
        STD=z->std(column(z,Symbol(var)),weights(column(z,Symbol(weight))), corrected=false),
        Q25=z->quantile(column(z,Symbol(var)),0.25),
        MEDIAN=z->median(column(z,Symbol(var)),weights(column(z,Symbol(weight)))),
        Q75=z->quantile(column(z,Symbol(var)),0.75)
        ),
        table,bycolumns,select=(Symbol(var),Symbol(weight)))
    end
    x = select(y,:MEAN)
    plot!(x)
end

function plot_descriptive!(table,var::String,bycolumn::Symbol;weight="None")
    if weight=="None"
        y= groupby(@NT(
        MEAN=mean,
        STD=std,
        Q25=z->quantile(z,0.25),
        MEDIAN = median,
        Q75=z->quantile(z,0.25)
        ),
        table,bycolumn,select=Symbol(var))
    else
        y= groupby(@NT(
        MEAN=z->mean(column(z,Symbol(var)),weights(column(z,Symbol(weight)))),
        STD=z->std(column(z,Symbol(var)),weights(column(z,Symbol(weight))), corrected=false),
        Q25=z->quantile(column(z,Symbol(var)),0.25),
        MEDIAN=z->median(column(z,Symbol(var)),weights(column(z,Symbol(weight)))),
        Q75=z->quantile(column(z,Symbol(var)),0.75)
        ),
        table,bycolumn,select=(Symbol(var),Symbol(weight)))
    end
    x = select(y,:MEAN)
    plot!(x)
end
