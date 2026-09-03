import excel using "$data/Berkeley_renaming.xlsx", firstrow clear

gen private_agree = 2-Q22
drop Q22
label define agree 1 "Privately Agree" 0 "Privately Disagree"
label values private_agree agree


rename Q51_1 guess_agree
rename Q52 guess_certain

gen sign = 0
replace sign = 1 if Q61_1!="" | Q71_1!=""

rename Q82 gender
rename Q83 ethnicity
rename Q84 year
rename Q85 major
rename Q86 ideology

gen group =. 
replace group = 0 if FL_21_DO == "summary_placebo"
replace group = 1 if FL_21_DO == "summary_control"
replace group = 2 if FL_21_DO == "summary_treat"

label define groups 0 "Omit Agree" 1 "Control (A+D)" 2 "Treatment"
label values group groups

* Regression: guesses and expression
rename id survey_id
local controls i.gender i.ethnicity i.year i.ideology i.major

eststo clear

reg guess_agree ib1.group  //omitted group: control
	eststo
	qui sum guess_agree if group == 1
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)
	test 0.group = 2.group
	estadd scalar p_diff = r(p)

reg guess_agree ib1.group  private_agree `controls'
	eststo
	qui sum guess_agree if group == 1
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)
	test 0.group = 2.group
	estadd scalar p_diff = r(p)
	
reg sign ib1.group if private_agree == 0 
	eststo
	qui sum sign if group == 1 & private_agree == 0
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)
	test 0.group = 2.group
	estadd scalar p_diff = r(p)

reg sign ib1.group `controls' if private_agree == 0 
	eststo
	qui sum sign if group == 1 & private_agree == 0
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)
	test 0.group = 2.group
	estadd scalar p_diff = r(p)
	
reg sign ib1.group if private_agree == 1 
	eststo
	qui sum sign if group == 1 & private_agree == 1
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)
	test 0.group = 2.group
	estadd scalar p_diff = r(p)

reg sign ib1.group `controls' if private_agree == 1 
	eststo
	qui sum sign if group == 1 & private_agree == 1
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	distinct(survey_id)
	estadd scalar ids = round(r(ndistinct),1)
	test 0.group = 2.group
	estadd scalar p_diff = r(p)
	
esttab using "$output/reg_renaming.tex", ///
se lab keep(0.group 2.group) order(0.group 2.group) stats(p_diff Cmean Csd ids,labels("p-value Omit Agree - Treatment" "Mean" "SD" "IDs")) star( * 0.1 ** 0.05 *** 0.01) ///
varwidth(32) wrap compress nogap noconstant replace ///
title("OLS Renaming") //indicate("Individual Controls =  gender")

