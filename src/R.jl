function load_rds(path)
    R"""
    res<-readRDS($path)
    """
    @rget res
end

function save_rds(file,path)
    @rput file
    R"""
    saveRDS($file, file = $path)
    """
end

function svyby(var,by;fun="svymean",dsgn="dsgn")
    reval(" res<-svyby(~$var, by = ~$by, FUN = $fun, design = $dsgn)")
    @rget res
    rename!(res, Symbol("$var") => :Mean)
end
function svyby(var,by1,by2;fun="svymean",dsgn="dsgn")
    reval(" res<-svyby(~$var, by = ~$by1+$by2, FUN = $fun, design = $dsgn)")
    @rget res
    rename!(res, Symbol("$var") => :Mean)
end

function initialize_survey(path,id,strata,weights)
    R"""
       library(Matrix)
       library(survival)
       library(survey)
       data = readRDS($path)
       options(survey.lonely.psu='adjust')
       """
       reval(" dsgn = svydesign(id = ~$(id),
                         strata = ~$(strata),
                         weights = ~$(weights),
                         data = data,
                         nest = TRUE)"
                         )
end
