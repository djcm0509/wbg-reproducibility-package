/* ==========================================================================
   PROJECT: Mock WBG Reproducibility Package - Education Intervention
   SCRIPT: master.do
   PURPOSE: Set up environment, install dependencies, define relative paths,
            and run all subordinate scripts in sequence.
   AUTHOR: Reproducible Research Reviewer
   ========================================================================== */

* --------------------------------------------------------------------------
* 1. Environment Setup
* --------------------------------------------------------------------------
clear all
set more off, permanently
set linesize 255
version 17.0
macro drop _all

* --------------------------------------------------------------------------
* 2. Directory Globals 
* --------------------------------------------------------------------------
* NOTE TO USER: Set the root directory path here. 
* By default, it captures the current working directory if launched properly.
capture cd "C:/path/to/reproducibility_package" // <-- CHANGE THIS IF NEEDED
global root `c(pwd)'

global do      "$root/do"
global datain  "$root/data/raw"
global dataout "$root/data/clean"
global tables  "$root/output/tables"
global figures "$root/output/figures"

* Create directories if they do not exist (to prevent execution errors)
cap mkdir "$root/do"
cap mkdir "$root/data"
cap mkdir "$datain"
cap mkdir "$dataout"
cap mkdir "$root/output"
cap mkdir "$tables"
cap mkdir "$figures"

* --------------------------------------------------------------------------
* 3. Package Management
* --------------------------------------------------------------------------
* Automatically check for and install required SSC packages
local packages "estout reghdfe ftools"

foreach pkg in `packages' {
    capture which `pkg'
    if _rc {
        display as text "Installing `pkg'..."
        ssc install `pkg', replace
    }
    else {
        display as text "`pkg' already installed."
    }
}

* --------------------------------------------------------------------------
* 4. Execute Subordinate Scripts
* --------------------------------------------------------------------------
display as text "=== Starting Data Cleaning ==="
do "$do/01_clean.do"

display as text "=== Starting Analysis ==="
do "$do/02_analyze.do"

display as text "=== Master Script Execution Complete ==="