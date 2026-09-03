******* Expression ********
use "$data/TC_cleaned_2nd.dta", clear

foreach var in rename_schools affirmative_action death_penalty marijuana{
	replace e_`var' = 9 if e_`var' == .
	gen e_d_`var' = 0 
	replace e_d_`var' = 1 if e_`var' != 9 & e_`var' == private_`var' 
	}

keep private_rename_schools private_marijuana private_death_penalty private_affirmative_action ///
	 guesses_rename_schools guesses_marijuana guesses_death_penalty guesses_affirmative_action ///
	 guesses_m_rename_schools guesses_m_marijuana guesses_m_death_penalty guesses_m_affirmative_action ///
	 e_d_rename_schools e_d_marijuana e_d_death_penalty e_d_affirmative_action ///
	 treat gender race year major ideology survey_id zoom_id group_size session_time week moderator

reshape long private_ guesses_ guesses_m_ e_d_, i(survey_id) j(topic) string

gen private_norm = 0 
replace private_norm = 1 if private_ == 1

gen guesses_norm = .  
replace guesses_norm = guesses_ 

rename e_d_ express_d 
encode topic, generate(topic_id)

local ind_controls i.gender i.race year i.ideology i.major

local session_controls group_size i.session_time i.moderator i.week

label var treat "Treat"

eststo clear

reg express_d treat i.topic_id if private_ == 0, cluster(zoom_id)
	eststo
	qui sum express_d if treat == 0 & private_ == 0
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id) if private_ == 0 
	estadd scalar ids = round(r(ndistinct),1)

reg express_d treat guesses_norm i.topic_id if private_ == 0, cluster(zoom_id)
	eststo
	qui sum express_d if treat == 0 & private_ == 0
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id) if private_ == 0 
	estadd scalar ids = round(r(ndistinct),1)
	
reg express_d treat guesses_norm i.topic_id `session_controls' if private_ == 0, cluster(zoom_id)
	eststo
	qui sum express_d if treat == 0 & private_ == 0
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id) if private_ == 0 
	estadd scalar ids = round(r(ndistinct),1)
	
reg express_d treat guesses_norm i.topic_id `session_controls' `ind_controls' if private_ == 0, cluster(zoom_id)
	eststo
	qui sum express_d if treat == 0 & private_ == 0
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id) if private_ == 0 
	estadd scalar ids = round(r(ndistinct),1)

logit express_d treat guesses_norm i.topic_id `session_controls' `ind_controls' if private_ == 0, cluster(zoom_id)
	margins, dydx(*) post
	eststo
	qui sum express_d if treat == 0 & private_ == 0
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id) if private_ == 0 
	estadd scalar ids = round(r(ndistinct),1)

esttab using "$output/ols_expression_minority_tc_2025.tex", ///
se lab stats(Cmean Csd ids N,labels("Mean" "SD" "IDs" "Obs")) keep(treat) star( * 0.1 ** 0.05 *** 0.01) ///
varwidth(32) wrap compress nogap noconstant replace ///
title("TC_expression") //indicate("Individual Controls =  gender")


eststo clear

reg express_d treat i.topic_id if private_ == 1, cluster(zoom_id)
	eststo
	qui sum express_d if treat == 0 & private_ == 1
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id) if private_ == 1 
	estadd scalar ids = round(r(ndistinct),1)

reg express_d treat guesses_norm i.topic_id if private_ == 1, cluster(zoom_id)
	eststo
	qui sum express_d if treat == 0 & private_ == 1
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id) if private_ == 1 
	estadd scalar ids = round(r(ndistinct),1)

reg express_d treat guesses_norm i.topic_id `session_controls' if private_ == 1, cluster(zoom_id)
	eststo
	qui sum express_d if treat == 0 & private_ == 1
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id) if private_ == 1 
	estadd scalar ids = round(r(ndistinct),1)

reg express_d treat guesses_norm i.topic_id `session_controls' `ind_controls' if private_ == 1, cluster(zoom_id)
	eststo
	qui sum express_d if treat == 0 & private_ == 1
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id) if private_ == 1 
	estadd scalar ids = round(r(ndistinct),1)

logit express_d treat guesses_norm i.topic_id `session_controls' `ind_controls' if private_ == 1, cluster(zoom_id)
	margins, dydx(*) post
	eststo
	qui sum express_d if treat == 0 & private_ == 1
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id) if private_ == 1 
	estadd scalar ids = round(r(ndistinct),1)

esttab using "$output/ols_expression_majority_tc_2025.tex", ///
se lab stats(Cmean Csd ids N,labels("Mean" "SD" "IDs" "Obs")) keep(treat) star( * 0.1 ** 0.05 *** 0.01) ///
varwidth(32) wrap compress nogap noconstant replace ///
title("TC_expression") //indicate("Individual Controls =  gender")

