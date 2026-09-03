*** Table C.6: Summary Statistics of All First Movers
use "$data/first_movers_analysis.dta", clear

foreach var in rename_schools affirmative_action death_penalty immunizations {
	qui replace e_`var' = 9 if e_`var' == .
}

local var1 rename_schools
local var2 affirmative_action
local var3 death_penalty
local var4 immunizations

local lab1 "Renaming Schools"
local lab2 "Affirmative Action"
local lab3 "Death Penalty"
local lab4 "Immunizations"

local agr1 1
local agr2 0
local agr3 1
local agr4 0

cap file close c6
file open c6 using "$output/summary_first_movers_r.tex", write replace
file write c6 "\begin{tabular}{l*{6}c}\toprule " _n
file write c6 "& Agree & Disagree & Silent & Total \\" _n
file write c6 "\midrule" _n

forval i = 1/4 {

	local v = "`var`i''"
	local a = `agr`i''
	local d = 1 - `a'

	qui count if e_`v' == `a'
	local nA = r(N)
	qui count if e_`v' == `d'
	local nD = r(N)
	qui count if e_`v' == 9
	local nS = r(N)
	local nT = `nA' + `nD' + `nS'

	file write c6 "`lab`i''" " & " %2.0f (`nA') " & " %2.0f (`nD') " & " %2.0f (`nS') " & " %2.0f (`nT') " \\" _n

	* also display, so the log carries the underlying cross-tab
	di _n as txt "{bf:`lab`i''}"
	tab e_`v' private_`v'
}

file write c6 "\bottomrule" _n
file write c6 "\end{tabular}" _n
file close c6
