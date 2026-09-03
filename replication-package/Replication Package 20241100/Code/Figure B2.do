use "$data/recruit_baseline_roster_TC.dta", clear

preserve
collapse (mean) private*
gen i = _n
reshape long private_, i(i) j(topic) string
rename private_ private_mean
save "$tempfile/private_mean_tc.dta", replace
restore

foreach var in rename_schools trans_athletes affirmative_action imm_citizenship religion_employ dst job_require  death_penalty criminalization immunizations  {
	replace guesses_`var' = guesses_`var'/100 
}

preserve
collapse (mean) guesses*
gen i = _n
reshape long guesses_, i(i) j(topic) string
rename guesses_ guesses_mean
save "$tempfile/guesses_mean_tc.dta", replace
restore

preserve
collapse (sd) guesses*
gen i = _n
reshape long guesses_, i(i) j(topic) string
rename guesses_ guesses_sd
save "$tempfile/guesses_sd_tc.dta", replace
restore

qui sum guesses_rename_schools
local n = r(N)

use "$tempfile/private_mean_tc.dta", clear
merge 1:1 topic using "$tempfile/guesses_mean_tc.dta"
drop _merge
merge 1:1 topic using "$tempfile/guesses_sd_tc.dta"
drop _merge

drop i
gen topic_id = _n 
gen guesses_ub = guesses_mean + 1.96*guesses_sd/sqrt(`n')
gen guesses_lb = guesses_mean - 1.96*guesses_sd/sqrt(`n')
gen misperception = abs(guesses_mean - private_mean)
save "$tempfile/private_guesses_tc.dta", replace

set scheme s1mono // black and white

twoway (scatter topic_id private_mean, mcolor(green)) /// dot for actual %agree
	   (scatter topic_id guesses_mean, mcolor(orange)) /// dot for perceived %agree
	   (rcap guesses_lb guesses_ub topic_id, horizontal), /// confidence interval
	   legend(row(1) order(1 "Actual %Agree" 2 "Perceved %Agree")) /// 
	   ylabel(1 "Affirmative Action" 2 "Criminalization" 3 "Death Penalty" 4 "Daylight Saving"  5 "Immigrants" 6 "Immunization" 7 "Job requirements" 8 "Religion Employ" 9 "Rename Schools" 10 "Trans Athletes", angle(0) noticks) ///
	   title(Actual and Perceived %Agree) subtitle (N = `n') xtitle("Percent Agree") ytitle("") ///
	   xlabel(0(0.2)1) xline(0.5, lcolor(black) lpattern(dot)) ysc(reverse) 
	   graph export "$output/private_perceived_TC.png", replace
