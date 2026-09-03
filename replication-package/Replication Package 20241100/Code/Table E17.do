use "$data/extremity_first_movers_cleaned.dta", replace

foreach var in renaming aa death_penalty immunizations{
	rename `var'_private private_`var'
	rename `var'_e_d e_d_`var'
	gen `var'_guesses = 1*`var'_guesses_1 + 2*`var'_guesses_2 + 3*`var'_guesses_3 + 4*`var'_guesses_4 + 5*`var'_guesses_5
	rename `var'_guesses guesses_`var'
}

keep private_* e_d_* guesses_* gender race year major ideology native_speaker id

reshape long private_ guesses_ e_d_, i(id) j(topic) string

rename private_ private
gen private_norm = 0 
replace private_norm = 1 if private > 3

gen guesses_norm = 0 
replace guesses_norm = 1 if guesses_ > 3

gen private_extreme = 0 
replace private_extreme = 1 if private == 1 | private == 5

rename e_d_ express_d 
encode topic, generate(topic_id)

local controls i.gender i.race i.year i.ideology i.major
label var private_norm "Private Agree"
label var private_extreme "Private Extreme"

eststo clear

reg express_d private_norm private_extreme i.topic_id, cluster(id)
	eststo
	qui sum express_d 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(id)
	estadd scalar ids = round(r(ndistinct),1)

reg express_d private_norm private_extreme guesses_ i.topic_id, cluster(id)
	eststo
	qui sum express_d 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(id)
	estadd scalar ids = round(r(ndistinct),1)

reg express_d private_norm private_extreme guesses_ i.topic_id `controls', cluster(id)
	eststo
	qui sum express_d 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(id)
	estadd scalar ids = round(r(ndistinct),1)
	

esttab using "$output/reg_first_movers_exp.tex", ///
se lab stats(Cmean Csd ids,labels("Mean" "SD" "IDs")) keep(private_norm private_extreme) star( * 0.1 ** 0.05 *** 0.01) ///
varwidth(32) wrap compress nogap noconstant replace ///
title("first_movers_expression") //indicate("Individual Controls =  gender")

