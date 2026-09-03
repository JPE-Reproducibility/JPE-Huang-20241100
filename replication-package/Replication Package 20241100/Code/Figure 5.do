* Figure 5: Perceived %Agree Over Time

use "$data/TC_cleaned.dta", clear


local label_rename_schools "Renaming Schools"
local label_affirmative_action "Affirmative Action"
local label_death_penalty "Death Penalty"
local label_immunizations "Immunizations"
local label_daylight_saving "Daylight Saving Time"

distinct survey_id if treat == 0 
local n_c = r(ndistinct)
	
distinct survey_id if treat == 1
local n_t = r(ndistinct)

distinct survey_id 

local n_total = r(ndistinct)


foreach var in rename_schools affirmative_action death_penalty immunizations daylight_saving{
	preserve
	sum private_`var'
	local actual_mean = string(r(mean)*100,"%8.2f")

keep survey_id guesses*`var' treat
rename guesses_`var' guesses_1 
rename guesses_m_`var' guesses_2
rename guesses_e_`var' guesses_3

reshape long guesses_, i(survey_id) j(round)
sum guesses_ if round == 1
local baseline = string(r(mean),"%8.2f")

*ttest guesses_, by(round) if round == 1 | round == 3
 
collapse (mean) mean_p = guesses_ (sd) sd_p=guesses_, by(round treat)
	
	gen p_lb_c= mean_p - 1.96*sd_p/sqrt(`n_c')
	gen p_ub_c= mean_p + 1.96*sd_p/sqrt(`n_c')

	gen p_lb_t= mean_p - 1.96*sd_p/sqrt(`n_t')
	gen p_ub_t= mean_p + 1.96*sd_p/sqrt(`n_t')

	twoway (connected mean_p round if treat == 0, mcolor(red) lcolor(red) msymbol(circle)) (rcap p_lb_c p_ub_c round if treat == 0, mcolor(red) lcolor(red)) ///
	(connected mean_p round if treat == 1, mcolor(blue) msymbol(triangle) lcolor(blue) lpattern(solid)) (rcap p_lb_t p_ub_t round if treat == 1, mcolor(blue) lcolor(blue)), ///
	ytitle("`label_`var'', % Agree") xtitle(Round) ylabel(30(20)90) xscale(range(0.9 3.1)) xlabel(1 "Baseline" 2 "Midline" 3 "Endline") ///
	yline(`actual_mean', lcolor(green) lpattern(dash)) ttext(`actual_mean' 2.8 "Private: `actual_mean'%") ///
	yline(`baseline', lcolor(orange) lpattern(dash)) ttext(`baseline' 2.3 "Baseline: `baseline'%") ///
	title("Perceived  % Agree, `label_`var''") subtitle("N = `n_total'") graphregion(fcolor(white)) legend(order(1 "Control (A+D)" 3 "Treat (A+D+S)") position(6) rows(1)) aspectratio(0.5) graphregion(margin(1 1 1 1)) plotregion(margin(0 0 0 0))
	graph export "$output/inference_`var'.png", replace	
restore

}
