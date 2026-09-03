************** Attrition Table C.3 *****************
use "$data/attrition.dta", clear

gen female = 0
replace female = 1 if gender == 2

gen asian = 0 
replace asian = 1 if race == 2

gen white = 0 
replace white = 1 if race == 6


count if attr == 0 
local n_c = r(N)
	
count if attr == 1
local n_t = r(N)

count
local n_total = r(N)

cap file close _all

file open myfile using "$output/attrition.tex", write replace
file write myfile "\begin{tabular}{l*{8}c}"
file write myfile "\toprule"
file write myfile " & \multicolumn{2}{c}{\textbf{Whole Sample (N = `n_total')}} & \multicolumn{2}{c}{\textbf{Completed (N = `n_c')}}  & \multicolumn{2}{c}{\textbf{Attrition (N = `n_t')}} & \multicolumn{1}{c}{\textbf{T test}} \\"
file write myfile "\cmidrule(r){2-3} \cmidrule(r){4-5} \cmidrule(r){6-7}  \cmidrule(r){8-8} "
file write myfile " & Mean & Sd & Mean & Sd & Mean & Sd & P Value \\ "

file close myfile

********* Demographics ****************
file open myfile using "$output/attrition.tex", write append
file write myfile "\midrule "
file write myfile "\multicolumn{7}{l}{Panel A: Demographics} \\"
file write myfile "\midrule "
file close myfile

label var female "Female"
label var year "Year"
label var white "White"
label var asian "Asian"
label var ideology "Ideology"

foreach x of varlist female asian white year ideology {
   sum `x' 
   scalar mean_a = r(mean)
   scalar sd_a = r(sd)
   sum `x' if attr == 0
   scalar mean_g = r(mean)  
   scalar sd_g = r(sd)
   sum `x' if attr == 1
   scalar mean_n = r(mean)  
   scalar sd_n = r(sd)
   ttest `x', by(attr)
   scalar p = r(p)
   
   cap file close _all
   file open myfile using "$output/attrition.tex", write append
   file write myfile "`: var label `x''" "&" %8.2f (mean_a) "&" %8.2f (sd_a) "&" %8.2f (mean_g) ///
   "&" %8.2f (sd_g) "&" %8.2f (mean_n) "&" %8.2f (sd_n) "&" %8.2f (p) "\\" 
   
   file close myfile
}


file open myfile using "$output/attrition.tex", write append
file write myfile "\midrule "
file write myfile "\multicolumn{7}{l}{Panel B: Private Beliefs} \\"
file write myfile "\midrule "
file close myfile

label var private_rename_schools "Rename Schools"
label var private_affirmative_action "Affirmative Action"
label var private_death_penalty "Death Penalty"
label var private_immunizations "Immunizations"
label var private_dst "DST"

foreach x of varlist private_rename_schools private_affirmative_action private_death_penalty private_immunizations private_dst{
   sum `x' 
   scalar mean_a = r(mean)
   scalar sd_a = r(sd)
   sum `x' if attr == 0 
   scalar mean_g = r(mean)  
   scalar sd_g = r(sd)
   sum `x' if attr == 1
   scalar mean_n = r(mean)  
   scalar sd_n = r(sd)
   ttest `x', by(attr)
   scalar p = r(p)
   
   cap file close _all
   file open myfile using "$output/attrition.tex", write append
   file write myfile "`: var label `x''" "&" %8.2f (mean_a) "&" %8.2f (sd_a) "&" %8.2f (mean_g) ///
   "&" %8.2f (sd_g) "&" %8.2f (mean_n) "&" %8.2f (sd_n) "&" %8.2f (p) "\\" 
   
   file close myfile
}

file open myfile using "$output/attrition.tex", write append
file write myfile "\midrule "
file write myfile "\multicolumn{7}{l}{Panel C: Baseline Guesses} \\"
file write myfile "\midrule "
file close myfile

label var guesses_rename_schools "Rename Schools"
label var guesses_affirmative_action "Affirmative Action"
label var guesses_death_penalty "Death Penalty"
label var guesses_immunizations "Immunizations"
label var guesses_dst "DST"

foreach x of varlist guesses_rename_schools guesses_affirmative_action guesses_death_penalty guesses_immunizations guesses_dst{
   sum `x' 
   scalar mean_a = r(mean)
   scalar sd_a = r(sd)
   sum `x' if attr == 0 
   scalar mean_g = r(mean)  
   scalar sd_g = r(sd)
   sum `x' if attr == 1
   scalar mean_n = r(mean)  
   scalar sd_n = r(sd)
   ttest `x', by(attr)
   scalar p = r(p)
   
   cap file close _all
   file open myfile using "$output/attrition.tex", write append
   file write myfile "`: var label `x''" "&" %8.2f (mean_a) "&" %8.2f (sd_a) "&" %8.2f (mean_g) ///
   "&" %8.2f (sd_g) "&" %8.2f (mean_n) "&" %8.2f (sd_n) "&" %8.2f (p) "\\" 
   
   file close myfile
}


file open myfile using "$output/attrition.tex", write append
file write myfile "\midrule "
file write myfile "\multicolumn{7}{l}{Panel D: Treatment Assignment} \\"
file write myfile "\midrule "
file close myfile

label var treat "Treat"

foreach x of varlist treat{
   sum `x' 
   scalar mean_a = r(mean)
   scalar sd_a = r(sd)
   sum `x' if attr == 0 
   scalar mean_g = r(mean)  
   scalar sd_g = r(sd)
   sum `x' if attr == 1
   scalar mean_n = r(mean)  
   scalar sd_n = r(sd)
   ttest `x', by(attr)
   scalar p = r(p)
   
   cap file close _all
   file open myfile using "$output/attrition.tex", write append
   file write myfile "`: var label `x''" "&" %8.2f (mean_a) "&" %8.2f (sd_a) "&" %8.2f (mean_g) ///
   "&" %8.2f (sd_g) "&" %8.2f (mean_n) "&" %8.2f (sd_n) "&" %8.2f (p) "\\" 
   
   file close myfile
}
file open myfile using "$output/attrition.tex", write append
file write myfile "\bottomrule "
file write myfile "\end{tabular} "

file close myfile
