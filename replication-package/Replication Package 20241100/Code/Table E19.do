****** Expression Regression ********

use "$data/extremity_TC_merged.dta", clear
foreach var in renaming_e aa_e death_penalty_e immunizations_e{
	replace `var' = 6 if `var' == .
}


foreach var in renaming aa death_penalty immunizations{
	gen `var'_e_d = 0
	replace `var'_e_d = 1 if abs(`var'_e - `var'_private) <= 1
}

foreach var in renaming aa death_penalty immunizations{
	rename `var'_private private_`var'
	rename `var'_e_d e_d_`var'
	gen `var'_guesses = 1*`var'_guesses_1 + 2*`var'_guesses_2 + 3*`var'_guesses_3 + 4*`var'_guesses_4 + 5*`var'_guesses_5
	rename `var'_guesses guesses_`var'
}

keep private_* e_d_* guesses_* gender race year major ideology native_speaker id treat

reshape long private_ guesses_ e_d_, i(id) j(topic) string

rename private_ private
gen private_norm = 0 
replace private_norm = 1 if private > 3

gen private_extreme = 0 
replace private_extreme = 1 if private == 1 | private == 5

rename e_d_ express_d 
encode topic, generate(topic_id)

local controls guesses_ i.gender i.race i.year i.ideology i.major
label var private_norm "Private Agree"
label var private_extreme "Private Extreme"

eststo clear

reg express_d treat i.topic_id if private_norm == 0, cluster(id)  
	eststo
	qui sum express_d if private_norm == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(id)
	estadd scalar ids = round(r(ndistinct),1)

reg express_d treat i.topic_id `controls' if private_norm == 0 , cluster(id) 
	eststo
	qui sum express_d if private_norm == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(id)
	estadd scalar ids = round(r(ndistinct),1)

reg express_d treat i.topic_id if private_extreme == 0 , cluster(id) 
	eststo
	qui sum express_d if private_extreme == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(id)
	estadd scalar ids = round(r(ndistinct),1)

reg express_d treat i.topic_id `controls' if private_extreme == 0 , cluster(id) 
	eststo
	qui sum express_d if private_extreme == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(id)
	estadd scalar ids = round(r(ndistinct),1)


esttab using "$output/reg_tc_exp_extremity.tex", ///
se lab stats(Cmean Csd ids,labels("Mean" "SD" "IDs")) keep(treat) star( * 0.1 ** 0.05 *** 0.01) ///
varwidth(32) wrap compress nogap noconstant replace ///
title("first_movers_expression") //indicate("Individual Controls =  gender")

