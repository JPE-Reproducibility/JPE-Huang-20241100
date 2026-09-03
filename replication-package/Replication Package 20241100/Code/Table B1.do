*** Table B.1: Perceived Social Appropriateness of each Statement

use "$data/recruitment_baseline.dta", clear

*------------------------------------------------------------------------------
* REVERSE-CODED ITEMS
*
* The appropriateness scale was presented in the opposite order in Qualtrics for
* the statements listed below, so that for them 1 = "Very appropriate". They are
* recoded here so that every item runs 1 = "Very inappropriate" through
* 5 = "Very appropriate".
*------------------------------------------------------------------------------

local reverse nv_crimes immunizations religion_employ trans_athletes

foreach v of local reverse {
	qui replace norm_`v' = 6 - norm_`v'
}

* Items shown in Table B.1, in the order they appear in the paper. The baseline
* survey covered six further topics (cancel_culture, electoral_college,
* gig_workers, islamic_religion, israel_pse, reparations_slavery) that are not
* reported in the paper and are omitted here.

local var1  affirmative_action
local var2  nv_crimes
local var3  death_penalty
local var4  daylight_saving
local var5  imm_citizenship
local var6  immunizations
local var7  college_require
local var8  religion_employ
local var9  rename_schools
local var10 trans_athletes

local lab1  "Affirmative Action"
local lab2  "Criminalization"
local lab3  "Death Penalty"
local lab4  "DST (P)"
local lab5  "Immigration"
local lab6  "Immunizations"
local lab7  "Job Requirements (P)"
local lab8  "Religious Values"
local lab9  "Renaming Schools"
local lab10 "Transgender Athletes"

cap file close b1
file open b1 using "$output/appropriateness_summary.tex", write replace

file write b1 "\begin{tabular}{l*{6}c}\toprule " _n
file write b1 "Topic & Very Inappropriate & Somewhat Inappropriate & Neutral & Somewhat Appropriate & Very Appropriate \\" _n
file write b1 "\midrule" _n

forval i = 1/10 {

	local v  "`var`i''"
	local nm "`lab`i''"

	qui count if norm_`v' < .
	local N = r(N)

	* row percentages, and the modal category (shown in bold, as in the paper)
	local best = -1
	forval k = 1/5 {
		qui count if norm_`v' == `k'
		local p`k' = 100*r(N)/`N'
		if (`p`k'' > `best') {
			local best = `p`k''
			local mode = `k'
		}
	}

	file write b1 "`nm'"
	forval k = 1/5 {
		if (`k' == `mode')  file write b1 " & \textbf{" %4.2f (`p`k'') "}"
		else                file write b1 " & " %4.2f (`p`k'')
	}
	file write b1 " \\" _n
}

file write b1 "\bottomrule" _n
file write b1 "\end{tabular}" _n
file close b1

forval i = 1/10 {
	local v "`var`i''"
	di _n as txt "{bf:`lab`i''}"
	tab norm_`v'
}
