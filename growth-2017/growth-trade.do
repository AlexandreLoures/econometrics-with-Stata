**  -----------------------------------------------------------------------------------------  **
**  -----------------------------------------------------------------------------------------  **
/*  ---  third article of the thesis - model of Anderson, Larch and Yotov (growth-trade)  ---  */
/*  ---                    by Erik Figueiredo and Alexandre Loures                        ---  */
/*  ---                    Joao Pessoa, Paraiba, Brazil 2016/11/13                        ---  */
**  -----------------------------------------------------------------------------------------  **
**  -----------------------------------------------------------------------------------------  **


** article available in: https://www.researchgate.net/publication/320094852

clear all



**  ----------------------------------  **
/*               1º STEP:               */
**  ----------------------------------  **

/*  
loading the Comtrade base
*/

use "C:\Users\Inspiron\OneDrive\quantitative_methods_applied\thesis_project\essay\growth_trade\base\expand-geppml.dta", clear

set more off
set matsize 7500



**  ----------------------------------  **
/*               2º STEP:               */
**  ----------------------------------  **

/*
making the merge between the Comtrade base and the BACI base to obtain the data on the standard variables of the gravitational model (dist, cntg, lang and clny)
*/

merge m:m ido idd using "C:\Users\Inspiron\OneDrive\quantitative_methods_applied\thesis_project\essay\growth_trade\base\dist_cepii.dta"

drop if _merge == 1
drop if _merge == 2
drop _merge

drop comlang_ethno comcol curcol col45 smctry distcap distw distwces

rename contig cntg
rename comlang_off lang
rename colony clny

gen ldist = log(dist)
label variable ldist "ln(distance)"



**  ----------------------------------  **
/*               3º STEP:               */
**  ----------------------------------  **

/*
making the merge between the previous base and the Larch base to obtain data on regional trade agreements (RTAs)
*/

merge m:m year ido idd using "C:\Users\Inspiron\OneDrive\quantitative_methods_applied\thesis_project\essay\growth_trade\base\rta-Larch.dta"

drop if _merge == 2
drop _merge



**  ----------------------------------  **
/*               4º STEP:               */
**  ----------------------------------  **

/*
choosing the period for the analysis
*/

keep if year > 1995
keep if year < 2015



**  ----------------------------------  **
/*               5º STEP:               */
**  ----------------------------------  **

/*
selecting countries of interest in the sample
*/

/*  TOTAL 13 SOURCE COUNTRIES  */

keep if ido == "ARG" | ido == "BRA" | ido == "CHN" | ido == "COL" | ido == "IND" | ido == "IDN" | ido == "MYS" | ido == "MEX" | ido == "PER" | ido == "PHL" | ido == "ZAF" | ///
        ido=="THA" | ido=="TUR"

		
/* TOTAL 31 DESTINATION COUNTRIES */

keep if idd == "AUS" | idd == "BRA" | idd == "CHN" | idd == "JPN" | idd == "IND" | idd == "MYS" | idd == "MEX" | idd == "ZAF" | idd == "THA" | idd == "TUR" | idd == "KOR" | ///
        idd == "USA" | idd == "CAN" | idd == "AUT" | idd == "DNK" | idd == "FRA" | idd == "FIN" | idd == "DEU" | idd == "GRC" | idd == "IRL" | idd == "ITA" | idd == "NLD" | ///
		idd == "PRT" | idd == "ESP" | idd == "SWE" | idd == "GBR" | idd == "ARG" | idd == "COL" | idd == "IDN" | idd == "PER" | idd == "PHL"



**  ----------------------------------  **
/*               6º STEP:               */
**  ----------------------------------  **

/*  CREATING THE VARIABLES PRODUCT AND EXPENDITURES  */

/*  

* making the merge between the previous base and the PENN 9.0 base (considering only the countries of origin)
* this data will also be used in the regression of the production function  */

merge m:m year ido using "C:\Users\Inspiron\OneDrive\quantitative_methods_applied\thesis_project\essay\growth_trade\base\pwt90ido.dta"

drop if _merge == 2
drop _merge

/*  

* making the merge between the previous base and the PENN 9.0 base (considering only the countries of destination)
* this data will also be used in the regression of the capital accumulation function  */

merge m:m year idd using "C:\Users\Inspiron\OneDrive\quantitative_methods_applied\thesis_project\essay\growth_trade\base\pwt90idd.dta"

drop if _merge == 2
drop _merge

/* creating the variable product  */

gen output = rgdpna_ido
label variable output "output for source countries"

/*  creating the variable expenditures  */

bysort year idd: egen expndr = sum (trade)
label variable expndr "expenditures for destination countries"



**  ----------------------------------  **
/*               7º STEP:               */
**  ----------------------------------  **

/*
choosing the numeraire country
*/

/*  

* excluding a fixed effect according to Anderson, Larch and Yotov (2015)
* randomly chosen through the command in software R: sample (13:1, 1, replace = FALSE)  */

