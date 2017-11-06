**  ---------------------------------------------------------------------------------------------  **
**  ---------------------------------------------------------------------------------------------  **
**  ---  second article of the thesis - extensive margin of international trade for Mercosur  ---  **
**  ---                      by Erik Figueiredo and Alexandre Loures                          ---  **
**  ---                      Joao Pessoa, Paraiba, Brazil 2015/09/23                          ---  **
**  ---------------------------------------------------------------------------------------------  **
**  ---------------------------------------------------------------------------------------------  **


** article available in : https://www.researchgate.net/publication/305485838


use "C:\Users\Inspiron\Documents\MEGA\thesis_project\essay\mercosur\base\stage\second_stage\expand1.dta", clear


**  ------------------------------------------------  **
**  transforming the dependent varaibale into binary  **
**  ------------------------------------------------  **

gen y = cond((trade > 0),1,0)
label variable y "y"


**  ---------------------------------------------------------------------  **
**  creating the dummies variables for the estimation and for the graph 3  **
**  ---------------------------------------------------------------------  **

gen sur11 = cond((ido == "BRA" & idd == "ARG" | ido == "BRA" & idd == "PRY" | ido == "BRA" & idd == "URY" | ido == "BRA" & idd == "VEN" | ///
				  ido == "ARG" & idd == "BRA" | ido == "ARG" & idd == "PRY" | ido == "ARG" & idd == "URY" | ido == "ARG" & idd == "VEN" | ///
				  ido == "PRY" & idd == "BRA" | ido == "PRY" & idd == "ARG" | ido == "PRY" & idd == "URY" | ido == "PRY" & idd == "VEN" | ///
				  ido == "URY" & idd == "BRA" | ido == "URY" & idd == "ARG" | ido == "URY" & idd == "PRY" | ido == "URY" & idd == "VEN" |///
				  ido == "VEN" & idd == "BRA" | ido == "VEN" & idd == "ARG" | ido == "VEN" & idd == "PRY" | ido == "VEN" & idd == "URY"),1,0)
label variable sur11 "sur11"

gen sur10 = cond((ido == "BRA" & idd == "BOL" | ido == "BRA" & idd == "CHL" | ido == "BRA" & idd == "PER" | ///
				  ido == "ARG" & idd == "BOL" | ido == "ARG" & idd == "CHL" | ido == "ARG" & idd == "PER" | ///
				  ido == "PRY" & idd == "BOL" | ido == "PRY" & idd == "CHL" | ido == "PRY" & idd == "PER" | ///
				  ido == "URY" & idd == "BOL" | ido == "URY" & idd == "CHL" | ido == "URY" & idd == "PER" | ///
				  ido == "VEN" & idd == "BOL" | ido == "VEN" & idd == "CHL" | ido == "VEN" & idd == "PER"),1,0)
label variable sur10 "sur10"

gen sur01 = cond((ido == "BOL" & idd == "ARG" | ido == "BOL" & idd == "BRA" | ido == "BOL" & idd == "PRY" | ido == "BOL" & idd == "URY" | ido == "BOL" & idd == "VEN" | ///
		          ido == "CHL" & idd == "ARG" | ido == "CHL" & idd == "BRA" | ido == "CHL" & idd == "PRY" | ido == "CHL" & idd == "URY" | ido == "CHL" & idd == "VEN" | ///
			      ido == "PER" & idd == "ARG" | ido == "PER" & idd == "BRA" | ido == "PER" & idd == "PRY" | ido == "PER" & idd == "URY" | ido == "PER" & idd == "VEN"),1,0)
label variable sur01 "sur01"

gen sur00 = cond((ido == "BOL" & idd == "CHL" | ido == "BOL" & idd == "PER" | ///
		          ido == "CHL" & idd == "BOL" | ido == "CHL" & idd == "PER" | ///
			      ido == "PER" & idd == "CHL" | ido == "PER" & idd == "BOL"),1,0)
label variable sur00 "sur00"


**  -------------------------------------------------  **
**  creating the dummies variables for the estimation  **
**  -------------------------------------------------  **

gen sur91 = cond((ido == "BRA" & idd == "ARG" & year > 1990 | ido == "BRA" & idd == "PRY" & year > 1990 | ido == "BRA" & idd == "URY" & year > 1990 | ido == "BRA" & idd == "VEN" & year > 1990 | ///
		          ido == "ARG" & idd == "BRA" & year > 1990 | ido == "ARG" & idd == "PRY" & year > 1990 | ido == "ARG" & idd == "URY" & year > 1990 | ido == "ARG" & idd == "VEN" & year > 1990 | ///
			      ido == "PRY" & idd == "BRA" & year > 1990 | ido == "PRY" & idd == "ARG" & year > 1990 | ido == "PRY" & idd == "URY" & year > 1990 | ido == "PRY" & idd == "VEN" & year > 1990 | ///
			      ido == "URY" & idd == "BRA" & year > 1990 | ido == "URY" & idd == "ARG" & year > 1990 | ido == "URY" & idd == "PRY" & year > 1990 | ido == "URY" & idd == "VEN" & year > 1990 | ///
				  ido == "VEN" & idd == "BRA" & year > 1990 | ido == "VEN" & idd == "ARG" & year > 1990 | ido == "VEN" & idd == "URY" & year > 1990 | ido == "VEN" & idd == "PRY" & year > 1990),1,0)
