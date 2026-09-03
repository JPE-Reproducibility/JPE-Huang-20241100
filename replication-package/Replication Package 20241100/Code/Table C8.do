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

eststo clear

reg guesses_m_ treat i.topic_id if private_ == 0 
	quietly test treat
    estadd scalar Fstat = r(F)
	eststo fs1
	qui sum guesses_m_ if private_ == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)

reg guesses_m_ treat guesses_norm i.topic_id if private_ == 0, cluster(zoom_id)
    quietly test treat
    estadd scalar Fstat = r(F)
    eststo fs2
	qui sum guesses_m_ if private_ == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)

reg guesses_m_ treat guesses_norm i.topic_id `session_controls' if private_ == 0, cluster(zoom_id)
    quietly test treat
    estadd scalar Fstat = r(F)
    eststo fs3
	qui sum guesses_m_ if private_ == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)

reg guesses_m_ treat guesses_norm i.topic_id `session_controls' `ind_controls' if private_ == 0, cluster(zoom_id)
    quietly test treat
    estadd scalar Fstat = r(F)
    eststo fs4
	qui sum guesses_m_ if private_ == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)

reg express_d treat i.topic_id if private_ == 0, cluster(zoom_id)
	eststo rf1
	qui sum express_d if private_ == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)

reg express_d treat guesses_norm i.topic_id if private_ == 0, cluster(zoom_id)
	eststo rf2
	qui sum express_d if private_ == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)

reg express_d treat guesses_norm i.topic_id `session_controls' if private_ == 0, cluster(zoom_id)
	eststo rf3
	qui sum express_d if private_ == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)

reg express_d treat guesses_norm i.topic_id `session_controls' `ind_controls' if private_ == 0, cluster(zoom_id)
	eststo rf4	
	qui sum express_d if private_ == 0 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)

	esttab fs1 fs2 fs3 fs4 rf1 rf2 rf3 rf4 using "$output/first_reduced_minority_tc.tex", ///
    se star(* 0.1 ** 0.05 *** 0.01) keep(treat) label noconstant ///
    stats(Cmean Csd Fstat N, labels("Mean" "SD" "First-stage F" "Observations")) ///
    mtitles("FS (1)" "FS (2)" "FS (3)" "FS (4)" "RF (1)" "RF (2)" "RF (3)" "RF (4)") ///
    varwidth(22) wrap compress nogap replace ///
    title("First Stage and Reduced Form, Privately Disagree")


eststo clear

reg guesses_m_ treat i.topic_id if private_ == 1 
	quietly test treat
    estadd scalar Fstat = r(F)
	eststo fs1
	qui sum guesses_m_ if private_ == 1
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)

reg guesses_m_ treat guesses_norm i.topic_id if private_ == 1, cluster(zoom_id)
    quietly test treat
    estadd scalar Fstat = r(F)
    eststo fs2
	qui sum guesses_m_ if private_ == 1 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)

reg guesses_m_ treat guesses_norm i.topic_id `session_controls' if private_ == 1, cluster(zoom_id)
    quietly test treat
    estadd scalar Fstat = r(F)
    eststo fs3
	qui sum guesses_m_ if private_ == 1 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)

reg guesses_m_ treat guesses_norm i.topic_id `session_controls' `ind_controls' if private_ == 1, cluster(zoom_id)
    quietly test treat
    estadd scalar Fstat = r(F)
    eststo fs4
	qui sum guesses_m_ if private_ == 1 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)

reg express_d treat i.topic_id if private_ == 1, cluster(zoom_id)
	eststo rf1
	qui sum express_d if private_ == 1
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)

reg express_d treat guesses_norm i.topic_id if private_ == 1, cluster(zoom_id)
	eststo rf2
	qui sum express_d if private_ == 1 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)

reg express_d treat guesses_norm i.topic_id `session_controls' if private_ == 1, cluster(zoom_id)
	eststo rf3
	qui sum express_d if private_ == 1 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)

reg express_d treat guesses_norm i.topic_id `session_controls' `ind_controls' if private_ == 1, cluster(zoom_id)
	eststo rf4	
	qui sum express_d if private_ == 1
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)

	esttab fs1 fs2 fs3 fs4 rf1 rf2 rf3 rf4 using "$output/first_reduced_majority_tc.tex", ///
    se star(* 0.1 ** 0.05 *** 0.01) keep(treat) label noconstant ///
    stats(Cmean Csd Fstat N, labels("Mean" "SD" "First-stage F" "Observations")) ///
    mtitles("FS (1)" "FS (2)" "FS (3)" "FS (4)" "RF (1)" "RF (2)" "RF (3)" "RF (4)") ///
    varwidth(22) wrap compress nogap replace ///
    title("First Stage and Reduced Form, Privately Disagree")
	
