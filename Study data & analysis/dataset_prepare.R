library(png)
library(tidyverse)
library(eyeScrollR)
### NB: eyeScrollR is not on CRAN. To install eyeScrollR, you can use Devtools
# and the following command:
# devtools::install_github("larigaldie-n/eyeScrollR")
# More info in eyeScrollR's paper:
# https://doi.org/10.3758/s13428-024-02343-1


# Excludes bad or incomplete data sets (poor calibration, eye tracker files
# without an associated response file and conversely, no responses in the
# response file, low frequency of data
source("preprocessing.R")
exclude()

# Takes files from /raw_data/ET_raw (raw eye tracker files from iMotions), and
# outputs eyeScrollR-corrected files into /intermediate_data/ET/
source("eyeScrollR_make.R")
eyeScrollR_make()

# Takes files from /intermediate_data/ET/ (eyeScrollR-corrected files), and
# outputs files in /intermediate_data/ET_fixations_only_fixed (a modified
# version of files from /intermediate_data/ET/, which only include fixations
# datapoints, and corrected for duration and start/end for fixations during
# scrolling). This is for use by eyeScrollR_checker(), to create a random
# selection of fixations (for sanity checks only)

# Also outputs files in /final_data/, which are complete data files with all
# statements, questionnaire ratings and total aggregated fixation times
source("dataset_merge.R")
datasets_merge()

# Creates a list (in /ET_check/) of files with 50 random fixations per
# participant, along with their median timestamp (converted in m-s-ms), to be
# used by the draw_check() Python script (used to draw crosses on the png files
# to locate fixations along with their timestamp ; sanity checks only)
source("eyeScrollR_checker.R")
eyeScrollR_checker()