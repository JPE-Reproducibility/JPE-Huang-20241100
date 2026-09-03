******** Inference *********
use "$data/TC_cleaned.dta", clear
	
keep *rename_schools *affirmative_action *death_penalty *immunizations ///
	 treat e_* gender race year major ideology survey_id zoom_id moderator week group_size session_time
	  
foreach var in rename_schools affirmative_action death_penalty immunizations {
	rename guesses_`var' guesses_b_`var'
}

reshape long private_ guesses_b_ guesses_m_ guesses_e_ , i(survey_id) j(topic) string
encode topic, generate(topic_id)
replace topic_id = topic_id + 1 
replace topic_id = 1 if topic_id == 5 // adjust the order of topics
forval i = 1/4{
	qui sum private_ if topic_id == `i'
	local actual_`i' = round(r(mean)*100,0.01)
}



* Table 2: Perceived Popularity of Socially Appropriate Views at Midline and Endline

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
	
esttab using "$output/ols_inference_tc_revised.tex", ///
se lab stats(Cmean Csd ids N,labels("Mean" "SD" "IDs" "Obs")) keep(treat private_ guesses_b_) star( * 0.1 ** 0.05 *** 0.01) ///
varwidth(32) wrap compress nogap noconstant replace ///
title("midline_inference") //indicate("Individual Controls =  gender")


*------------------------------------------------------------------------------
* SUEST: test whether the treatment effect is the same at midline and endline.
*
* NOTE ON OUTPUT. These tests are DISPLAYED IN THE STATA LOG ONLY -- they are not
* written to any file in $output. The three chi2(1) statistics and p-values below
* are transcribed by hand into the "SUEST b_M = b_E" row of Table 2
* (Draft tex/Tables/reg_inference_tc.tex). Expected values:
*
*     pair 1  ->  Table 2, cols (1) & (4):  chi2(1) =  10.54,  p = 0.0012
*     pair 2  ->  Table 2, cols (2) & (5):  chi2(1) =  10.55,  p = 0.0012
*     pair 3  ->  Table 2, cols (3) & (6):  chi2(1) =   8.26,  p = 0.0040
*
*------------------------------------------------------------------------------

reg guesses_m_ treat i.topic_id 
estimates store midline_inference_1

reg guesses_e_ treat i.topic_id 
estimates store endline_inference_1

suest midline_inference_1 endline_inference_1, cluster(survey_id) 
ereturn list
 di "`e(names)'"
 test [midline_inference_1_mean]treat = [endline_inference_1_mean]treat

reg guesses_m_ treat guesses_b_ i.topic_id 
estimates store midline_inference_2

reg guesses_e_ treat guesses_b_ i.topic_id  
estimates store endline_inference_2

suest midline_inference_2 endline_inference_2, cluster(survey_id) 
ereturn list
 di "`e(names)'"
 test [midline_inference_2_mean]treat = [endline_inference_2_mean]treat


local controls i.gender i.race i.year i.ideology i.major

reg guesses_m_ treat private_ guesses_b_ i.topic_id `controls' 
estimates store midline_inference

reg guesses_e_ treat private_ guesses_b_ i.topic_id `controls' i.moderator i.week group_size i.session_time
estimates store endline_inference

suest midline_inference endline_inference, cluster(survey_id) 
ereturn list
 di "`e(names)'"
 test [midline_inference_mean]treat = [endline_inference_mean]treat
 
 
