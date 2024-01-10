library(png)
library(tidyverse)
library(eyeScrollR)

# Exclude bad or incomplete data sets (poor calibration, eye tracker files
# without an associated response file and conversely, no responses in the
# response file, low frequency of data
source("preprocessing.R")
exclude()

# Take files from /ET_raw/ (raw eye tracker files from iMotions), and output
# eyeScrollR-corrected files into /ET/
source("eyeScrollR_make.R")
eyeScrollR_make()

# Take files from /ET/ (eyeScrollR-corrected files), and output files in
# /ET_fixations_only_fixed (which is a modified version of files from ET, which
# only include fixations datapoints, and corrected for duration and start/end
# for fixations during scrolling). This is for use by eyeScrollR_checker(), to
# create a random selection of fixations (for sanity checks)

# Also outputs files in /final/, which are the total sum of fixation times for
# each statement
source("dataset_merge.R")
datasets_merge()

# Creates a list (in /ET_check/) of files with 50 random fixations per
# participant, along with their median timestamp (converted in m-s-ms), to be
# used by the draw_check() Python script (used to draw crosses on the png files
# to locate fixations along with their timestamp)
source("eyeScrollR_checker.R")
eyeScrollR_checker()