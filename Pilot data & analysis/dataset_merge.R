correct_fixation_times <- function(dataset)
{
  dataset <- dataset %>% mutate(idx = seq_len(nrow(dataset)))
  d <- dataset %>% group_by(Fixation.Start, Fixation.End, Fixation.Duration, Corrected.Fixation.X, Corrected.Fixation.Y) %>% summarise(n=n(), f_ts = first(Timestamp), l_ts = last(Timestamp), f_idx = first(idx), l_idx = last(idx), .groups="keep") %>% group_by(Fixation.Start, Fixation.End, Fixation.Duration) %>% reframe(n=n(), f_ts = f_ts, l_ts = l_ts, f_idx = f_idx, l_idx = l_idx, Corrected.Fixation.Y = Corrected.Fixation.Y) %>% filter(n>1)
  
  if(nrow(d) > 0)
  {
    i <- 1
    while (i < nrow(d))
    {
      for (j in seq(from=0, to=d[[i, "n"]]-1))
      {
        f_idx <- d[[i+j, "f_idx"]]
        l_idx <- d[[i+j, "l_idx"]]
        if(j==0)
        {
          ### In order to keep NA value: dataset[f_idx:l_idx, "Fixation.End"] - dataset[f_idx:l_idx, "Fixation.End"] + (same in the other conditions)
          dataset[f_idx:l_idx, "Fixation.End"] <- dataset[f_idx:l_idx, "Fixation.End"] - dataset[f_idx:l_idx, "Fixation.End"] + (d[[i+j, "l_ts"]] + d[[i+j+1, "f_ts"]])/2
        }
        else if (j==d[[i, "n"]]-1)
        {
          dataset[f_idx:l_idx, "Fixation.Start"] <- dataset[f_idx:l_idx, "Fixation.Start"] - dataset[f_idx:l_idx, "Fixation.Start"] + dataset[[d[[i+j-1, "f_idx"]], "Fixation.End"]]
        }
        else
        {
          dataset[f_idx:l_idx, "Fixation.Start"] <- dataset[f_idx:l_idx, "Fixation.Start"] - dataset[f_idx:l_idx, "Fixation.Start"] + dataset[[d[[i+j-1, "f_idx"]], "Fixation.End"]]
          dataset[f_idx:l_idx, "Fixation.End"] <- dataset[f_idx:l_idx, "Fixation.End"] - dataset[f_idx:l_idx, "Fixation.End"] + (d[[i+j, "l_ts"]] + d[[i+j+1, "f_ts"]])/2
        }
        dataset[f_idx:l_idx, "Fixation.Duration"] <- dataset[f_idx:l_idx, "Fixation.Duration"] - dataset[f_idx:l_idx, "Fixation.Duration"] + dataset[[f_idx, "Fixation.End"]] - dataset[[f_idx, "Fixation.Start"]]
      }
      i <- i + d[[i, "n"]]
    }
    return(dataset)
  }
}

extract_fixation_times <- function(dataset, size, start_coordinate, shift_coordinate, x_left, x_right, y_size)
{
  Fixation_time <- c()
  
  pb <- txtProgressBar(min = -1, max = size-1, style = 3, width = 50, char = "=")
  
  for (j in (seq_len(size) - 1))
  {
    d_match <- dataset %>% select(Fixation.Start, Fixation.End, Corrected.Fixation.X, Corrected.Fixation.Y, Fixation.Duration) %>% unique() %>% filter(Corrected.Fixation.X >= x_left & Corrected.Fixation.X <= x_right & Corrected.Fixation.Y >= floor(start_coordinate + shift_coordinate * j) & Corrected.Fixation.Y <= floor(start_coordinate + shift_coordinate * j) + y_size & !is.na(Corrected.Fixation.Y))

    if(nrow(d_match) > 0)
    {
      Fixation_time[j+1] <- sum(d_match$Fixation.Duration)
    }
    else
    {
      Fixation_time <- c(Fixation_time, 0)
    }
    setTxtProgressBar(pb, j)
  }
  return(Fixation_time)
}

datasets_merge <- function()
{
  start_coordinate <- 1
  shift_coordinate <- 389.5
  x_left <- 248
  x_right <- 1673
  y_shift <- 325
  
  ET_files         <- list.files(path="./ET/", pattern="*.csv", full.names = TRUE)
  d_eye_tracking   <- lapply(ET_files, read_csv, comment="#", show_col_types = FALSE)
  d_eye_tracking   <- lapply(d_eye_tracking,
                             function(x) { correct_fixation_times(x)
                             })
  ET_files_names <- list.files(path="./ET/", pattern="*.csv")
  responses_files  <- list.files(path="./responses/", pattern="*.csv", full.names = TRUE)
  d_responses      <- lapply(responses_files, read_csv, comment="#", show_col_types = FALSE)
  
  lapply(d_eye_tracking,
         function(x) { correct_fixation_times(x)
         })
  
  for (i in seq_len(length(d_eye_tracking)))
  {
    cat(paste("File:", ET_files_names[[i]]))
    d_responses[[i]]$Fixation.Time <- extract_fixation_times(d_eye_tracking[[i]], max(d_responses[[i]]$Order), start_coordinate, shift_coordinate, x_left, x_right, y_shift)
    write.csv(d_eye_tracking[[i]], file = paste0("./ET_fixations_only_fixed/", ET_files_names[i]), row.names = FALSE)
    write.csv(d_responses[[i]], file = paste0("./final/", ET_files_names[i]), row.names = FALSE)
  }
  cat("\nDone!")
}

