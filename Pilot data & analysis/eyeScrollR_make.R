eyeScrollR_make <- function()
{
  ET_files <- list.files(path="./ET_raw/", pattern="*.csv", full.names = TRUE)
  ET_files_names <- list.files(path="./ET_raw/", pattern="*.csv")
  datasets <- lapply(ET_files, read_csv, comment="#", show_col_types = FALSE)
  datasets <- lapply(datasets,
                     function(x) {names(x) <- make.names(names(x))
                     return(x)
                     }
  )
  
  img_height <- 39238
  img_width <- 1920
  
  timestamp_start <- list()
  timestamp_stop <- list()
  timestamp_start[["7e1de5a2-5fd4-4b67-afa3-31ea126ef0e1.csv"]] <- 46269
  timestamp_stop[["7e1de5a2-5fd4-4b67-afa3-31ea126ef0e1.csv"]] <- 584005
  timestamp_start[["18ba885d-4c80-4d33-9c74-f78967c0cabb.csv"]] <- 66813
  timestamp_stop[["18ba885d-4c80-4d33-9c74-f78967c0cabb.csv"]] <- 918069
  timestamp_start[["190b9952-c489-4b96-88ab-f5b01d23b471.csv"]] <- 82508
  timestamp_stop[["190b9952-c489-4b96-88ab-f5b01d23b471.csv"]] <- 975180
  timestamp_start[["73377e3b-407d-49d5-b1fd-9d72dc51a48a.csv"]] <- 71001
  timestamp_stop[["73377e3b-407d-49d5-b1fd-9d72dc51a48a.csv"]] <- 1975744
  timestamp_start[["84501052-19a4-46b7-8138-68cd819d7bec.csv"]] <- 61170
  timestamp_stop[["84501052-19a4-46b7-8138-68cd819d7bec.csv"]] <- 1389522
  timestamp_start[["bfc5a358-c718-415d-b491-f76fc617eecf.csv"]] <- 55995
  timestamp_stop[["bfc5a358-c718-415d-b491-f76fc617eecf.csv"]] <- 1007018
  timestamp_start[["f137fa43-fa1a-4608-b5d5-9729119d35dc.csv"]] <- 120442
  timestamp_stop[["f137fa43-fa1a-4608-b5d5-9729119d35dc.csv"]] <- 875242
  timestamp_start[["fc40b447-f576-4490-9de9-5c9979689b0c.csv"]] <- 120442
  timestamp_stop[["fc40b447-f576-4490-9de9-5c9979689b0c.csv"]] <- 1307169
  
  
  calib_img <- readPNG("calibration_image.png")
  calibration <- scroll_calibration_auto(calib_img, 125)
  
  for (i in seq_len(length(datasets)))
  {
    startmedia <- (datasets[[i]] %>% filter(SlideEvent=="StartMedia"))[["Timestamp"]]
    timestamp_start[[ET_files_names[[i]]]] <- timestamp_start[[ET_files_names[[i]]]] - startmedia
    timestamp_stop[[ET_files_names[[i]]]] <- timestamp_stop[[ET_files_names[[i]]]] - startmedia
    write.csv(eye_scroll_correct(eyes_data = datasets[[i]], timestamp_start = timestamp_start[[ET_files_names[[i]]]],
                                 time_shift=startmedia,
                                 timestamp_stop = timestamp_stop[[ET_files_names[[i]]]], image_width = img_width,
                                 image_height = img_height, calibration = calibration) %>% select(Timestamp = Timestamp.Shifted, Fixation.Start, Fixation.End, Fixation.Duration, Corrected.Fixation.X, Corrected.Fixation.Y) %>% mutate(Fixation.Start = Fixation.Start - startmedia, Fixation.End = Fixation.End - startmedia),
              file = paste0("./ET/", ET_files_names[i]), row.names = FALSE)
  }
}
