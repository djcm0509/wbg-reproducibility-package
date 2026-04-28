# ==============================================================================
# PROJECT: Mock WBG Reproducibility Package
# SCRIPT: 01_clean_and_analyze.R
# PURPOSE: R Translation of the Stata cleaning and analysis pipeline.
#          Uses dplyr for data wrangling and modelsummary for output.
# ==============================================================================

# ------------------------------------------------------------------------------
# 0. Environment Setup & Reproducibility (renv)
# ------------------------------------------------------------------------------
# Uncomment the following lines to initialize and capture the environment:
# if (!require("renv")) install.packages("renv")
# renv::init()
# renv::snapshot() # Run this after installing the packages below to lock versions

# Install required packages if missing
required_packages <- c("dplyr", "tidyr", "fixest", "modelsummary", "readr")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)

library(dplyr)
library(fixest)
library(modelsummary)
library(readr)

# Define relative paths
dir.create("data/raw", showWarnings = FALSE, recursive = TRUE)
dir.create("data/clean", showWarnings = FALSE, recursive = TRUE)
dir.create("output/tables", showWarnings = FALSE, recursive = TRUE)

# ------------------------------------------------------------------------------
# 1. Simulate Raw Data (Equivalent to Stata 01_clean.do)
# ------------------------------------------------------------------------------
set.seed(987654321)

n_obs <- 2000
raw_data <- tibble(
  student_id = 1:n_obs,
  school_id = sample(1:100, n_obs, replace = TRUE),
  female = as.numeric(runif(n_obs) > 0.5),
  test_score_baseline = rnorm(n_obs, mean = 50, sd = 10)
) %>%
  group_by(school_id) %>%
  mutate(school_rand = runif(1)) %>%
  ungroup() %>%
  mutate(
    treatment = as.numeric(school_rand > 0.5),
    error_term = rnorm(n_obs, mean = 0, sd = 8),
    test_score_endline = 5 + 0.8 * test_score_baseline + 5 * treatment + 2 * female + error_term
  ) %>%
  select(-school_rand, -error_term)

write_csv(raw_data, "data/raw/raw_education_data.csv")

# ------------------------------------------------------------------------------
# 2. Data Cleaning & Variable Construction
# ------------------------------------------------------------------------------
clean_data <- raw_data %>%
  mutate(
    z_score_baseline = (test_score_baseline - mean(test_score_baseline)) / sd(test_score_baseline),
    z_score_endline = (test_score_endline - mean(test_score_endline)) / sd(test_score_endline)
  )

write_csv(clean_data, "data/clean/clean_education_data.csv")

# ------------------------------------------------------------------------------
# 3. Regression Analysis (Equivalent to Stata 02_analyze.do)
# ------------------------------------------------------------------------------
# Using fixest::feols for robust clustering standard errors (reghdfe equivalent)

# Model 1: Simple OLS
m1 <- feols(z_score_endline ~ treatment, 
            cluster = ~school_id, data = clean_data)

# Model 2: OLS with controls
m2 <- feols(z_score_endline ~ treatment + z_score_baseline + female, 
            cluster = ~school_id, data = clean_data)

# Model 3: "reghdfe" exact equivalent showcase (Standard OLS clustered, no FEs applied)
m3 <- feols(z_score_endline ~ treatment + z_score_baseline + female, 
            cluster = ~school_id, data = clean_data)

# ------------------------------------------------------------------------------
# 4. Export Output using modelsummary
# ------------------------------------------------------------------------------
models <- list(
  "Model 1" = m1,
  "Model 2" = m2,
  "Model 3" = m3
)

# Create a naming dictionary for clean table labels
coef_map <- c(
  "treatment" = "Treatment Group",
  "z_score_baseline" = "Baseline Z-Score",
  "female" = "Female (1=Yes)",
  "(Intercept)" = "Constant"
)

modelsummary(
  models,
  output = "output/tables/r_regression_results.html",
  coef_map = coef_map,
  gof_map = c("nobs", "r.squared"),
  stars = c('*' = .1, '**' = .05, '***' = .01),
  title = "Impact of Tutoring Intervention on Student Z-Scores (R Translation)",
  notes = list("Standard errors clustered at the school level in parentheses.")
)

cat("=== R Pipeline Execution Complete. Outputs saved to output/tables/ ===\n")