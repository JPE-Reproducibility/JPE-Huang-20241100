*** DID: Inference
use "$data/TC_cleaned.dta", clear
	
keep *rename_schools *affirmative_action *death_penalty *immunizations *daylight_saving ///
	 treat e_* gender race year major ideology survey_id zoom_id moderator week group_size session_time
	  
foreach var in rename_schools affirmative_action death_penalty immunizations daylight_saving{
	rename guesses_`var' guesses_b_`var'
}

reshape long private_ guesses_b_ guesses_m_ guesses_e_ , i(survey_id) j(topic) string
encode topic, generate(topic_id)

gen topic_t = . 
replace topic_t = 1 if topic_id != 2
replace topic_t = 0 if topic_id == 2 // Placebo topic: DST

local controls i.gender i.race i.year i.ideology i.major
label var treat "Treat"
label var topic_t "Sensitive Topics"
label var private_ "Private Agree"

eststo clear

reg guesses_m_ i.treat##i.topic_t, cluster(survey_id)
	eststo
	qui sum guesses_m_ if treat == 0 & topic_t == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

reg guesses_m_ i.treat##i.topic_t  private_ guesses_b_ i.topic_id, cluster(survey_id)
	eststo
	qui sum guesses_m_ if treat == 0 & topic_t == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

reg guesses_m_ i.treat##i.topic_t  private_ guesses_b_ i.topic_id `controls', cluster(survey_id)
	eststo
	qui sum guesses_m_ if treat == 0 & topic_t == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)
	
reg guesses_e_ i.treat##i.topic_t i.topic_id, cluster(zoom_id)
	eststo
	qui sum guesses_e_ if treat == 0 & topic_t == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

reg guesses_e_ i.treat##i.topic_t private_ guesses_b_ i.topic_id, cluster(zoom_id)
	eststo
	qui sum guesses_e_ if treat == 0 & topic_t == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

reg guesses_e_ i.treat##i.topic_t private_ guesses_b_ guesses_m_ i.topic_id `controls' i.moderator i.week group_size i.session_time, cluster(zoom_id)
	eststo
	qui sum guesses_e_ if treat == 0 & topic_t == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)
	
esttab using "$output/ols_inference_did.tex", ///
se lab stats(Cmean Csd ids,labels("Mean" "SD" "IDs")) keep(1.treat 1.topic_t 1.treat#1.topic_t private_ guesses_b_) star( * 0.1 ** 0.05 *** 0.01) ///
varwidth(32) wrap compress nogap noconstant replace ///
title("inference_did") //indicate("Individual Controls =  gender")
