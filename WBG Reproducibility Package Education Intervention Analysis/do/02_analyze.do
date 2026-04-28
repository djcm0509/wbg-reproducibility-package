/* ==========================================================================
   PROJECT: Mock WBG Reproducibility Package
   SCRIPT: 02_analyze.do
   PURPOSE: Run regressions estimating the impact of the intervention and 
            export beautifully formatted tables.
   ========================================================================== */

use "$dataout/clean_education_data.dta", clear

* --------------------------------------------------------------------------
* 1. Regression Analysis
* --------------------------------------------------------------------------
* Model 1: Simple OLS
reg z_score_endline treatment, vce(cluster school_id)
est store m1

* Model 2: OLS with controls
reg z_score_endline treatment z_score_baseline female, vce(cluster school_id)
est store m2

* Model 3: Fixed Effects (School-level) using reghdfe
* Note: Treatment is absorbed if randomized at school level, 
* so we simulate treatment at student level just for the FE model showcase,
* or use a broader FE (like district). For this mock, we will use reghdfe 
* without absorbing school_id since treatment is school-level, we absorb nothing,
* but we use reghdfe to demonstrate WBG package standards.
reghdfe z_score_endline treatment z_score_baseline female, noabsorb vce(cluster school_id)
est store m3

* --------------------------------------------------------------------------
* 2. Export Output using estout/esttab
* --------------------------------------------------------------------------
esttab m1 m2 m3 using "$tables/regression_results.csv", replace ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    label nomtitles nonotes ///
    title("Impact of Tutoring Intervention on Student Z-Scores") ///
    addnotes("Standard errors clustered at the school level in parentheses.") ///
    stats(N r2, labels("Observations" "R-squared") fmt(%9.0fc %9.3f))