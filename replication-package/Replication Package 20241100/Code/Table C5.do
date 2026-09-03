*** Table C.5: Summary Statistics of First Movers Used in Information Interventions
*
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

cap file close c5
file open c5 using "$output/summary_first_movers.tex", write replace
file write c5 "\begin{tabular}{l*{6}c}\toprule " _n
file write c5 "& Agree & Disagree & Silent & Total \\" _n
file write c5 "\midrule" _n

forval i = 1/4 {

	local v = "`var`i''"
	local a = `agr`i''
	local d = 1 - `a'

	qui count if e_`v' == `a' & (zoom_id == 2 | zoom_id == 6)
	local nA = r(N)
	qui count if e_`v' == `d' & (zoom_id == 2 | zoom_id == 6)
	local nD = r(N)
	qui count if e_`v' == 9 & (zoom_id == 2 | zoom_id == 6)
	local nS = r(N)
	local nT = `nA' + `nD' + `nS'

	file write c5 "`lab`i''" " & " %2.0f (`nA') " & " %2.0f (`nD') " & " %2.0f (`nS') " & " %2.0f (`nT') " \\" _n

	di _n as txt "{bf:`lab`i''}  (sessions 2 and 6)"
	tab e_`v' private_`v' if zoom_id == 2 | zoom_id == 6
}

file write c5 "\bottomrule" _n
file write c5 "\end{tabular}" _n
file close c5