replace ido = "ZZZ" if ido == "THA"
replace idd = "ZZZ" if idd == "THA"

gen expndr_tha0 = expndr if idd == "ZZZ"
egen expndr_tha = mean (expndr_tha0)

/*  WARNING:

* RENAMES THE FIXED EFFECT DELETED AS "ZZZ" TO FACILITATE ITS DELETION, AS THIS WILL REMAIN AS THE LAST COUNTRY

* IN THIS ARTICLE, RENAMING THE "THA" AS "ZZZ" WILL LAST, AND THUS PLACING THE FIXED EFFECT IN THE GRAVITACIONAL EQUATION IS ONLY UP TO THE 30th COUNTRY (DO NOT FORGET THAT THERE
  ARE 31 COUNTRIES OF DESTINATION). FOR EXAMPLE, INSTEAD OF F_2iddXyea_1_1996-F_2iddXyea_31_2014, F_2iddXyea_1_1996-F_2iddXyea_30_2014 IS PLACED.

* NOTE THAT INSTEAD OF PLACING EACH FIXED EFFECT SOMETIMES (F_2iddXyea_1_1996 + F_2iddXyea_1_1997 + F_2iddXyea_1_1998 + ... + F_2iddXyea_30_2014) THE (INITIAL-FINAL)INTERVAL OF
  FIXED EFFECTS THAT WILL ENTER THE SEPARATED ESTIMATE BY "-" IS PLACED.  */



**  ----------------------------------  **
/*               8º STEP:               */
**  ----------------------------------  **

/*
creating the effects fixed
*/

xi, pre(F_1) noomit i.ido*i.year
xi, pre(F_2) noomit i.idd*i.year

/*  WARNING:  

* NOTE THAT SINCE STATISTICAL AND ECONOMETRIC SOFTWARE BY DEFAULT DO NOT GENERATE THE FIRST FIXED EFFECT, THE "noomit" COMMAND IS PLACED, THUS GENERATING ALL THE FIXED EFFECTS  */



**  ----------------------------------  **
/*               9º STEP:               */
**  ----------------------------------  **

/*
estimating the specification "baseline" to obtain the terms of resistance
*/

ppml trade rta ldist cntg lang clny F_1idoXyea_* F_2iddXyea_1_1996-F_2iddXyea_30_2014, noconst



**  -----------------------------------  **
/*               10º STEP:               */
**  -----------------------------------  **

/*  
calculating the trade cost per pair of countries (considering an Armington substitution elasticity of 6)
*/

scalar sigma = 6

gen t_ij = exp(_b[rta]*rta + _b[ldist]*ldist + _b[cntg]*cntg + _b[lang]*lang + _b[clny]*clny)^(1/(1 - sigma))  /*  to prove that the cost is greater than or equal to one  */
label variable t_ij "t_ij >= 1"



**  -----------------------------------  **
/*               11º STEP:               */
**  -----------------------------------  **

/*  
generating the vector of the parameters that will be used in the conditional counterfactual of the NAFTA 
*/

clonevar rtac = rta   /*  where rtac is the rta for the counterfactual exercise  */
label variable rtac "set RTA to zero for the NAFTA countries after 1994"

replace rtac = 0 if (ido == "MEX" & idd == "CAN" & year > 1994)  /*  range of our sample 1995-2014  */
replace rtac = 0 if (ido == "MEX" & idd == "USA" & year > 1994)  /*  range of our sample 1995-2014  */

gen cost_nafta = exp(_b[rta]*rtac + _b[ldist]*ldist + _b[cntg]*cntg + _b[lang]*lang + _b[clny]*clny)
label variable cost_nafta "cost of nafta estimation"

gen lcost_nafta = log(cost_nafta)
label variable lcost_nafta "log(cost_nafta)"



**  -----------------------------------  **
/*               12º STEP:               */
**  -----------------------------------  **

/*  
generating the vector of the parameters that will be used in the conditional counterfactual of the hyperglobalization  */

gen cost_gbln = exp(_b[rta]*rta*0 + _b[ldist]*ldist*0 + _b[cntg]*cntg*0 + _b[lang]*lang*0 + _b[clny]*clny*0)
label variable cost_gbln "cost of globalization estimation"

gen lcost_gbln = log(cost_gbln)
label variable lcost_gbln "log(cost_gbln)"



**  -----------------------------------  **
/*               13º STEP:               */
**  -----------------------------------  **

/*
multiplying each vector of fixed effect "ORIGIN" by the exponential of its respective coefficient
*/

/*  --------------------------  */
/*  ALL FIXED EFFECTS EXPORTER  */
/*  --------------------------  */
 
forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_1996 = F_1idoXyea_`i'_1996*exp(_b[F_1idoXyea_`i'_1996])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_1997 = F_1idoXyea_`i'_1997*exp(_b[F_1idoXyea_`i'_1997])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_1998 = F_1idoXyea_`i'_1998*exp(_b[F_1idoXyea_`i'_1998])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_1999 = F_1idoXyea_`i'_1999*exp(_b[F_1idoXyea_`i'_1999])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2000 = F_1idoXyea_`i'_2000*exp(_b[F_1idoXyea_`i'_2000])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2001 = F_1idoXyea_`i'_2001*exp(_b[F_1idoXyea_`i'_2001])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2002 = F_1idoXyea_`i'_2002*exp(_b[F_1idoXyea_`i'_2002])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2003 = F_1idoXyea_`i'_2003*exp(_b[F_1idoXyea_`i'_2003])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2004 = F_1idoXyea_`i'_2004*exp(_b[F_1idoXyea_`i'_2004])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2005 = F_1idoXyea_`i'_2005*exp(_b[F_1idoXyea_`i'_2005])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2006 = F_1idoXyea_`i'_2006*exp(_b[F_1idoXyea_`i'_2006])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2007 = F_1idoXyea_`i'_2007*exp(_b[F_1idoXyea_`i'_2007])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2008 = F_1idoXyea_`i'_2008*exp(_b[F_1idoXyea_`i'_2008])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2009 = F_1idoXyea_`i'_2009*exp(_b[F_1idoXyea_`i'_2009])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2010 = F_1idoXyea_`i'_2010*exp(_b[F_1idoXyea_`i'_2010])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2011 = F_1idoXyea_`i'_2011*exp(_b[F_1idoXyea_`i'_2011])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2012 = F_1idoXyea_`i'_2012*exp(_b[F_1idoXyea_`i'_2012])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2013 = F_1idoXyea_`i'_2013*exp(_b[F_1idoXyea_`i'_2013])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2014 = F_1idoXyea_`i'_2014*exp(_b[F_1idoXyea_`i'_2014])
}




**  -----------------------------------  **
/*               14º STEP:               */
**  -----------------------------------  **

/*
multiplying each vector of fixed effect "DESTINATION" by the exponential of its respective coefficient
*/

/*  --------------------------  */
/*  ALL FIXED EFFECTS IMPORTER  */
/*  --------------------------  */

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_1996 = F_2iddXyea_`i'_1996*exp(_b[F_2iddXyea_`i'_1996])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_1997 = F_2iddXyea_`i'_1997*exp(_b[F_2iddXyea_`i'_1997])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_1998 = F_2iddXyea_`i'_1998*exp(_b[F_2iddXyea_`i'_1998])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_1999 = F_2iddXyea_`i'_1999*exp(_b[F_2iddXyea_`i'_1999])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2000 = F_2iddXyea_`i'_2000*exp(_b[F_2iddXyea_`i'_2000])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2001 = F_2iddXyea_`i'_2001*exp(_b[F_2iddXyea_`i'_2001])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2002 = F_2iddXyea_`i'_2002*exp(_b[F_2iddXyea_`i'_2002])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2003 = F_2iddXyea_`i'_2003*exp(_b[F_2iddXyea_`i'_2003])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2004 = F_2iddXyea_`i'_2004*exp(_b[F_2iddXyea_`i'_2004])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2005 = F_2iddXyea_`i'_2005*exp(_b[F_2iddXyea_`i'_2005])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2006 = F_2iddXyea_`i'_2006*exp(_b[F_2iddXyea_`i'_2006])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2007 = F_2iddXyea_`i'_2007*exp(_b[F_2iddXyea_`i'_2007])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2008 = F_2iddXyea_`i'_2008*exp(_b[F_2iddXyea_`i'_2008])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2009 = F_2iddXyea_`i'_2009*exp(_b[F_2iddXyea_`i'_2009])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2010 = F_2iddXyea_`i'_2010*exp(_b[F_2iddXyea_`i'_2010])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2011 = F_2iddXyea_`i'_2011*exp(_b[F_2iddXyea_`i'_2011])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2012 = F_2iddXyea_`i'_2012*exp(_b[F_2iddXyea_`i'_2012])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2013 = F_2iddXyea_`i'_2013*exp(_b[F_2iddXyea_`i'_2013])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2014 = F_2iddXyea_`i'_2014*exp(_b[F_2iddXyea_`i'_2014])
}



**  -----------------------------------  **
/*               15º STEP:               */
**  -----------------------------------  **

/*
placing all fixed-effect vectors "ORIGIN" baseline on a single vector
*/

egen all_exp_fe0 = rowtotal (F_1idoXyea_*)

/*
placing all fixed-effect vectors "DESTINATION" baseline on a single vector
*/

egen all_imp_fe0 = rowtotal (F_2iddXyea_*)



**  -----------------------------------  **
/*               16º STEP:               */
**  -----------------------------------  **

/*
creating the internal resistances baseline
*/

