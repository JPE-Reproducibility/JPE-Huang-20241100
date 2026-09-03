******** Recall and Changes in Beliefs *******

use "$data/TC_cleaned.dta", clear

foreach var in rename_schools affirmative_action death_penalty immunizations daylight_saving{
	gen att_silence_`var' = 0
	forval i = 1/36{ 
		quietly count if e_`var' == . & zoom_id == `i'
		local n_s_`i' = r(N)
		replace att_silence_`var' = 1 if abs(recall_`var'_s - `n_s_`i'')<=1  & zoom_id == `i'
	}
}

foreach var in rename_schools affirmative_action death_penalty immunizations daylight_saving{
	gen frac_`var'_s_a = recall_`var'_s_a/recall_`var'_s
	preserve
	drop if frac_`var'_s_a > 1 
	sum frac_`var'_s_a if treat == 1
	restore
}
* Define those to be sophisticated if they infer that the %Agree among silence is smaller than the %Agree among the expressed sample (first movers summary stats)
gen soph1_rename_schools = 0 
replace soph1_rename_schools = 1 if frac_rename_schools_s_a < 0.58

gen soph1_affirmative_action = 0 
replace soph1_affirmative_action = 1 if frac_affirmative_action_s_a < 0.58

gen soph1_death_penalty = 0 
replace soph1_death_penalty = 1 if frac_death_penalty_s_a < 0.69

gen soph1_immunizations = 0 
replace soph1_immunizations = 1 if frac_immunizations_s_a < 0.92


* Alternative way of defning sophistication
gen soph2_rename_schools = 0 
replace soph2_rename_schools = 1 if frac_rename_schools_s_a < 0.6

gen soph2_affirmative_action = 0 
replace soph2_affirmative_action = 1 if frac_affirmative_action_s_a < 0.5

gen soph2_death_penalty = 0 
replace soph2_death_penalty = 1 if frac_death_penalty_s_a < 0.55

gen soph2_immunizations = 0 
replace soph2_immunizations = 1 if frac_immunizations_s_a < 0.8


******** Heterogeneity Table *******

keep *rename_schools *affirmative_action *death_penalty *immunizations ///
	 treat e_* soph* gender race year major ideology survey_id zoom_id moderator week group_size session_time
	  
foreach var in rename_schools affirmative_action death_penalty immunizations {
	rename guesses_`var' guesses_b_`var'
}

reshape long private_ guesses_b_ guesses_m_ guesses_e_ soph1_ soph2_, i(survey_id) j(topic) string
encode topic, generate(topic_id)

gen treat_private = treat*private_

gen treat_soph1_ = treat*soph1_

gen treat_soph2_ = treat*soph2_

gen female = 0
replace female = 1 if gender == 2

gen asian = 0 
replace asian = 1 if race == 2

gen white = 0 
replace white = 1 if race == 6

gen ideology_l = 0 
replace ideology_l = 1 if ideology <= 3

gen senior = 0 
replace senior = 1 if year >=4

gen social_science = 0 
replace social_science = 1 if major == 13

gen treat_female = treat*female 
gen treat_asian = treat*asian
gen treat_white = treat*white
gen treat_liberal = treat*ideology_l
gen treat_senior = treat*senior
gen treat_ss = treat*social_science

label var treat_private "Treat x Private Agree"
label var treat_soph1_ "Treat x Soph1"
label var treat_soph2_ "Treat x Soph2"
label var treat_female "Treat x Female"
label var treat_asian "Treat x Asian"
label var treat_white "Treat x White"
label var treat_liberal "Treat x Liberal"
label var treat_senior "Treat x Senior"
label var treat_ss "Treat x Social Science"

local ind_controls i.gender i.race i.year i.ideology i.major
local session_controls group_size i.session_time i.moderator i.week

eststo clear
reg guesses_m_ treat private_ treat_private guesses_b_ i.topic_id `ind_controls', cluster(survey_id)
	eststo
	qui sum guesses_m_ if treat == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)


reg guesses_m_ treat soph1_ treat_soph1_ guesses_b_ i.topic_id `ind_controls', cluster(survey_id)
	eststo
	qui sum guesses_m_ if treat == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

