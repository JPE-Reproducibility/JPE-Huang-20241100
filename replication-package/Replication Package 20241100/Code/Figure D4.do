******* Expression： DID ********
use "$data/TC_cleaned.dta", clear

foreach var in rename_schools affirmative_action death_penalty immunizations daylight_saving{
	replace e_`var' = 9 if e_`var' == .
	gen e_d_`var' = 0 
	replace e_d_`var' = 1 if e_`var' != 9 & e_`var' == private_`var' 
	}
label define private_label 0 "Privately Disagree" 1 "Privately Agree" 
label values private_daylight_saving private_label

label define treat_label 0 "Control (A+D)" 1 "Treat (A+D+S)" 
label values treat treat_label
splitvallabels treat, length(2)

distinct survey_id 
local n_total = r(ndistinct)

cibar e_d_daylight_saving, over(treat private_daylight_saving) barlabel(on) blf(%9.3f) bargap(20) gap(120)  blgap(-0.1) baropts(lcolor(none)) barcolor(cranberry%35 midblue%35) ciopts(lcolor(gs5)) ///
graphopts(legend(position(6) rows(1)) ylabel(0(0.1)0.6, nogrid) xlab(, nogrid) ytitle("Pr(Express)") title("Pr(Express|Agree), Pr(Express|Disagree) , Daylight Saving") subtitle("N = `n_total'"))
graph export "$output/bar_express_dst.png", replace