gen omr_bsln = output*expndr_tha/(all_exp_fe0)  /*  equation 7 Anderson, Larch and Yotov - Estimating General Equilibrium Trade Policy Effects: GE PPML  */
label variable omr_bsln "outward multilateral resistance terms baseline"

/*
creating the external resistances baseline
*/

gen imr_bsln = expndr/(all_imp_fe0*expndr_tha)  /*  equation 8 Anderson, Larch and Yotov - Estimating General Equilibrium Trade Policy Effects: GE PPML  */
label variable imr_bsln "inward multilateral resistance terms baseline"


drop F_*


save C:\Users\Inspiron\Desktop\geppmlA.dta, replace



**  -----------------------------------  **
/*               17º STEP:               */
**  -----------------------------------  **

/*  ---------------------------------------  */
**  ESTIMATING THE SPECIFICATION FOR GROWTH  **
/*  ---------------------------------------  */

clear all

use "C:\Users\Inspiron\Desktop\geppmlA.dta"


set more off
set matsize 7500


replace ido = "THA" if ido == "ZZZ"
replace idd = "THA" if idd == "ZZZ"



/*
creating the variables of interest for the economic growth model  */

qui tab (ido), gen (c_)
qui tab (year), gen (y_)

gen empeffective = emp_ido*hc_ido
label variable empeffective "employment in effective units"

gen ll = log(empeffective)
label variable ll "ln(empeffective)"

gen lk = log(rkna_ido)
label variable lk "ln(capital)"

gen lomr_bsln = log(1/omr_bsln)
label variable lomr_bsln "ln(1/omr_bsln)"

gen lrgdpna_ido = log(rgdpna_ido)
label variable lrgdpna_ido "ln(rgdpna_ido)"



/*
structural constraints of the Cobb-Douglas  */

constraint 1 ll + lk = 1



/*
estimating the Cobb-Douglas unrestricted  */

reg lrgdpna_ido ll lk y_* c_*, vce(boot)



/*
estimating the Cobb-Douglas restricted  */  

cnsreg lrgdpna_ido ll lk y_* c_*, constraint (1) vce(boot)



/*
calculating the R^2 for the restricted Cobb-Douglas  */

predict lrgdpna_idop if e(sample)  /*  source: http://www.stata.com/support/faqs/statisitics/r-squared/  */
corr lrgdpna_ido lrgdpna_idop if e(sample)
di r(rho)^2



/*
structural constraints of the Anderson, Larch and Yotov model  */

constraint 2 ll + lk = 1 + lomr_bsln



/*
estimating the unrestricted structural model equation of Anderson, Larch and Yotov  */

reg lrgdpna_ido ll lk lomr_bsln y_* c_*, vce(boot)



/*
estimating the restricted structural model of Anderson, Larch and Yotov  */

cnsreg lrgdpna_ido ll lk lomr_bsln y_* c_*, constraint (2) vce(boot)



/*
calculating the R^2 for the restricted structural model of Anderson, Larch and Yotov  */

predict lrgdpna_idopA if e(sample)  /*  source: http://www.stata.com/support/faqs/statistics/r-squared/  */
corr lrgdpna_ido lrgdpna_idopA if e(sample)
di r(rho)^2



**  -----------------------------------  **
/*               18º STEP:               */
**  -----------------------------------  **

/*  -----------------------------------------------------  */
/*  ESTIMATING THE SPECIFICATION FOR CAPITAL ACCUMULATION  */
/*  -----------------------------------------------------  */



/*
creating the variables of interest for the capital accumulation model */

qui tab (idd), gen (d_)

gen lk_idd = log(rkna_idd)
label variable lk_idd "log(rkna_idd)"

gen lrgdpna_idd = log(rgdpna_idd)
label variable lrgdpna_idd "log(rgdpna_idd)"

gen limr_bsln = log(imr_bsln)
label variable limr_bsln "ln(imr_bsln)"



/*
creating the "ID" variable to lag the sample  */

egen idcode = group (ido idd)
label variable idcode "code identifier"

xtset idcode year



/*
lag the variables  */

gen lk_idd_1 = L.lk_idd
label variable lk_idd_1 "lag for lrkna_idd"

gen lrgdpna_idd_1 = L.lrgdpna_idd
label variable lrgdpna_idd_1 "lag for lrgdpna_idd"

gen limr_bsln_1 = L.limr_bsln
label variable limr_bsln_1 "lag for limr_bsln"



/*
structural constraints of the Anderson, Larch and Yotov model  */

constraint 3  limr_bsln_1 = - lrgdpna_idd_1
constraint 4 lk_idd_1 = 1 - lrgdpna_idd_1



/*
estimating the unrestricted structural model of Anderson, Larch and Yotov  */

reg lk_idd lrgdpna_idd_1 lk_idd_1 limr_bsln_1 y_* d_*, vce(boot)



/*
estimating the restricted structural model of Anderson, Larch and Yotov  */

