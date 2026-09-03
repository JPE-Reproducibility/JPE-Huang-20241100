*** Table D.15: Treatment Effects on Latent Attention Types Across Topics
***
*** Displayed output only -- captured in logs/Table_D15.log by the master file.
*** The table is assembled by hand into Draft tex/Tables/ffm_midline.tex.
***
*==============================================================================
* WHERE EACH CELL OF TABLE D.15 COMES FROM
*
* The table has one COLUMN per topic, in this order:
*     (1) Renaming Schools   (2) Affirmative Action
*     (3) Death Penalty      (4) Immunizations
* and five ROWS. For each topic the numbers are read off the output of the two
* commands marked [A] and [B] in the loop below:
*
*   Row "%Agree, Type 1"      -> [A] the _cons of the regress equation for the
*   Row "%Agree, Type 2"          component with the LOWER (Type 1) and HIGHER
*                                 (Type 2) estimated mean, with its standard
*                                 error in parentheses beneath.
*
*   Row "Pr(Type 1| Control)" -> [B] the margins table, row treat = 0
*   Row "Pr(Type 1| Treat)"   -> [B] the margins table, row treat = 1
*                                 (delta-method standard errors in parentheses)
*
*   Row "p-value"             -> [A] the latent-class probability equation, the
*                                 p-value on 1.treat
*
* The -fmm 1- / -fmm 2- pairs with -estat ic- are not in the table. They are the
* one- versus two-component BIC comparison that motivates using two components;
* the two BIC values are noted in the comment beside each -estat ic-.
*==============================================================================

set seed 20260820

**** Test if posteriors are bimodal ****
use "$data/TC_cleaned.dta", clear

keep *rename_schools *affirmative_action *death_penalty *immunizations *daylight_saving ///
	 treat e_* gender race year major ideology survey_id zoom_id moderator week group_size session_time


foreach var in rename_schools affirmative_action death_penalty immunizations{
	rename guesses_`var' guesses_b_`var'

}

local label_rename_schools "Renaming Schools"
local label_affirmative_action "Affirmative Action"
local label_death_penalty "Death Penalty"
local label_immunizations "Immunizations"



* finite mixture model: "two types" + treatment shifts their share

*------------------------------------------------------------------ COLUMN (1)
local y guesses_m_rename_schools

fmm 1: regress `y'
estat ic
fmm 2: regress `y'
estat ic  //2625.7-2606.5

* [A] component means -> rows "%Agree, Type 1" and "%Agree, Type 2"
*     latent-class equation -> row "p-value" (p on 1.treat)
fmm 2, lcprob(i.treat): regress `y'

* [B] -> rows "Pr(Type 1| Control)" (treat = 0) and "Pr(Type 1| Treat)" (treat = 1)
margins treat, predict(classpr)

*------------------------------------------------------------------ COLUMN (2)
local y guesses_m_affirmative_action

fmm 1: regress `y'
estat ic

fmm 2: regress `y'
estat ic  //2633-2623.7

* [A] see the header block
fmm 2, lcprob(i.treat): regress `y'
* [B] see the header block
margins treat, predict(classpr)


*------------------------------------------------------------------ COLUMN (3)
local y guesses_m_death_penalty
fmm 1: regress `y'
estat ic

fmm 2: regress `y'
estat ic //2669.8-2658.7

* [A] see the header block
fmm 2, lcprob(i.treat): regress `y'
* [B] see the header block
margins treat, predict(classpr)

*------------------------------------------------------------------ COLUMN (4)
local y guesses_m_immunizations
fmm 1: regress `y'
estat ic
fmm 2: regress `y'
estat ic //2893.1-2710.6

* [A] see the header block
fmm 2, lcprob(i.treat): regress `y'
* [B] see the header block
margins treat, predict(classpr)


*==============================================================================
* VALIDATION EXERCISE -- not part of Table D.15.
*
* Produces the correlation quoted in the Appendix D.3 text:
* "a positive and statistically significant correlation between correct recall
*  and classification as the low-belief, silence-attentive type (Type 1)
*  (rho = 0.072, p = 0.009)".
*
*==============================================================================

*Combine that with the recall questions, correlationL 0.072
use "$data/TC_cleaned.dta", clear


* att_silence_ = 1 if the participant's recalled number of silent group members
foreach var in rename_schools affirmative_action death_penalty immunizations{
	gen att_silence_`var' = 0
	forval i = 1/36{
		quietly count if e_`var' == . & zoom_id == `i'
		local n_s_`i' = r(N)
		replace att_silence_`var' = 1 if abs(recall_`var'_s - `n_s_`i'')<=1  & zoom_id == `i'
	}
}

* frac_*_s_a is not used below; the summary is displayed for reference only.
foreach var in rename_schools affirmative_action death_penalty immunizations daylight_saving{
	gen frac_`var'_s_a = recall_`var'_s_a/recall_`var'_s
	preserve
	drop if frac_`var'_s_a > 1
	sum frac_`var'_s_a if treat == 1
	restore
}

foreach var in rename_schools affirmative_action death_penalty immunizations{
    fmm 2, lcprob(i.treat): regress guesses_m_`var'

    capture drop post*

    predict post*, classposteriorpr

    gen type_`var' = (post1 > 0.5)
}

preserve
keep att_silence* type_* treat gender race year major ideology survey_id zoom_id moderator week group_size session_time

reshape long att_silence_ type_ , i(survey_id) j(topic) string
encode topic, generate(topic_id)

* -> rho = 0.072, p = 0.009 as quoted in the Appendix D.3 text
pwcorr att_silence_ type_,sig
restore