reg guesses_m_ treat soph2_ treat_soph2_ guesses_b_ i.topic_id `ind_controls', cluster(survey_id)
	eststo
	qui sum guesses_m_ if treat == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

reg guesses_m_ treat private_ treat_female guesses_b_ i.topic_id `ind_controls', cluster(survey_id)
	eststo
	qui sum guesses_m_ if treat == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)
	
reg guesses_m_ treat private_ treat_asian guesses_b_ i.topic_id `ind_controls', cluster(survey_id)
	eststo
	qui sum guesses_m_ if treat == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

reg guesses_m_ treat private_ treat_white guesses_b_ i.topic_id `ind_controls', cluster(survey_id)
	eststo
	qui sum guesses_m_ if treat == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

reg guesses_m_ treat private_ treat_liberal guesses_b_ i.topic_id `ind_controls', cluster(survey_id)
	eststo
	qui sum guesses_m_ if treat == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)
	
reg guesses_m_ treat private_ treat_senior guesses_b_ i.topic_id `ind_controls', cluster(survey_id)
	eststo
	qui sum guesses_m_ if treat == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)
	
reg guesses_m_ treat private_ treat_ss guesses_b_ i.topic_id `ind_controls', cluster(survey_id)
	eststo
	qui sum guesses_m_ if treat == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

reg guesses_m_ treat private_ soph1_ treat_private treat_soph1_ treat_female treat_asian treat_white treat_liberal treat_senior treat_ss guesses_b_ i.topic_id `ind_controls', cluster(survey_id)
	eststo
	qui sum guesses_m_ if treat == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

esttab using "$output/het_midline.tex", ///
se lab stats(Cmean Csd ids,labels("Mean" "SD" "IDs")) keep(treat*) star( * 0.1 ** 0.05 *** 0.01) ///
varwidth(32) wrap compress nogap noconstant replace ///
title("TC_het_midline") 

eststo clear
reg guesses_e_ treat private_ treat_private guesses_b_ i.topic_id `ind_controls' `session_controls', cluster(zoom_id)
	eststo
	qui sum guesses_e_ if treat == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

reg guesses_e_ treat soph1_ treat_soph1_ guesses_b_ i.topic_id `ind_controls' `session_controls', cluster(zoom_id)
	eststo
	qui sum guesses_e_ if treat == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

reg guesses_e_ treat soph2_ treat_soph2_ guesses_b_ i.topic_id `ind_controls' `session_controls', cluster(zoom_id)
	eststo
	qui sum guesses_e_ if treat == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

	
reg guesses_e_ treat private_ treat_female guesses_b_ i.topic_id `ind_controls' `session_controls', cluster(zoom_id)
	eststo
	qui sum guesses_e_ if treat == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)
	
reg guesses_e_ treat private_ treat_asian guesses_b_ i.topic_id `ind_controls' `session_controls', cluster(zoom_id)
	eststo
	qui sum guesses_e_ if treat == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

reg guesses_e_ treat private_ treat_white guesses_b_ i.topic_id `ind_controls' `session_controls', cluster(zoom_id)
	eststo
	qui sum guesses_e_ if treat == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

reg guesses_e_ treat private_ treat_liberal guesses_b_ i.topic_id `ind_controls' `session_controls', cluster(zoom_id)
	eststo
	qui sum guesses_e_ if treat == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)
	
reg guesses_e_ treat private_ treat_senior guesses_b_ i.topic_id `ind_controls' `session_controls', cluster(zoom_id)
	eststo
	qui sum guesses_e_ if treat == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)
	
reg guesses_e_ treat private_ treat_ss guesses_b_ i.topic_id `ind_controls' `session_controls', cluster(zoom_id)
	eststo
	qui sum guesses_e_ if treat == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

reg guesses_e_ treat private_ soph1_ treat_private treat_soph1_ treat_female treat_asian treat_white treat_liberal treat_senior treat_ss guesses_b_ i.topic_id `ind_controls' `session_controls', cluster(zoom_id)
	eststo
	qui sum guesses_e_ if treat == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)

esttab using "$output/het_endline.tex", ///
se lab stats(Cmean Csd ids,labels("Mean" "SD" "IDs")) keep(treat*) star( * 0.1 ** 0.05 *** 0.01) ///
varwidth(32) wrap compress nogap noconstant replace ///
title("TC_het_endline") 

