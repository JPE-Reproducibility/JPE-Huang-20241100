*** Table E.23: Silence and Misperception in the ANES, 1974-2020
***
*** Panel A uses the full ANES time series; Panel B restricts to in-person interviews.

insheet using "$data/anes_full.csv", clear

drop if year < 1974 
keep if misperception !=. & n_silent!=0
gen frac_silent = n_silent/n

gen id = _n
gen party = 1
replace party = 2 if mod(id, 2) == 0
drop id

gen perceived = .
replace perceived = actual - misperception_a if party == 1
replace perceived = actual + misperception_a if party == 2

encode topic, gen(topic_id)
reg misperception_a i.year i.topic_id 
predict misperception_a_hat, xb
gen misperception_a_res = misperception_a - misperception_a_hat


eststo clear
reg misperception frac_silent 
	eststo 
	qui sum misperception 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	estadd scalar Ns = r(N)
	
reg misperception frac_silent salience i.year i.topic_id 
	eststo 
	qui sum misperception 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	estadd scalar Ns = r(N)

reg misperception frac_silent actual salience i.year i.topic_id
	eststo 
	qui sum misperception 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	estadd scalar Ns = r(N)

	
reg misperception_a frac_silent
	eststo 
	qui sum misperception_a
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	estadd scalar Ns = r(N)
	
reg misperception_a frac_silent salience i.year i.topic_id
	eststo 
	qui sum misperception_a 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	estadd scalar Ns = r(N)
	
reg misperception_a frac_silent actual salience i.year i.topic_id 
	eststo 
	qui sum misperception_a
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	estadd scalar Ns = r(N)

	
esttab using "$output/reg_anes_all.tex", ///
se lab stats(Cmean Csd Ns,labels("Mean" "SD" "N")) keep(frac_silent) star( * 0.1 ** 0.05 *** 0.01) ///
varwidth(32) wrap compress nogap noconstant replace ///
title("ANES all")


insheet using "$data/anes_full_inperson.csv", clear

drop if year < 1974 
keep if misperception !=. & n_silent!=0
gen frac_silent = n_silent/n

gen id = _n
gen party = 1
replace party = 2 if mod(id, 2) == 0
drop id

gen perceived = .
replace perceived = actual - misperception_a if party == 1
replace perceived = actual + misperception_a if party == 2

encode topic, gen(topic_id)
reg misperception_a i.year i.topic_id 
predict misperception_a_hat, xb
gen misperception_a_res = misperception_a - misperception_a_hat


eststo clear
reg misperception frac_silent 
	eststo 
	qui sum misperception 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	estadd scalar Ns = r(N)
	
reg misperception frac_silent salience i.year i.topic_id 
	eststo 
	qui sum misperception 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	estadd scalar Ns = r(N)

reg misperception frac_silent actual salience i.year i.topic_id
	eststo 
	qui sum misperception 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	estadd scalar Ns = r(N)

	
reg misperception_a frac_silent
	eststo 
	qui sum misperception_a
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	estadd scalar Ns = r(N)
	
reg misperception_a frac_silent salience i.year i.topic_id
	eststo 
	qui sum misperception_a 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	estadd scalar Ns = r(N)
	
reg misperception_a frac_silent actual salience i.year i.topic_id 
	eststo 
	qui sum misperception_a 
	estadd scalar Cmean = r(mean)
	estadd scalar Csd = r(sd)
	estadd scalar Ns = r(N)

	
esttab using "$output/reg_anes_inperson.tex", ///
se lab stats(Cmean Csd Ns,labels("Mean" "SD" "N")) keep(frac_silent) star( * 0.1 ** 0.05 *** 0.01) ///
varwidth(32) wrap compress nogap noconstant replace ///
title("ANES all")
