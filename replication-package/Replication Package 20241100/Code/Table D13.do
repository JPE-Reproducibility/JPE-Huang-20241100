******* Expression： DID ********
use "$data/TC_cleaned.dta", clear

foreach var in rename_schools affirmative_action death_penalty immunizations daylight_saving{
	replace e_`var' = 9 if e_`var' == .
	gen e_d_`var' = 0 
	replace e_d_`var' = 1 if e_`var' != 9 & e_`var' == private_`var' 
	}


keep private_rename_schools private_immunizations private_death_penalty private_affirmative_action private_daylight_saving ///
	 guesses_rename_schools guesses_immunizations guesses_death_penalty guesses_affirmative_action guesses_daylight_saving ///
	 guesses_m_rename_schools guesses_m_immunizations guesses_m_death_penalty guesses_m_affirmative_action guesses_m_daylight_saving ///
	 e_d_rename_schools e_d_immunizations e_d_death_penalty e_d_affirmative_action e_d_daylight_saving ///
	 treat gender race year major ideology survey_id zoom_id group_size session_time moderator week

reshape long private_ guesses_ guesses_m_ e_d_, i(survey_id) j(topic) string


* Panel A: Public Expression by Second Movers, Those who Privately Disagree

gen private_norm = 0 
replace private_norm = 1 if private_ == 1

gen guesses_norm = .  
replace guesses_norm = guesses_ 

rename e_d_ express_d 
encode topic, generate(topic_id)
gen topic_t = . 
replace topic_t = 1 if topic_id != 2
replace topic_t = 0 if topic_id == 2 // Placebo topic: DST


local ind_controls i.gender i.race year i.ideology 
local session_controls group_size i.session_time i.moderator i.week


label var treat "Treat"
label var topic_t "Sensitive Topics"

eststo clear

reg express_d i.treat##i.topic_t i.topic_id if private_ == 0, cluster(zoom_id)
	eststo
	qui sum express_d if treat == 0 & private_ == 0 & topic_t == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id) if private_ == 0 
	estadd scalar ids = round(r(ndistinct),1)

reg express_d i.treat##i.topic_t guesses_norm i.topic_id if private_ == 0, cluster(zoom_id)
	eststo
	qui sum express_d if treat == 0 & private_ == 0 & topic_t == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id) if private_ == 0 
	estadd scalar ids = round(r(ndistinct),1)
	
reg express_d i.treat##i.topic_t guesses_norm i.topic_id `session_controls' if private_ == 0, cluster(zoom_id)
	eststo
	qui sum express_d if treat == 0 & private_ == 0 & topic_t == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id) if private_ == 0 
	estadd scalar ids = round(r(ndistinct),1)
	
reg express_d i.treat##i.topic_t guesses_norm i.topic_id `session_controls' `ind_controls' if private_ == 0, cluster(zoom_id)
	eststo
	qui sum express_d if treat == 0 & private_ == 0 & topic_t == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id) if private_ == 0 
	estadd scalar ids = round(r(ndistinct),1)

logit express_d i.treat##i.topic_t guesses_norm i.topic_id `session_controls' `ind_controls' if private_ == 0, cluster(zoom_id)
	eststo
	qui sum express_d if treat == 0 & private_ == 0 & topic_t == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id) if private_ == 0 
	estadd scalar ids = round(r(ndistinct),1)

esttab using "$output/ols_expression_minority_did.tex", ///
se lab stats(Cmean Csd ids N,labels("Mean" "SD" "IDs" "Obs")) keep(1.treat 1.topic_t 1.treat#1.topic_t) star( * 0.1 ** 0.05 *** 0.01) ///
varwidth(32) wrap compress nogap noconstant replace ///
title("TC_expression") //indicate("Individual Controls =  gender")

* Panel B: Public Expression by Second Movers, Those who Privately Disagree
eststo clear

reg express_d i.treat##i.topic_t i.topic_id if private_ == 1, cluster(zoom_id)
	eststo
	qui sum express_d if treat == 0 & private_ == 1 & topic_t == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id) if private_ == 1 
	estadd scalar ids = round(r(ndistinct),1)

reg express_d i.treat##i.topic_t guesses_norm i.topic_id if private_ == 1, cluster(zoom_id)
	eststo
	qui sum express_d if treat == 0 & private_ == 1 & topic_t == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id) if private_ == 1 
	estadd scalar ids = round(r(ndistinct),1)

reg express_d i.treat##i.topic_t guesses_norm i.topic_id `session_controls' if private_ == 1, cluster(zoom_id)
	eststo
	qui sum express_d if treat == 0 & private_ == 1 & topic_t == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id) if private_ == 1 
	estadd scalar ids = round(r(ndistinct),1)

reg express_d i.treat##i.topic_t guesses_norm i.topic_id `session_controls' `ind_controls' if private_ == 1, cluster(zoom_id)
	eststo
	qui sum express_d if treat == 0 & private_ == 1 & topic_t == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id) if private_ == 1 
	estadd scalar ids = round(r(ndistinct),1)

logit express_d i.treat##i.topic_t guesses_norm i.topic_id `session_controls' `ind_controls' if private_ == 1, cluster(zoom_id)
	eststo
	qui sum express_d if treat == 0 & private_ == 1 & topic_t == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id) if private_ == 1 
	estadd scalar ids = round(r(ndistinct),1)

esttab using "$output/ols_expression_majority_did.tex", ///
se lab stats(Cmean Csd ids N,labels("Mean" "SD" "IDs" "Obs")) keep(1.treat 1.topic_t 1.treat#1.topic_t) star( * 0.1 ** 0.05 *** 0.01) ///
varwidth(32) wrap compress nogap noconstant replace ///
title("TC_expression") //indicate("Individual Controls =  gender")