cnsreg lk_idd lrgdpna_idd_1 lk_idd_1 limr_bsln_1 y_* d_*, constraint (3 4) vce(boot)  /*  Constraint with Year FE and Country FE  */



/*
calculating the R^2 for the restricted structural model of Anderson, Larch and Yotov  */

predict lk_iddp if e(sample)  /*  source: http://www.stata.com/support/faqs/statistics/r-squared/  */
corr lk_idd lk_iddp if e(sample)
di r(rho)^2


drop c_* y_* d_*


save C:\Users\Inspiron\Desktop\geppmlB.dta, replace



**  --------------------------------------------------------------------------------------------  **
**  --------------------------------------------------------------------------------------------  **
/*  ---  COUNTERFACTUAL   COUNTERFACTUAL   COUNTERFACTUAL   COUNTERFACTUAL   COUNTERFACTUAL  ---  */
**  --------------------------------------------------------------------------------------------  **
**  --------------------------------------------------------------------------------------------  **

clear all

use "C:\Users\Inspiron\Desktop\geppmlB.dta"

set more off
set matsize 7500

replace ido = "ZZZ" if ido == "THA"
replace idd = "ZZZ" if idd == "THA"

xi, pre(F_1) noomit i.ido*i.year
xi, pre(F_2) noomit i.idd*i.year

/*  ---------------------------------------------------------------------  */
/*  ---------------------------------------------------------------------  */
/*  ---  THE WELFARE EFFECTS OF NAFTA   THE WELFARE EFFECTS OF NAFTA  ---  */
/*  ---------------------------------------------------------------------  */
/*  ---------------------------------------------------------------------  */

**  -----------------------------------  **
/*               19º STEP:               */
**  -----------------------------------  **

/*
estimating the specification of "NAFTA" to obtain the terms of resistance of the conditional counterfactual 
*/

ppml trade F_1idoXyea_* F_2iddXyea_1_1996-F_2iddXyea_30_2014, noconst offset(lcost_nafta)

/*  WARNING:

* NOTE THAT THE COEFFICIENTS OF THE CONDITIONAL COUNTERFACTUAL WILL HAVE THE SAME BASELINE ESTIMATION VALUES WILL NOT INCLUDE THE STANDARD VARIABLES OF THE GRAVITATIONAL MODEL.
  IN CONTRAPARTIDE IS PLACED AS OPTION THE TERM offset().  */



**  -----------------------------------  **
/*               20º STEP:               */
**  -----------------------------------  **

/*
multiplying each vector of fixed effect "ORIGIN", NAFTA specification, by the exponential of its respective coefficient
*/

/*  --------------------------  */
/*  ALL FIXED EFFECTS EXPORTER  */
/*  --------------------------  */
 
forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_1996 = F_1idoXyea_`i'_1996*exp(_b[F_1idoXyea_`i'_1996])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_1997 = F_1idoXyea_`i'_1997*exp(_b[F_1idoXyea_`i'_1997])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_1998 = F_1idoXyea_`i'_1998*exp(_b[F_1idoXyea_`i'_1998])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_1999 = F_1idoXyea_`i'_1999*exp(_b[F_1idoXyea_`i'_1999])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2000 = F_1idoXyea_`i'_2000*exp(_b[F_1idoXyea_`i'_2000])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2001 = F_1idoXyea_`i'_2001*exp(_b[F_1idoXyea_`i'_2001])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2002 = F_1idoXyea_`i'_2002*exp(_b[F_1idoXyea_`i'_2002])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2003 = F_1idoXyea_`i'_2003*exp(_b[F_1idoXyea_`i'_2003])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2004 = F_1idoXyea_`i'_2004*exp(_b[F_1idoXyea_`i'_2004])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2005 = F_1idoXyea_`i'_2005*exp(_b[F_1idoXyea_`i'_2005])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2006 = F_1idoXyea_`i'_2006*exp(_b[F_1idoXyea_`i'_2006])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2007 = F_1idoXyea_`i'_2007*exp(_b[F_1idoXyea_`i'_2007])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2008 = F_1idoXyea_`i'_2008*exp(_b[F_1idoXyea_`i'_2008])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2009 = F_1idoXyea_`i'_2009*exp(_b[F_1idoXyea_`i'_2009])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2010 = F_1idoXyea_`i'_2010*exp(_b[F_1idoXyea_`i'_2010])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2011 = F_1idoXyea_`i'_2011*exp(_b[F_1idoXyea_`i'_2011])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2012 = F_1idoXyea_`i'_2012*exp(_b[F_1idoXyea_`i'_2012])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2013 = F_1idoXyea_`i'_2013*exp(_b[F_1idoXyea_`i'_2013])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2014 = F_1idoXyea_`i'_2014*exp(_b[F_1idoXyea_`i'_2014])
}



**  -----------------------------------  **
/*               21º STEP:               */
**  -----------------------------------  **

