*** Table 1: Public Expression Decisions by First Movers

use "$data/first_movers_analysis.dta", clear
drop e_d_*
foreach var in rename_schools immunizations death_penalty affirmative_action{
	replace e_`var' = 9 if e_`var' == .
	gen e_d_`var' = 0 
	replace e_d_`var' = 1 if e_`var' != 9 & e_`var' == private_`var' //  dummies for truthful expression
	} 
	
keep private_rename_schools private_immunizations private_death_penalty private_affirmative_action ///
	 guesses_rename_schools guesses_immunizations guesses_death_penalty guesses_affirmative_action ///
	 e_* gender race year major ideology survey_id zoom_id

reshape long private_ guesses_ e_d_, i(survey_id) j(topic) string
save "$tempfile/first_movers_long.dta", replace

gen private_norm = 0 
replace private_norm = 1 if private_ == 1 & topic == "rename_schools"
replace private_norm = 1 if private_ == 0 & topic == "immunizations"
replace private_norm = 1 if private_ == 1 & topic == "death_penalty"
replace private_norm = 1 if private_ == 0 & topic == "affirmative_action" 

// Note: the statements were coded in the opposite direction for first-movers and second-movers, so we standardize the statements here to make it consistent with the analysis for second movers (in Table 3 etc.)

gen guesses_norm = .  
replace guesses_norm = guesses_ if topic == "rename_schools" | topic == "death_penalty" 
replace guesses_norm = 100 - guesses_ if topic == "immunizations" | topic == "affirmative_action"

rename e_d_ express_d 
encode topic, generate(topic_id)

local controls i.gender i.race i.year i.ideology i.major
label var private_norm "Private Agree"
label var guesses_norm "Perceived \%Agree"

* Panel A
eststo clear

reg express_d private_norm i.topic_id, cluster(survey_id)
	eststo
	qui sum express_d 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

reg express_d private_norm guesses_norm i.topic_id, cluster(survey_id)
	eststo
	qui sum express_d 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

reg express_d private_norm guesses_norm i.topic_id i.zoom_id, cluster(survey_id)
	eststo
	qui sum express_d 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)
	
reg express_d private_norm guesses_norm i.topic_id i.zoom_id `controls', cluster(survey_id)
	eststo
	qui sum express_d 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

esttab using "$output/ols_first_movers_expression.tex", ///
se lab stats(Cmean Csd ids N,labels("Mean" "SD" "IDs" "Obs")) keep(private_norm) star( * 0.1 ** 0.05 *** 0.01) ///
varwidth(32) wrap compress nogap noconstant replace ///
title("first_movers_expression") //indicate("Individual Controls =  gender")


* Panel B 
eststo clear

logit express_d private_norm i.topic_id, cluster(survey_id)
margins, dydx(*) post
	eststo
	qui sum express_d 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

logit express_d private_norm guesses_norm i.topic_id, cluster(survey_id)
margins, dydx(*) post
	eststo
	qui sum express_d 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

logit express_d private_norm guesses_norm i.topic_id i.zoom_id, cluster(survey_id)
margins, dydx(*) post
	eststo
	qui sum express_d 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

	
logit express_d private_norm guesses_norm i.topic_id i.zoom_id `controls', cluster(survey_id)
margins, dydx(*) post
	eststo
	qui sum express_d 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

esttab using "$output/logit_first_movers_expression.tex", ///
se lab stats(Cmean Csd ids,labels("Mean" "SD" "IDs")) keep(private_norm) star( * 0.1 ** 0.05 *** 0.01) ///
varwidth(32) wrap compress nogap noconstant replace ///
title("first_movers_expression") //indicate("Individual Controls =  gender")