label variable sur91 "mercosur"

gen border = cond((ido == "BRA" & idd == "ARG" | ido == "BRA" & idd == "URY" | ido == "BRA" & idd == "PRY" | ido == "BRA" & idd == "BOL" | ido == "BRA" & idd == "PER" | ido == "BRA" & idd == "VEN" | ///
                   ido == "ARG" & idd == "BRA" | ido == "ARG" & idd == "PRY" | ido == "ARG" & idd == "URY" | ido == "ARG" & idd == "BOL" | ido == "ARG" & idd == "CHL" | ///
				   ido == "URY" & idd == "BRA" | ido == "URY" & idd == "ARG" | ///
				   ido == "PRY" & idd == "BRA" | ido == "PRY" & idd == "BOL" | ido == "PRY" & idd == "ARG" | ///
				   ido == "VEN" & idd == "BRA" | ///
				   ido == "BOL" & idd == "BRA" | ido == "BOL" & idd == "PRY" | ido == "BOL" & idd == "ARG" | ido == "BOL" & idd == "CHL" | ido == "BOL" & idd == "PER" | ///
				   ido == "CHL" & idd == "PER" | ido == "CHL" & idd == "BOL" | ido == "CHL" & idd == "ARG" | ///
				   ido == "PER" & idd == "BRA" | ido == "PER" & idd == "BOL" | ido == "PER" & idd == "CHL"),1,0)
label variable border "border"

gen lang = cond((ido == "ARG" & idd == "PRY" | ido == "ARG" & idd == "URY" | ido == "ARG" & idd == "BOL" | ido == "ARG" & idd == "CHL" | ido == "ARG" & idd == "PER" | ido == "ARG" & idd == "VEN" | ///
                 ido == "PRY" & idd == "ARG" | ido == "PRY" & idd == "URY" | ido == "PRY" & idd == "BOL" | ido == "PRY" & idd == "CHL" | ido == "PRY" & idd == "PER" | ido == "PRY" & idd == "VEN" | ///
			     ido == "URY" & idd == "ARG" | ido == "URY" & idd == "PRY" | ido == "URY" & idd == "BOL" | ido == "URY" & idd == "CHL" | ido == "URY" & idd == "PER" | ido == "URY" & idd == "VEN" | ///
			     ido == "BOL" & idd == "ARG" | ido == "BOL" & idd == "PRY" | ido == "BOL" & idd == "URY" | ido == "BOL" & idd == "CHL" | ido == "BOL" & idd == "PER" | ido == "BOL" & idd == "VEN" | ///
			     ido == "CHL" & idd == "ARG" | ido == "CHL" & idd == "PRY" | ido == "CHL" & idd == "BOL" | ido == "CHL" & idd == "URY" | ido == "CHL" & idd == "PER" | ido == "CHL" & idd == "VEN" | ///
			     ido == "PER" & idd == "ARG" | ido == "PER" & idd == "PRY" | ido == "PER" & idd == "BOL" | ido == "PER" & idd == "CHL" | ido == "PER" & idd == "URY" | ido == "PER" & idd == "VEN" | ///
				 ido == "VEN" & idd == "ARG" | ido == "VEN" & idd == "PRY" | ido == "VEN" & idd == "BOL" | ido == "VEN" & idd == "CHL" | ido == "VEN" & idd == "URY" | ido == "VEN" & idd == "PER"),1,0)
label variable lang "comlang"


**  --------------------------------------  **
**  getting the neperian from the distance  **
**  --------------------------------------  **

gen ldist = log(dist)
label variable ldist "ldist"


**  -----------------------------------------------  **
**  generating the terms of multilateral resistance  **
**  -----------------------------------------------  **

xi, pre(F_1) i.ido*i.year
xi, pre(F_2) i.idd*i.year


**  ---------------------------------------------------  **
**  creating the group of regressors for the estimation  **
**  ---------------------------------------------------  **

global xlist0 sur11 sur91 ldist border lang F_*
global xlist1 sur11 sur10 sur01 ldist border lang F_*
global xlist2 sur11 sur10 sur01 F_*
global xlist3 sur11 sur91 F_*


**  -----------------------------------------------------------  **
**  logit model estimation with robust errors for heterogeneity  **
**  -----------------------------------------------------------  **

logit y $xlist0, vce(r)
eststo mm1

esttab mm1 using C:\Users\Inspiron\Desktop\logitG1.doc, b(4) se(4) star(*** 0.1 ** 0.05 * 0.01) ///
title(Resultados) replace rtf label nonumbers drop (F_*)

mfx, predict() varlist(sur11 sur91 ldist border lang)  /*  marginal effect  */
