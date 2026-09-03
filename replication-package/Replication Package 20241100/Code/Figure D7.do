*** Correlation Matrix of Private Views across Topics **** 

use "$data/TC_cleaned.dta", clear
pwcorr private_rename_schools private_affirmative_action private_death_penalty ///
       private_immunizations private_daylight_saving private_trans_athletes, sig

local dummies private_rename_schools private_affirmative_action private_death_penalty ///
             private_immunizations private_daylight_saving private_trans_athletes

* 1) Correlation matrix
quietly correlate `dummies'
matrix C = r(C)

matrix L = C
local k = colsof(L)
forvalues i = 1/`k' {
    forvalues j = `=`i'+1'/`k' {
        matrix L[`i',`j'] = .
    }
}

matrix colnames L = RenameSchools AA DeathPenalty Immunizations DST TransAthletes
matrix rownames L = RenameSchools AA DeathPenalty Immunizations DST TransAthletes

heatplot L, ///
    color(RdBu) cuts(-1(0.2)1) ///
    values(format(%4.2f) size(vsmall)) ///
    aspect(1) ///
    xlabel(, angle(45) labsize(small)) ///
    ylabel(, labsize(small)) ///
    legend(off) ///
    title("Correlation Heat Map (Private Views)", size(medsmall)) ///
    graphregion(color(white)) plotregion(margin(zero))
	
graph export "$output/corr_heatmap.png", replace
