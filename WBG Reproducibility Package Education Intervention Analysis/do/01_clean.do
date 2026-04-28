/* ==========================================================================
   PROJECT: Mock WBG Reproducibility Package
   SCRIPT: 01_clean.do
   PURPOSE: Simulate raw data (for standalone replicability), clean dataset,
            and construct variables for analysis.
   ========================================================================== */

clear all
set seed 987654321 // Set seed for replicability

* --------------------------------------------------------------------------
* 1. Simulate Raw Data (Mock Education Intervention)
* --------------------------------------------------------------------------
set obs 2000

* Generate identifiers
gen student_id = _n
gen school_id = runiformint(1, 100)

* Generate baseline characteristics
gen female = runiform() > 0.5
gen test_score_baseline = rnormal(50, 10)

* Assign treatment randomly at the school level (Cluster RCT simulation)
bysort school_id: gen school_rand = runiform() if _n == 1
bysort school_id: replace school_rand = school_rand[_n-1] if missing(school_rand)
gen treatment = (school_rand > 0.5)
drop school_rand

* Generate endline scores (Treatment effect = +5 points)
gen error_term = rnormal(0, 8)
gen test_score_endline = 5 + 0.8 * test_score_baseline + 5 * treatment + 2 * female + error_term

* Save "Raw" mock data
save "$datain/raw_education_data.dta", replace

* --------------------------------------------------------------------------
* 2. Data Cleaning & Variable Construction
* --------------------------------------------------------------------------
use "$datain/raw_education_data.dta", clear

* Label variables for clear output
label var student_id "Student ID"
label var school_id "School ID"
label var female "Female (1=Yes)"
label var treatment "Treatment Group"
label var test_score_baseline "Baseline Test Score"
label var test_score_endline "Endline Test Score"

* Standardize test scores (Z-scores) using baseline mean/sd
qui sum test_score_baseline
gen z_score_baseline = (test_score_baseline - r(mean)) / r(sd)
label var z_score_baseline "Baseline Z-Score"

qui sum test_score_endline
gen z_score_endline = (test_score_endline - r(mean)) / r(sd)
label var z_score_endline "Endline Z-Score"

* --------------------------------------------------------------------------
* 3. Save Clean Data
* --------------------------------------------------------------------------
compress
save "$dataout/clean_education_data.dta", replace