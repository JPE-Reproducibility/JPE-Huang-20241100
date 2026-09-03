
use "$data/recruitment_baseline_2nd.dta", clear

preserve
collapse (mean) private*
gen i = _n
reshape long private_, i(i) j(topic) string
rename private_ private_mean
drop if topic == "free_speech" | topic == "homeless_camps" | topic == "peoples_park" | topic == "immunizations"

save "$tempfile/private_mean_2nd.dta", replace
restore

foreach var in rename_schools trans_athletes affirmative_action immigrants daylight_saving college_require death_penalty marijuana tariffs parents_smartphone {
	replace guesses_`var' = guesses_`var'/100 
}

preserve
collapse (mean) guesses*
gen i = _n
reshape long guesses_, i(i) j(topic) string
rename guesses_ guesses_mean
drop if topic == "free_speech" | topic == "homeless_camps" | topic == "peoples_park" | topic == "immunizations"

save "$tempfile/guesses_mean_2nd.dta", replace
restore

preserve
collapse (sd) guesses*
gen i = _n
reshape long guesses_, i(i) j(topic) string
rename guesses_ guesses_sd
drop if topic == "free_speech" | topic == "homeless_camps" | topic == "peoples_park" | topic == "immunizations"

save "$tempfile/guesses_sd_2nd.dta", replace
restore

qui sum guesses_affirmative_action
local n = r(N)

use "$tempfile/private_mean_2nd.dta", clear
merge 1:1 topic using "$tempfile/guesses_mean_2nd.dta"
drop _merge
merge 1:1 topic using "$tempfile/guesses_sd_2nd.dta"
drop _merge

drop i
gen topic_id = _n 
gen guesses_ub = guesses_mean + 1.96*guesses_sd/sqrt(`n')
gen guesses_lb = guesses_mean - 1.96*guesses_sd/sqrt(`n')
gen misperception = abs(guesses_mean - private_mean)
save "$tempfile/private_guesses_2nd.dta", replace

use "$data/TC_cleaned_2nd.dta", clear


local label_rename_schools "Rename Schools"
local label_affirmative_action "Affirmative Actions"
local label_death_penalty "Death Penalty"
local label_marijuana "Legalize Marijuana"
local label_daylight_saving "Daylight Saving Time"
local label_college_require "College Requirement"

	
foreach var in rename_schools affirmative_action death_penalty marijuana daylight_saving{
	preserve
	use "$tempfile/private_guesses_2nd.dta", clear

	sum private_mean if topic == "`var'"
	local actual_mean = string(r(mean)*100,"%8.2f")
	restore 
	
	preserve
	*drop if zoom_id == 17 | zoom_id == 18

distinct survey_id if treat == 0 
local n_c = r(ndistinct)
	
distinct survey_id if treat == 1
local n_t = r(ndistinct)

distinct survey_id 

local n_total = r(ndistinct)

keep survey_id guesses*`var' treat
rename guesses_`var' guesses_1 
rename guesses_m_`var' guesses_2
rename guesses_e_`var' guesses_3

reshape long guesses_, i(survey_id) j(round)
sum guesses_ if round == 1
local baseline = string(r(mean),"%8.2f")

collapse (mean) mean_p = guesses_ (sd) sd_p=guesses_, by(round treat)
	
	gen p_lb_c= mean_p - 1.96*sd_p/sqrt(`n_c')
	gen p_ub_c= mean_p + 1.96*sd_p/sqrt(`n_c')

	gen p_lb_t= mean_p - 1.96*sd_p/sqrt(`n_t')
	gen p_ub_t= mean_p + 1.96*sd_p/sqrt(`n_t')

	twoway (connected mean_p round if treat == 0, mcolor(red) lcolor(red)) (rcap p_lb_c p_ub_c round if treat == 0, mcolor(red) lcolor(red)) ///
	(connected mean_p round if treat == 1, mcolor(blue) lcolor(blue) lpattern(solid)) (rcap p_lb_t p_ub_t round if treat == 1, mcolor(blue) lcolor(blue)), ///
	ytitle("`label_`var'', % Agree") xtitle(Round) ylabel(20(20)80) xscale(range(0.9 3.1)) xlabel(1 "Baseline" 2 "Midline" 3 "Endline") ///
	yline(`actual_mean', lcolor(green) lpattern(dash)) ttext(`actual_mean' 2.8 "`actual_mean'%") ///
	yline(`baseline', lcolor(orange) lpattern(dash)) ttext(`baseline' 2.3 "Baseline: `baseline'%") ///
	title("Perceived  % Agree, `label_`var''") subtitle("N = `n_total'") graphregion(fcolor(white)) legend(order(1 "Control (A+D)" 3 "Treat (A+D+S)") position(6) rows(1)) aspectratio(0.5) graphregion(margin(1 1 1 1)) plotregion(margin(0 0 0 0))
	graph export "$output/inference_`var'_2025.png", replace	
restore

}
