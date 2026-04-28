Mock WBG Reproducibility Package: Education Intervention Analysis

Overview

This repository contains the reproducibility package for the impact evaluation of a mock education intervention. The code strictly adheres to the World Bank's reproducible research standards, ensuring that all data cleaning, variable construction, and analyses are entirely replicable from raw (simulated) data to final outputs.

Directory Structure

To ensure reproducibility across different machines, this project uses relative file paths based on a dynamically set root directory.

reproducibility_package/
│
├── README.md                           <- This documentation file
├── master.do                           <- Main Stata execution script
│
├── do/                                 <- Stata scripts
│   ├── 01_clean.do                     <- Simulates/cleans data
│   └── 02_analyze.do                   <- Generates regressions and tables
│
├── r_scripts/                          <- R replication scripts
│   └── 01_clean_and_analyze.R          <- R translation of the Stata pipeline
│   └── renv.lock                       <- R environment lockfile (generated upon run)
│
├── data/                               <- Datasets
│   ├── raw/                            <- Raw data (Mock data generated in memory)
│   └── clean/                          <- Processed data ready for analysis
│
└── output/                             <- Generated outputs
    ├── tables/                         <- Regression tables (.csv, .tex, .html)
    └── figures/                        <- Generated figures (if applicable)



Software Requirements

Stata Environment

Version: Stata 17.0 (or higher).

Execution: Open master.do. Ensure your working directory is set to the root folder (reproducibility_package/), or change the global root path at the top of the script. Run master.do.

Dependencies: The master.do script will automatically check for and install necessary SSC packages, including estout, reghdfe, and ftools.

R Environment

Version: R 4.2.0 (or higher).

Environment Management: This project uses renv to guarantee package version reproducibility.

Execution: 1. Open r_scripts/01_clean_and_analyze.R.
2. The top of the script contains instructions to initialize the environment using renv::init() and restore the exact package versions required.
3. Run the script to execute the data generation, dplyr-based cleaning, and modelsummary-based outputs.