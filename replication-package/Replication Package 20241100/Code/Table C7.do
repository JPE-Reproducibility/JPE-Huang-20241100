******* Expression ********
use "$data/TC_cleaned.dta", clear


foreach var in rename_schools affirmative_action death_penalty immunizations daylight_saving{
	replace e_`var' = 9 if e_`var' == .
	gen e_d_`var' = 0 
	replace e_d_`var' = 1 if e_`var' != 9 & e_`var' == private_`var' 
	}

	 keep private_rename_schools private_immunizations private_death_penalty private_affirmative_action ///
	 guesses_rename_schools guesses_immunizations guesses_death_penalty guesses_affirmative_action ///
	 guesses_m_rename_schools guesses_m_immunizations guesses_m_death_penalty guesses_m_affirmative_action ///
	 e_d_rename_schools e_d_immunizations e_d_death_penalty e_d_affirmative_action ///
	 treat gender race year major ideology survey_id zoom_id group_size session_time moderator week

reshape long private_ guesses_ guesses_m_ e_d_, i(survey_id) j(topic) string

gen private_norm = 0 
replace private_norm = 1 if private_ == 1

gen guesses_norm = .  
replace guesses_norm = guesses_ 

rename e_d_ express_d 
encode topic, generate(topic_id)

local ind_controls i.gender i.race year i.ideology i.major
local session_controls group_size i.session_time i.moderator i.week

gen female = 0 
replace female = 1 if gender == 2

gen ideology_l = 0 
replace ideology_l = 1 if ideology <= 3

local ind_controls female i.race year ideology_l i.major

label var treat "Treat"

eststo clear

reg express_d treat guesses_norm `session_controls' `ind_controls' if private_ == 0 & topic_id == 1, cluster(zoom_id)


logit express_d treat guesses_norm `session_controls' `ind_controls' if private_ == 0 & topic_id == 1, cluster(zoom_id)

margins, dydx(*) post
	eststo
	qui sum express_d if treat == 0 & private_ == 0 & topic_id == 1
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id) if private_ == 0  & topic_id == 1
	estadd scalar ids = round(r(ndistinct),1)

logit express_d treat guesses_norm `session_controls' `ind_controls' if private_ == 0 & topic_id == 2, cluster(zoom_id)
margins, dydx(*) post
	eststo
	qui sum express_d if treat == 0 & private_ == 0 & topic_id == 2
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id) if private_ == 0  & topic_id == 2
	estadd scalar ids = round(r(ndistinct),1)
	
logit express_d treat guesses_norm `session_controls' `ind_controls'  if private_ == 0 & topic_id == 3, cluster(zoom_id)
margins, dydx(*) post
	eststo
	qui sum express_d if treat == 0 & private_ == 0 & topic_id == 3
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id) if private_ == 0  & topic_id == 3
	estadd scalar ids = round(r(ndistinct),1)
	
logit express_d treat guesses_norm `session_controls' `ind_controls' if private_ == 0 & topic_id == 4, cluster(zoom_id)
margins, dydx(*) post
	eststo
	qui sum express_d if treat == 0 & private_ == 0 & topic_id == 4
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id) if private_ == 0  & topic_id == 4
	estadd scalar ids = round(r(ndistinct),1)

esttab using "$output/logit_expression_minority_tc_topic.tex", ///
se lab stats(Cmean Csd ids,labels("Mean" "SD" "IDs")) keep(treat) star( * 0.1 ** 0.05 *** 0.01) ///
varwidth(32) wrap compress nogap noconstant replace ///
title("TC_expression") //indicate("Individual Controls =  gender")


eststo clear

logit express_d treat guesses_norm i.topic_id `session_controls' `ind_controls' if private_ == 1 & topic_id == 1, cluster(zoom_id)
margins, dydx(*) post
	eststo
	qui sum express_d if treat == 0 & private_ == 1 & topic_id == 1
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id) if private_ == 1  & topic_id == 1
	estadd scalar ids = round(r(ndistinct),1)

logit express_d treat guesses_norm i.topic_id `session_controls' `ind_controls' if private_ == 1 & topic_id == 2, cluster(zoom_id)
margins, dydx(*) post
	eststo
	qui sum express_d if treat == 0 & private_ == 1 & topic_id == 2
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id) if private_ == 1  & topic_id == 2
	estadd scalar ids = round(r(ndistinct),1)
	
logit express_d treat guesses_norm i.topic_id `session_controls' `ind_controls' if private_ == 1 & topic_id == 3, cluster(zoom_id)
margins, dydx(*) post
	eststo
	qui sum express_d if treat == 0 & private_ == 1 & topic_id == 3
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id) if private_ == 1  & topic_id == 3
	estadd scalar ids = round(r(ndistinct),1)
	
logit express_d treat guesses_norm i.topic_id `session_controls' `ind_controls' if private_ == 1 & topic_id == 4, cluster(zoom_id)
margins, dydx(*) post
	eststo
	qui sum express_d if treat == 0 & private_ == 1 & topic_id == 4
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id) if private_ == 1  & topic_id == 4
	estadd scalar ids = round(r(ndistinct),1)

esttab using "$output/logit_expression_majority_tc_topic.tex", ///
se lab stats(Cmean Csd ids,labels("Mean" "SD" "IDs")) keep(treat) star( * 0.1 ** 0.05 *** 0.01) ///
varwidth(32) wrap compress nogap noconstant replace ///
title("TC_expression") //indicate("Individual Controls =  gender")
