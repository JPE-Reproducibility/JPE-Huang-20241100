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


* Alternative to Table 2: Diff-in-Diff
preserve
rename guesses_b_ guesses0
rename guesses_m_ guesses1
rename guesses_e_ guesses2

reshape long guesses, i(survey_id topic_id) j(round)

gen midline = (round == 1)
gen endline = (round == 2)
gen post = (round == 1 | round == 2)
gen treat_midline = treat*midline
gen treat_endline = treat*endline
gen treat_post = treat*post
label var midline "Midline"
label var endline "Endline"
label var post "Post"
label var treat_midline "Treat X Midline"
label var treat_endline "Treat X Endline"
label var treat_post "Treat X Post"

local controls i.gender i.race i.year i.ideology i.major
eststo clear

reg guesses treat post treat_post private_ i.topic_id, cluster(zoom_id) 
	eststo
	qui sum guesses if treat == 0 & round == 0
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

	
reg guesses treat post endline treat_post treat_endline private_ i.topic_id, cluster(zoom_id) 
	eststo
	qui sum guesses if treat == 0 & round == 0
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

reg guesses treat post endline treat_post treat_endline private_ i.topic_id `controls', cluster(zoom_id) 
	eststo
	qui sum guesses if treat == 0 & round == 0
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

reg guesses treat post endline treat_post treat_endline private_ i.topic_id `controls' i.moderator i.week group_size i.session_time, cluster(zoom_id) 
	eststo
	qui sum guesses if treat == 0 & round == 0
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)


esttab using "$output/ols_inference_tc_did.tex", ///
se lab stats(Cmean Csd ids,labels("Mean" "SD" "IDs")) keep(post endline treat treat_post treat_endline ) star( * 0.1 ** 0.05 *** 0.01) ///
varwidth(32) wrap compress nogap noconstant replace ///
title("midline_inference") //indicate("Individual Controls =  gender")
restore
