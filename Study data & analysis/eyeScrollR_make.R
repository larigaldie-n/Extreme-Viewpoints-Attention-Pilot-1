eyeScrollR_make <- function()
{
  if (!dir.exists(file.path("intermediate_data", "ET"))) {dir.create(file.path("intermediate_data", "ET"), recursive = TRUE)}
  ET_files <- list.files(path=file.path("raw_data", "ET_raw"), pattern="*.csv", full.names = TRUE)
  ET_files_names <- basename(ET_files)
  datasets <- lapply(ET_files, read_csv, comment="#", show_col_types = FALSE)
  datasets <- lapply(datasets,
                     function(x) {names(x) <- make.names(names(x))
                     return(x)
                     }
  )
  
  img_height <- 39238
  img_width <- 1920
  
  source("eyeScrollR_make_timestamps.R")
  
  calib_img <- readPNG("calibration_image.png")
  calibration <- scroll_calibration_auto(calib_img, 125)
  
  for (i in seq_len(length(datasets)))
  {
    startmedia <- (datasets[[i]] %>% filter(SlideEvent=="StartMedia"))[["Timestamp"]]
    write.csv(eye_scroll_correct(eyes_data = datasets[[i]], timestamp_start = timestamp_start[[ET_files_names[[i]]]],
                                 time_shift=startmedia,
                                 timestamp_stop = timestamp_stop[[ET_files_names[[i]]]], image_width = img_width,
                                 image_height = img_height, calibration = calibration,
                                 scroll_lag = get_scroll_lag(refresh_rate = 60, n_frame = 2)) %>% select(Timestamp = Timestamp.Shifted, Fixation.Start, Fixation.End, Fixation.Duration, Corrected.Fixation.X, Corrected.Fixation.Y) %>% mutate(Fixation.Start = Fixation.Start - startmedia, Fixation.End = Fixation.End - startmedia),
              file = file.path("intermediate_data", "ET", ET_files_names[i]), row.names = FALSE)
  }
}
