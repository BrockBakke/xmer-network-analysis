#############################################
# 5. Extract and Assign Year
#############################################
extract_year <- function(strain_name) {
  parts <- unlist(strsplit(strain_name, "/"))
  last_part <- tail(parts, 1)
  
  year_str <- gsub("[^0-9]", "", last_part)
  if (nchar(year_str) == 0) return(NA_integer_)
  
  year_num <- as.integer(year_str)
  if (is.na(year_num)) return(NA_integer_)
  
  if (nchar(year_str) == 2) {
    if (year_num <= 24) {
      year_num <- 2000 + year_num
    } else if (year_num <= 99) {
      year_num <- 1900 + year_num
    } else {
      return(NA_integer_)
    }
  } else if (nchar(year_str) == 4) {
    # Use as is
  } else {
    return(NA_integer_)
  }
  
  return(year_num)
}

assign_years <- function(df_with_metadata, manual_years) {
  df_with_metadata$Year <- sapply(df_with_metadata$Strain_Name, extract_year)
  
  invalid_year_entries <- df_with_metadata[
    is.na(df_with_metadata$Year) | nchar(as.character(df_with_metadata$Year)) != 4,
  ]
  
  num_invalid_years <- nrow(invalid_year_entries)
  cat("Number of entries with invalid years:", num_invalid_years, "\n")
  print(invalid_year_entries[, c("Strain_Name", "Year")])
  
  for (i in seq_len(nrow(manual_years))) {
    strain_name <- manual_years$Strain_Name[i]
    year_value <- manual_years$Year[i]
    matching_rows <- which(df_with_metadata$Strain_Name == strain_name)
    if (length(matching_rows) > 0) {
      df_with_metadata$Year[matching_rows] <- year_value
      cat("Updated Year for strain:", strain_name, "to", year_value, "\n")
    } else {
      cat("No exact match found for strain:", strain_name, "\n")
    }
  }
  
  return(df_with_metadata)
}