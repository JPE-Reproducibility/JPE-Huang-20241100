*** Figure 3: Misperceptions, differences between actual and perceived belief distribution 

use "$data/recruit_baseline_roster_TC.dta",clear

preserve
collapse (mean) private*
gen i = _n
reshape long private_, i(i) j(topic) string
rename private_ private_mean
keep if topic == "rename_schools" | topic == "affirmative_action" | topic == "dst" | topic == "death_penalty" | topic == "immunizations"

save "$tempfile/private_mean_tc.dta", replace
restore

foreach var in rename_schools affirmative_action dst death_penalty immunizations  {
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
keep if _merge == 3
drop _merge
merge 1:1 topic using "$tempfile/guesses_sd_tc.dta"
keep if _merge == 3
drop _merge

drop i
gen topic_id = _n 
gen guesses_ub = guesses_mean + 1.96*guesses_sd/sqrt(`n')
gen guesses_lb = guesses_mean - 1.96*guesses_sd/sqrt(`n')
gen misperception = abs(guesses_mean - private_mean)
save "$tempfile/private_guesses_tc.dta", replace

save "$tempfile/private_guesses_tc.dta", replace

set scheme s1mono // black and white

twoway (scatter topic_id private_mean, mcolor(green)) /// dot for actual %agree
	   (scatter topic_id guesses_mean, mcolor(orange)) /// dot for perceived %agree
	   (rcap guesses_lb guesses_ub topic_id, horizontal), /// confidence interval
	   legend(row(1) order(1 "Actual %Agree" 2 "Perceived %Agree")) /// 
	   ylabel(1 "Affirmative Action" 2 "Death Penalty" 3 "DST (Placebo)" 4 "Immunization" 5 "Rename Schools", angle(0) noticks) ///
    title("Actual and Perceived %Agree") subtitle("N = `n'") ///
    xtitle("Percent Agree") ytitle("") ///
    xlabel(0.1(0.1)0.9) xline(0.5, lcolor(black) lpattern(dot)) ///
	yscale(range(0.7 5.5)) ysc(reverse)
	graph export "$output/private_perceived_a.png", replace
  