/*
multiplying each vector of fixed effect "DESTINATION", NAFTA specification, by the exponential of its respective coefficient
*/

/*  --------------------------  */
/*  ALL FIXED EFFECTS IMPORTER  */
/*  --------------------------  */

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_1996 = F_2iddXyea_`i'_1996*exp(_b[F_2iddXyea_`i'_1996])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_1997 = F_2iddXyea_`i'_1997*exp(_b[F_2iddXyea_`i'_1997])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_1998 = F_2iddXyea_`i'_1998*exp(_b[F_2iddXyea_`i'_1998])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_1999 = F_2iddXyea_`i'_1999*exp(_b[F_2iddXyea_`i'_1999])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2000 = F_2iddXyea_`i'_2000*exp(_b[F_2iddXyea_`i'_2000])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2001 = F_2iddXyea_`i'_2001*exp(_b[F_2iddXyea_`i'_2001])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2002 = F_2iddXyea_`i'_2002*exp(_b[F_2iddXyea_`i'_2002])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2003 = F_2iddXyea_`i'_2003*exp(_b[F_2iddXyea_`i'_2003])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2004 = F_2iddXyea_`i'_2004*exp(_b[F_2iddXyea_`i'_2004])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2005 = F_2iddXyea_`i'_2005*exp(_b[F_2iddXyea_`i'_2005])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2006 = F_2iddXyea_`i'_2006*exp(_b[F_2iddXyea_`i'_2006])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2007 = F_2iddXyea_`i'_2007*exp(_b[F_2iddXyea_`i'_2007])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2008 = F_2iddXyea_`i'_2008*exp(_b[F_2iddXyea_`i'_2008])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2009 = F_2iddXyea_`i'_2009*exp(_b[F_2iddXyea_`i'_2009])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2010 = F_2iddXyea_`i'_2010*exp(_b[F_2iddXyea_`i'_2010])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2011 = F_2iddXyea_`i'_2011*exp(_b[F_2iddXyea_`i'_2011])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2012 = F_2iddXyea_`i'_2012*exp(_b[F_2iddXyea_`i'_2012])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2013 = F_2iddXyea_`i'_2013*exp(_b[F_2iddXyea_`i'_2013])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2014 = F_2iddXyea_`i'_2014*exp(_b[F_2iddXyea_`i'_2014])
}



**  -----------------------------------  **
/*               22º STEP:               */
**  -----------------------------------  **

/*
placing all fixed-effect vectors "ORIGIN", NAFTA specification, on a single vector
*/

egen all_exp_fe1 = rowtotal (F_1idoXyea_*)

/*
placing all fixed-effect vectors "DESTINATION", NAFTA specification, on a single vector
*/

egen all_imp_fe1 = rowtotal (F_2iddXyea_*)



**  -----------------------------------  **
/*               23º STEP:               */
**  -----------------------------------  **

/*
creating the internal resistances of the NAFTA
*/

gen omr_nafta = output*expndr_tha/(all_exp_fe1)  /*  equation 7 Anderson, Larch and Yotov - Estimating General Equilibrium Trade Policy Effects: GE PPML  */



**  -----------------------------------  **
/*               24º STEP:               */
**  -----------------------------------  **

/*
creating the external resistances of the NAFTA
*/

gen imr_nafta = expndr/(all_imp_fe1*expndr_tha)  /*  equation 8 Anderson, Larch and Yotov - Estimating General Equilibrium Trade Policy Effects: GE PPML  */


replace ido = "THA" if ido == "ZZZ"
replace idd = "THA" if idd == "ZZZ"


drop F_*


save C:\Users\Inspiron\Desktop\geppmlC.dta, replace


/*  -------------------------------------------------------------------------------------  */
/*  -------------------------------------------------------------------------------------  */
/*  ---  THE WELFARE EFFECTS OF GLOBALIZATION   THE WELFARE EFFECTS OF GLOBALIZATION  ---  */
/*  -------------------------------------------------------------------------------------  */
/*  -------------------------------------------------------------------------------------  */


clear all

use "C:\Users\Inspiron\Desktop\geppmlC.dta"

set more off
set matsize 7500


replace ido = "ZZZ" if ido == "THA"
replace idd = "ZZZ" if idd == "THA"

xi, pre(F_1) noomit i.ido*i.year
xi, pre(F_2) noomit i.idd*i.year



**  -----------------------------------  **
/*               25º STEP:               */
**  -----------------------------------  **

/*
estimating the specification of "hyperglobalization" to obtain the terms of resistance of the conditional counterfactual 
*/

ppml trade F_1idoXyea_* F_2iddXyea_1_1996-F_2iddXyea_30_2014, noconst offset(lcost_gbln)

/*  WARNING:

* NOTE THAT THE COEFFICIENTS OF THE CONDITIONAL COUNTERFACTUAL WILL HAVE THE SAME BASELINE ESTIMATION VALUES WILL NOT INCLUDE THE STANDARD VARIABLES OF THE GRAVITATIONAL MODEL.
  IN CONTRAPARTIDE IS PLACED AS OPTION THE TERM offset().  */



