use "$data/TC_first_movers_merged.dta", clear

gen female = 0
replace female = 1 if gender == 2

gen asian = 0 
replace asian = 1 if race == 2

gen white = 0 
replace white = 1 if race == 6

local label_rename_schools "Rename Schools"
local label_affirmative_action "Affirmative Actions"
local label_death_penalty "Death Penalty"
local label_immunizations "Immunizations"
local label_daylight_saving "Daylight Saving Time"
local label_religion_employ "Religion Employment"

gen first_movers = 0 
replace first_movers = 1 if treat ==. 

distinct survey_id if treat == . 
local n_f = r(ndistinct)

distinct survey_id if treat == 0 
local n_c = r(ndistinct)
	
distinct survey_id if treat == 1
local n_t = r(ndistinct)

distinct survey_id 
local n_total = r(ndistinct)

cap file close _all

file open myfile using "$output/summary_ftc.tex", write replace
file write myfile "\begin{tabular}{l*{6}c}"
file write myfile "\toprule"
file write myfile " & \textbf{Whole Sample} & \textbf{First Movers} & \textbf{Control}  & \textbf{Treatment} & \textbf{P Value: } & \textbf{P Value} \\"

file write myfile " & (N = `n_total') & (N = `n_f') & (N = `n_c')  & (N = `n_t') &  1st/2nd Movers & Control/Treat \\"

file close myfile

********* Demographics ****************
file open myfile using "$output/summary_ftc.tex", write append
file write myfile "\midrule "
file write myfile "\multicolumn{7}{l}{Panel A: Demographics} \\"
file write myfile "\midrule "
file close myfile

label var female "Female"
label var year "Year"
label var ideology "Ideology"


foreach x of varlist female year asian white ideology {
   sum `x' 
   scalar mean_a = r(mean)
   scalar sd_a = r(sd)
   
   sum `x' if treat == .
   scalar mean_f = r(mean)  
   scalar sd_f = r(sd)
   
   sum `x' if treat == 0
   scalar mean_g = r(mean)  
   scalar sd_g = r(sd)
   
   sum `x' if treat == 1
   scalar mean_n = r(mean)  
   scalar sd_n = r(sd)
   
   ttest `x', by(first_movers)
   scalar p_1 = r(p)
   
   ttest `x', by(treat)
   scalar p_2 = r(p)
   
   cap file close _all
   file open myfile using "$output/summary_ftc.tex", write append
   file write myfile "`: var label `x''" "&" %8.2f (mean_a) "&" %8.2f (mean_f) "&" %8.2f (mean_g) ///
   "&" %8.2f (mean_n) "&" %8.2f (p_1) "&" %8.2f (p_2)  "\\" 
    file write myfile  "&" "(" %8.2f (sd_a) ")" "&" %8.2f "(" (sd_f) ")" "&" %8.2f "("(sd_g) ")" ///
   "&" %8.2f "(" (sd_n) ")" "&"  "&"   "\\" 
   file close myfile
}


file open myfile using "$output/summary_ftc.tex", write append
file write myfile "\midrule "
file write myfile "\multicolumn{7}{l}{Panel B: Private Beliefs} \\"
file write myfile "\midrule "
file close myfile

label var private_rename_schools "Rename Schools"
label var private_affirmative_action "Affirmative Action"
label var private_death_penalty "Death Penalty"
label var private_immunizations "Immunizations"
label var private_daylight_saving "DST"

foreach x of varlist private_rename_schools private_affirmative_action private_death_penalty private_immunizations private_daylight_saving {
   sum `x' 
   scalar mean_a = r(mean)
   scalar sd_a = r(sd)
   
   sum `x' if treat == .
   scalar mean_f = r(mean)  
   scalar sd_f = r(sd)
   
   sum `x' if treat == 0
   scalar mean_g = r(mean)  
   scalar sd_g = r(sd)
   
   sum `x' if treat == 1
   scalar mean_n = r(mean)  
   scalar sd_n = r(sd)
   
   ttest `x', by(first_movers)
   scalar p_1 = r(p)
   
   ttest `x', by(treat)
   scalar p_2 = r(p)
   
   cap file close _all
   file open myfile using "$output/summary_ftc.tex", write append
   file write myfile "`: var label `x''" "&" %8.2f (mean_a) "&" %8.2f (mean_f) "&" %8.2f (mean_g) ///
   "&" %8.2f (mean_n) "&" %8.2f (p_1) "&" %8.2f (p_2)  "\\" 
    file write myfile  "&" "(" %8.2f (sd_a) ")" "&" %8.2f "(" (sd_f) ")" "&" %8.2f "("(sd_g) ")" ///
   "&" %8.2f "(" (sd_n) ")" "&"  "&"   "\\" 
   file close myfile
}

file open myfile using "$output/summary_ftc.tex", write append
file write myfile "\midrule "
file write myfile "\multicolumn{7}{l}{Panel C: Baseline Guesses} \\"
file write myfile "\midrule "
file close myfile

label var guesses_rename_schools "Rename Schools"
label var guesses_affirmative_action "Affirmative Action"
label var guesses_death_penalty "Death Penalty"
label var guesses_immunizations "Immunizations"
label var guesses_daylight_saving "DST"

foreach x of varlist guesses_rename_schools guesses_affirmative_action guesses_death_penalty guesses_immunizations guesses_daylight_saving {
   sum `x' 
   scalar mean_a = r(mean)
   scalar sd_a = r(sd)
   
   sum `x' if treat == .
   scalar mean_f = r(mean)  
   scalar sd_f = r(sd)
   
   sum `x' if treat == 0
   scalar mean_g = r(mean)  
   scalar sd_g = r(sd)
   
   sum `x' if treat == 1
   scalar mean_n = r(mean)  
   scalar sd_n = r(sd)
   
   ttest `x', by(first_movers)
   scalar p_1 = r(p)
   
   ttest `x', by(treat)
   scalar p_2 = r(p)
   
   cap file close _all
   file open myfile using "$output/summary_ftc.tex", write append
   file write myfile "`: var label `x''" "&" %8.2f (mean_a) "&" %8.2f (mean_f) "&" %8.2f (mean_g) ///
   "&" %8.2f (mean_n) "&" %8.2f (p_1) "&" %8.2f (p_2)  "\\" 
    file write myfile  "&" "(" %8.2f (sd_a) ")" "&" %8.2f "(" (sd_f) ")" "&" %8.2f "("(sd_g) ")" ///
   "&" %8.2f "(" (sd_n) ")" "&"  "&"   "\\" 
   file close myfile
}

file open myfile using "$output/summary_ftc.tex", write append
file write myfile "\bottomrule "
file write myfile "\end{tabular} "

file close myfile

