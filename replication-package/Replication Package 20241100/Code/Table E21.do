

use "$data/TC_cleaned_2nd.dta", clear

keep *rename_schools *affirmative_action *death_penalty *marijuana ///
	 treat e_* gender race year major ideology survey_id zoom_id moderator week group_size session_time
	  
foreach var in rename_schools affirmative_action death_penalty marijuana {
	rename guesses_`var' guesses_b_`var'
}

reshape long private_ guesses_b_ guesses_m_ guesses_e_ , i(survey_id) j(topic) string
encode topic, generate(topic_id)


local controls i.gender i.race i.year i.ideology i.major
label var treat "Treat"
label var private_ "Private Agree"

eststo clear

reg guesses_m_ treat i.topic_id, cluster(survey_id)
	eststo
	qui sum guesses_m_ if treat == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

reg guesses_m_ treat private_ guesses_b_ i.topic_id, cluster(survey_id)
	eststo
	qui sum guesses_m_ if treat == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

reg guesses_m_ treat private_ guesses_b_ i.topic_id `controls', cluster(survey_id)
	eststo
	qui sum guesses_m_ if treat == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)
	
reg guesses_e_ treat i.topic_id, cluster(zoom_id)
	eststo
	qui sum guesses_e_ if treat == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

reg guesses_e_ treat private_ guesses_b_ i.topic_id, cluster(zoom_id)
	eststo
	qui sum guesses_e_ if treat == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

reg guesses_e_ treat private_ guesses_b_ i.topic_id `controls' i.moderator i.week group_size i.session_time, cluster(zoom_id)
	eststo
	qui sum guesses_e_ if treat == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)
	
esttab using "$output/ols_inference_tc_2025.tex", ///
se lab stats(Cmean Csd ids N,labels("Mean" "SD" "IDs" "Obs")) keep(treat private_ guesses_b_) star( * 0.1 ** 0.05 *** 0.01) ///
varwidth(32) wrap compress nogap noconstant replace ///
title("midline_inference") //indicate("Individual Controls =  gender")