**  -----------------------------------  **
/*               26º STEP:               */
**  -----------------------------------  **

/*
multiplying each vector of fixed effect "ORIGIN", hyperglobalization specification, by the exponential of its respective coefficient
*/

/*  --------------------------  */
/*  ALL FIXED EFFECTS EXPORTER  */
/*  --------------------------  */
 
forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_1996 = F_1idoXyea_`i'_1996*exp(_b[F_1idoXyea_`i'_1996])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_1997 = F_1idoXyea_`i'_1997*exp(_b[F_1idoXyea_`i'_1997])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_1998 = F_1idoXyea_`i'_1998*exp(_b[F_1idoXyea_`i'_1998])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_1999 = F_1idoXyea_`i'_1999*exp(_b[F_1idoXyea_`i'_1999])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2000 = F_1idoXyea_`i'_2000*exp(_b[F_1idoXyea_`i'_2000])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2001 = F_1idoXyea_`i'_2001*exp(_b[F_1idoXyea_`i'_2001])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2002 = F_1idoXyea_`i'_2002*exp(_b[F_1idoXyea_`i'_2002])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2003 = F_1idoXyea_`i'_2003*exp(_b[F_1idoXyea_`i'_2003])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2004 = F_1idoXyea_`i'_2004*exp(_b[F_1idoXyea_`i'_2004])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2005 = F_1idoXyea_`i'_2005*exp(_b[F_1idoXyea_`i'_2005])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2006 = F_1idoXyea_`i'_2006*exp(_b[F_1idoXyea_`i'_2006])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2007 = F_1idoXyea_`i'_2007*exp(_b[F_1idoXyea_`i'_2007])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2008 = F_1idoXyea_`i'_2008*exp(_b[F_1idoXyea_`i'_2008])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2009 = F_1idoXyea_`i'_2009*exp(_b[F_1idoXyea_`i'_2009])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2010 = F_1idoXyea_`i'_2010*exp(_b[F_1idoXyea_`i'_2010])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2011 = F_1idoXyea_`i'_2011*exp(_b[F_1idoXyea_`i'_2011])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2012 = F_1idoXyea_`i'_2012*exp(_b[F_1idoXyea_`i'_2012])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2013 = F_1idoXyea_`i'_2013*exp(_b[F_1idoXyea_`i'_2013])
}

forvalues i = 1(1)13 {
qui replace F_1idoXyea_`i'_2014 = F_1idoXyea_`i'_2014*exp(_b[F_1idoXyea_`i'_2014])
}



**  -----------------------------------  **
/*               27º STEP:               */
**  -----------------------------------  **

/*
multiplying each vector of fixed effect "DESTINATION", hyperglobalization specification, by the exponential of its respective coefficient
*/

/*  --------------------------  */
/*  ALL FIXED EFFECTS IMPORTER  */
/*  --------------------------  */

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_1996 = F_2iddXyea_`i'_1996*exp(_b[F_2iddXyea_`i'_1996])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_1997 = F_2iddXyea_`i'_1997*exp(_b[F_2iddXyea_`i'_1997])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_1998 = F_2iddXyea_`i'_1998*exp(_b[F_2iddXyea_`i'_1998])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_1999 = F_2iddXyea_`i'_1999*exp(_b[F_2iddXyea_`i'_1999])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2000 = F_2iddXyea_`i'_2000*exp(_b[F_2iddXyea_`i'_2000])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2001 = F_2iddXyea_`i'_2001*exp(_b[F_2iddXyea_`i'_2001])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2002 = F_2iddXyea_`i'_2002*exp(_b[F_2iddXyea_`i'_2002])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2003 = F_2iddXyea_`i'_2003*exp(_b[F_2iddXyea_`i'_2003])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2004 = F_2iddXyea_`i'_2004*exp(_b[F_2iddXyea_`i'_2004])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2005 = F_2iddXyea_`i'_2005*exp(_b[F_2iddXyea_`i'_2005])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2006 = F_2iddXyea_`i'_2006*exp(_b[F_2iddXyea_`i'_2006])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2007 = F_2iddXyea_`i'_2007*exp(_b[F_2iddXyea_`i'_2007])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2008 = F_2iddXyea_`i'_2008*exp(_b[F_2iddXyea_`i'_2008])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2009 = F_2iddXyea_`i'_2009*exp(_b[F_2iddXyea_`i'_2009])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2010 = F_2iddXyea_`i'_2010*exp(_b[F_2iddXyea_`i'_2010])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2011 = F_2iddXyea_`i'_2011*exp(_b[F_2iddXyea_`i'_2011])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2012 = F_2iddXyea_`i'_2012*exp(_b[F_2iddXyea_`i'_2012])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2013 = F_2iddXyea_`i'_2013*exp(_b[F_2iddXyea_`i'_2013])
}

