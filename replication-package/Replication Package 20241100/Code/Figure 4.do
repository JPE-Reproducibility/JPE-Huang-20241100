

* Figure 4: Perceived Popularity of Socially Appropriate View at Midline
use "$data/TC_cleaned.dta", clear
	
keep *rename_schools *affirmative_action *death_penalty *immunizations ///
	 treat e_* gender race year major ideology survey_id zoom_id moderator week group_size session_time
	  
foreach var in rename_schools affirmative_action death_penalty immunizations {
	rename guesses_`var' guesses_b_`var'
}

reshape long private_ guesses_b_ guesses_m_ guesses_e_ , i(survey_id) j(topic) string
encode topic, generate(topic_id)
replace topic_id = topic_id + 1 
replace topic_id = 1 if topic_id == 5 // adjust the order of topics
forval i = 1/4{
	qui sum private_ if topic_id == `i'
	local actual_`i' = round(r(mean)*100,0.01)
}

local expressed_1 = round(7/12*100,0.01)
local expressed_2 = round(7/12*100,0.01)
local expressed_3 = round(9/13*100,0.01)
local expressed_4 = round(11/12*100,0.01)

label define topic_label 1 "Renaming Schools" 2 "Affirmative Action" 3 "Death Penalty" 4 "Immunizations" 
label values topic_id topic_label 

label define treat_label 0 "Control (A+D)" 1 "Treat (A+D+S)"
label values treat treat_label


distinct survey_id 
local n_total = r(ndistinct)

cibar guesses_m_, over(treat topic_id)  barlabel(on) blf(%9.1f)  blgap(-30) baropts(lcolor(none)) barcolor(cranberry%35 midblue%35) ciopts(lcolor(gs5)) ///
graphopts(legend(position(0) bplacement(nwest)) ylabel(0(10)100, nogrid) xlab(, nogrid labsize(small))  ytitle("Perceived %Agree") title("Perceived %Agree,  by Topic") subtitle("N = `n_total'")  ///
graphregion(color(white))  ///
ttext(`actual_1' 1.5 "------------------", color(green)) ///
ttext(`actual_2' 4.16 "------------------", color(green)) ///
ttext(`actual_3' 6.84 "-------------------", color(green)) ///
ttext(`actual_4' 9.52 "------------------", color(green)) ///
ttext(`expressed_1' 1.5 "------------------", color(gs9)) ///
ttext(`expressed_2' 4.16 "------------------", color(gs9)) ///
ttext(`expressed_3' 6.84 "------------------", color(gs9))  ///
ttext(`expressed_4' 9.51 "------------------", color(gs9)) ///
ttext(86.2 1 "-----  Actual", color(green)) ///
ttext(81.5 1.7 "-----  Expressed (FM)", color(gs9))) 
graph export "$output/inference_midline_2.png", replace

