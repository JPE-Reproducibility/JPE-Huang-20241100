**** Test if posteriors are bimodal **** 
* k-density for midline and endline beliefs (for control and treat respectively), by topic
use "$data/TC_cleaned.dta", clear

keep *rename_schools *affirmative_action *death_penalty *immunizations *daylight_saving ///
	 treat e_* gender race year major ideology survey_id zoom_id moderator week group_size session_time
	 
	  
foreach var in rename_schools affirmative_action death_penalty immunizations{
	rename guesses_`var' guesses_b_`var'
	
}

local label_rename_schools "Renaming Schools"
local label_affirmative_action "Affirmative Action"
local label_death_penalty "Death Penalty"
local label_immunizations "Immunizations"

foreach var in rename_schools affirmative_action death_penalty immunizations{
	twoway(kdensity guesses_b_`var' if treat == 0, bwidth(6) lcolor(gs80) lpattern(shortdash)) ///
	(kdensity guesses_m_`var' if treat == 0, bwidth(6) lcolor(red)) ///
	(kdensity guesses_m_`var' if treat == 1, bwidth(6) lcolor(blue)), ///
	legend(order(1 2 3 4 5) label(1 "Baseline") label(2 "Midline, Control") label(3 "Midline, Treat") position(6) rows(1)) xtitle("Guesses: % Agree, `label_`var''") ytitle(Kernel Density) title("Kernel Density of % Agree, `label_`var''")
	graph export "$output/kdensity_`var'.png", replace	
}

