using PGFPlotsX
pgfplots_pre = "
\\usepgfplotslibrary{fillbetween}
\\definecolor{airforceblue}{rgb}{0.36, 0.54, 0.66}
\\definecolor{amaranth}{rgb}{0.9, 0.17, 0.31}
\\definecolor{asparagus}{rgb}{0.53, 0.66, 0.42}
\\definecolor{cadmiumorange}{rgb}{0.93, 0.53, 0.18}
\\definecolor{color1}{RGB}{0.0, 0.0, 0.0}
\\definecolor{color2}{RGB}{191, 191, 191}
\\definecolor{color3}{RGB}{140, 140, 140}
\\definecolor{color4}{RGB}{89, 89, 89}



\\pgfplotscreateplotcyclelist{plot2}{%
no marks,very thick,color = airforceblue\\\\%1
no marks,very thick,color = cadmiumorange\\\\%2
}
\\pgfplotscreateplotcyclelist{plot3}{%
no marks,very thick,color = cadmiumorange\\\\%2
no marks,very thick,color = asparagus\\\\%3
no marks,very thick,color = airforceblue\\\\%1
}
\\pgfplotscreateplotcyclelist{plot4}{%
no marks,very thick,color = airforceblue\\\\%1
no marks,very thick,color = cadmiumorange\\\\%2
no marks,very thick,color = asparagus\\\\%3
no marks,very thick,color = amaranth\\\\%4
}
\\pgfplotscreateplotcyclelist{pgs3}{%
no marks,very thick,color = airforceblue\\\\%1 Low
no marks,very thick,color = asparagus\\\\%2 Med
no marks,very thick,color = cadmiumorange\\\\%3 High
}
\\pgfplotscreateplotcyclelist{edu2}{%
no marks,very thick,color = amaranth\\\\%1 HS
no marks,very thick,color = airforceblue\\\\%2 College
}
\\pgfplotscreateplotcyclelist{grayscale}{%
no marks,very thick,color = color1\\\\%1
no marks,very thick,color = color2\\\\%2
no marks,very thick,dashed,color = color1\\\\%3
no marks,very thick,dashed,color = color2\\\\%3
}"
push!(PGFPlotsX.CUSTOM_PREAMBLE, pgfplots_pre)
export pgfplots_pre
