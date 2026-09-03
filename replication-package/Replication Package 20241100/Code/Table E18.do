use "$data/extremity_TC_merged.dta", clear

preserve
foreach var in renaming aa death_penalty immunizations{
	rename `var'_private private_`var'
}

keep private_* gender race year major ideology native_speaker treat id

reshape long private_, i(id) j(topic) string

rename private_ private
encode topic, generate(topic_id)
save "$tempfile/private_demographics_long.dta", replace

restore

foreach var in renaming aa death_penalty immunizations{
	rename `var'_private private_`var'
	forval i = 1/5{
		rename `var'_guesses_`i' guesses_`var'_`i'
		rename `var'_m_`i' m_`var'_`i'
	}
}

keep m_* guesses_* gender race year major ideology native_speaker id

reshape long guesses_ m_, i(id) j(topic_scale) string

gen topic_id =. 
replace topic_id = 1 if strpos(topic_scale, "aa")
replace topic_id = 2 if strpos(topic_scale, "death_penalty")
replace topic_id = 3 if strpos(topic_scale, "immunizations")
replace topic_id = 4 if strpos(topic_scale, "renaming")

gen scale = . 
replace scale = 1 if strpos(topic_scale, "1")
replace scale = 2 if strpos(topic_scale, "2")
replace scale = 3 if strpos(topic_scale, "3")
replace scale = 4 if strpos(topic_scale, "4")
replace scale = 5 if strpos(topic_scale, "5")

bysort id topic_id: egen m_agree = total(m_) if scale == 4 | scale == 5
bysort id topic_id: egen m_disagree = total(m_) if scale == 1 | scale == 2
bysort id topic_id: egen m_extreme = total(m_) if scale == 1 | scale == 5

bysort id topic_id: egen b_1 = total(guesses_) if scale == 1
bysort id topic_id: egen b_2 = total(guesses_) if scale == 2
bysort id topic_id: egen b_3 = total(guesses_) if scale == 3
bysort id topic_id: egen b_4 = total(guesses_) if scale == 4

collapse (mean) m_agree m_disagree m_extreme b_1 b_2 b_3 b_4, by(id topic_id)

merge 1:1 id topic_id using "$tempfile/private_demographics_long"
drop _merge

local controls private b_1 b_2 b_3 b_4 i.gender i.race i.year i.major ideology i.native_speaker

eststo clear

reg m_agree treat i.topic_id, cluster(id)
	eststo
	qui sum m_agree 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(id)
	estadd scalar ids = round(r(ndistinct),1)

reg m_agree treat i.topic_id `controls', cluster(id)
	eststo
	qui sum m_agree 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(id)
	estadd scalar ids = round(r(ndistinct),1)
	
reg m_disagree treat i.topic_id, cluster(id)
	eststo
	qui sum m_disagree 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(id)
	estadd scalar ids = round(r(ndistinct),1)

reg m_disagree treat i.topic_id `controls', cluster(id)
	eststo
	qui sum m_disagree 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(id)
	estadd scalar ids = round(r(ndistinct),1)

reg m_extreme treat i.topic_id, cluster(id)
	eststo
	qui sum m_extreme 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(id)
	estadd scalar ids = round(r(ndistinct),1)

reg m_extreme treat i.topic_id `controls', cluster(id)
	eststo
	qui sum m_extreme
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(id)
	estadd scalar ids = round(r(ndistinct),1)
	
esttab using "$output/reg_tc_guesses_extremity.tex", ///
se lab stats(Cmean Csd ids,labels("Mean" "SD" "IDs")) keep(treat) star( * 0.1 ** 0.05 *** 0.01) ///
varwidth(32) wrap compress nogap noconstant replace ///
title("TC_guesses") //indicate("Individual Controls =  gender")

