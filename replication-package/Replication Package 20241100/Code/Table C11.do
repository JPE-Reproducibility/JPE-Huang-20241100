*** Table C.11: Private Beliefs Among Silent vs. Expressive Participants

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


gen byte first_mover = 0
append using "$tempfile/first_movers_long.dta"
replace first_mover = 1 if missing(first_mover)

replace private_ = 1 - private_ ///
	if first_mover == 1 & inlist(topic, "immunizations", "affirmative_action")

replace guesses_ = 100 - guesses_ ///
	if first_mover == 1 & inlist(topic, "immunizations", "affirmative_action")
	
* e_d_ == 0: stayed silent or did not express their private view
* e_d_ == 1: publicly expressed their private view
* prtest returns r(P1) for the first group (e_d_ == 0) and r(P2) for the second.
* r(p_l) is the one-sided p-value for P1 < P2, which is what the paper reports.

local var1 rename_schools
local var2 affirmative_action
local var3 death_penalty
local var4 immunizations

local lab1 "Renaming Schools"
local lab2 "Affirmative Action"
local lab3 "Death Penalty"
local lab4 "Immunizations"

cap file close c11
file open c11 using "$output/dist_private_silent.tex", write replace
file write c11 "\begin{tabular}{l*{4}c}\toprule " _n
file write c11 "& \%Agree Among Silence & \%Agree Among Expressed & p-value (one-sided) \\" _n
file write c11 "\midrule" _n

forval i = 1/4 {

	local v = "`var`i''"

	di _n as txt "{bf:`lab`i''}"
	prtest private_ if topic == "`v'", by(e_d_)

	local p1 = 100*r(P1)
	local p2 = 100*r(P2)
	local pv = r(p_l)

	file write c11 "`lab`i''" " & " %4.1f (`p1') "\% & " %4.1f (`p2') "\% & " %4.2f (`pv') " \\" _n
}

file write c11 "\midrule" _n

di _n as txt "{bf:Total}"
prtest private_, by(e_d_)

local p1 = 100*r(P1)
local p2 = 100*r(P2)
local pv = r(p_l)

file write c11 "Total & " %4.1f (`p1') "\% & " %4.1f (`p2') "\% & " %4.2f (`pv') " \\" _n
file write c11 "\bottomrule" _n
file write c11 "\end{tabular}" _n
file close c11


