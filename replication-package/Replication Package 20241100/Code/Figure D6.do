****** Spillover: Expression Decisions for Trans Athletes ******
use "$data/TC_cleaned.dta", clear

gen trans_express_d = 0
replace trans_express_d = 1 if trans_expression == 1 & private_trans_athletes == 0
replace trans_express_d = 1 if trans_expression == 2 & private_trans_athletes == 1

label define private_label 0 "Privately Disagree" 1 "Privately Agree" 
label values private_trans_athletes private_label

label define treat_label 0 "Control (A+D)" 1 "Treat (A+D+S)" 
label values treat treat_label
splitvallabels treat, length(2)

distinct survey_id 
local n_total = r(ndistinct)

cibar trans_express_d, over(treat private_trans_athletes) barlabel(on) blf(%9.3f) bargap(20) gap(120)  blgap(-0.1) baropts(lcolor(none)) barcolor(cranberry%35 midblue%35) ciopts(lcolor(gs5)) ///
graphopts(legend(position(6) rows(1)) ylabel(0(0.1)0.6, nogrid) xlab(, nogrid) ytitle("Pr(Express)") title("Pr(Express|Agree), Pr(Express|Disagree) ,Trans Athletes") subtitle("N = `n_total'"))
graph export "$output/bar_express_trans_athletes.png", replace