forvalues i = 1(1)30 {
qui replace F_2iddXyea_`i'_2014 = F_2iddXyea_`i'_2014*exp(_b[F_2iddXyea_`i'_2014])
}



**  -----------------------------------  **
/*               28º STEP:               */
**  -----------------------------------  **

/*
placing all fixed-effect vectors "ORIGIN", hyperglobalization specification, on a single vector
*/

egen all_exp_fe2 = rowtotal (F_1idoXyea_*)

/*
placing all fixed-effect vectors "DESTINATION", hyperglobalization specification, on a single vector
*/

egen all_imp_fe2 = rowtotal (F_2iddXyea_*)



**  -----------------------------------  **
/*               29º STEP:               */
**  -----------------------------------  **

/*
creating the internal resistances of the hyperglobalization
*/

gen omr_gbln = output*expndr_tha/(all_exp_fe2)  /*  equation 7 Anderson, Larch and Yotov - Estimating General Equilibrium Trade Policy Effects: GE PPML  */



**  -----------------------------------  **
/*               30º STEP:               */
**  -----------------------------------  **

/*
creating the external resistances of the hyperglobalization
*/

gen imr_gbln = expndr/(all_imp_fe2*expndr_tha)  /*  equation 8 Anderson, Larch and Yotov - Estimating General Equilibrium Trade Policy Effects: GE PPML  */


replace ido = "THA" if ido == "ZZZ"
replace idd = "THA" if idd == "ZZZ"


drop F_*


save C:\Users\Inspiron\Desktop\geppmlD.dta, replace


/*  --------------------------------------------------------------------------------  */
/*  --------------------------------------------------------------------------------  */
/*  ---  WELFARE EFFECTS   WELFARE EFFECTS   WELFARE EFFECTS   WELFARE EFFECTTS  ---  */
/*  --------------------------------------------------------------------------------  */
/*  --------------------------------------------------------------------------------  */


use C:\Users\Inspiron\Desktop\geppmlD.dta



**  -----------------------------------  **
/*               31º STEP:               */
**  -----------------------------------  **

/* keeping the variables of interest for the counterfactual */

keep idd imr_bsln imr_nafta imr_gbln output



**  -----------------------------------  **
/*               32º STEP:               */
**  -----------------------------------  **

/*
averaging the variables of interest to perform the counterfactual */

collapse imr_bsln imr_nafta imr_gbln output, by (idd)



**  -----------------------------------  **
/*               33º STEP:               */
**  -----------------------------------  **

/* keeping only the developing economies */

keep if idd == "ARG" | idd == "BRA" | idd == "CHN" | idd == "COL" | idd == "IDN" | idd == "IND" | idd == "MEX" | idd == "MYS" | idd == "PER" | idd == "PHL" | idd == "TUR" | ///
        idd == "THA" | idd == "ZAF"



**  -----------------------------------  **
/*               34º STEP:               */
**  -----------------------------------  **

/*  
value of the Armington elasticity considered in the counterfactual
*/


scalar sigma = 12.1  /*  Anderson, Larch and Yotov used a standard value for the elasticity of substitution - sigma = 7  */



**  -----------------------------------  **
/*               35º STEP:               */
**  -----------------------------------  **
		
/*  
calculating real gdp for the baseline and counterfactual estimations  */

gen rgdp_bsln = output / (imr_bsln^(1 / (1 - sigma)))
label variable rgdp_bsln "real gdp for baseline estimation"

gen rgdp_nafta = output / (imr_nafta^(1 / (1 - sigma)))
label variable rgdp_nafta "real gdp for the counterfactual of NAFTA"

gen rgdp_gbln = output / (imr_gbln^(1 / (1 - sigma)))
label variable rgdp_gbln "real gdp for the counterfactual of hyperglobalization"



**  -----------------------------------  **
/*               36º STEP:               */
**  -----------------------------------  **

/*  
calculating the percentage change in welfare - equation 13 Anderson, Larch and Yotov - Estimating General Equilibrium Trade Policy Effects: GE PPML  */
		
gen delta_nafta = ((rgdp_nafta - rgdp_bsln)/rgdp_bsln)*100
label variable delta_nafta "percentage change in welfare due to NAFTA"

gen delta_gbln = ((rgdp_gbln - rgdp_bsln)/rgdp_bsln)*100
label variable delta_gbln "percentage change in welfare due to hyperglobalization"



**  -----------------------------------  **
/*               37º STEP:               */
**  -----------------------------------  **

/*  
calculating the average percentage change in welfare for nafta and globalization  */

egen mean_nafta = mean(delta_nafta)
label variable mean_nafta "mean delta_nafta"

egen mean_gbln = mean(delta_gbln)
label variable mean_gbln "mean delta_gbln"


save C:\Users\Inspiron\Desktop\geppmlWELFARE.dta, replace
