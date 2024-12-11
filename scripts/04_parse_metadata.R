parse_header <- function(header, 
                         manual = FALSE, 
                         field_sep = "\\|", 
                         is_kv = TRUE, 
                         kv_sep = ":",
                         manual_field_names = NULL) {
  
  # If not manual mode, use the existing logic
  if (!manual) {
    components <- unlist(strsplit(header, "\\|"))
    kv_pairs <- list()
    
    for (component in components) {
      kv <- sub("^([^:]+):", "\\1§", component)
      kv_split <- unlist(strsplit(kv, "§", fixed = TRUE))
      
      if (length(kv_split) == 2) {
        key <- trimws(kv_split[1])
        value <- trimws(kv_split[2])
        key <- gsub(" ", "_", key)
        kv_pairs[[key]] <- value
      } else {
        key <- gsub(" ", "_", trimws(component))
        kv_pairs[[key]] <- NA
      }
    }
    return(kv_pairs)
  } else {
    # Manual mode
    components <- unlist(strsplit(header, field_sep))
    # If we have key-value pairs
    if (is_kv) {
      kv_pairs <- list()
      # Parse each component as key-value pair if possible
      for (component in components) {
        # Replace first occurrence of kv_sep with a marker
        # to split later. This assumes format Key:Value
        pat <- paste0("^([^", kv_sep, "]+)", kv_sep)
        kv <- sub(pat, "\\1§", component)
        kv_split <- unlist(strsplit(kv, "§", fixed = TRUE))
        
        if (length(kv_split) == 2) {
          key <- trimws(kv_split[1])
          value <- trimws(kv_split[2])
          key <- gsub(" ", "_", key)
          kv_pairs[[key]] <- value
        } else {
          # If we can't find a kv pair, treat the entire component as a key with NA value
          key <- gsub(" ", "_", trimws(component))
          kv_pairs[[key]] <- NA
        }
      }
      return(kv_pairs)
    } else {
      # If not KV, we rely on manual_field_names
      # manual_field_names should be a vector of column names
      # that user defined. If there are more components than field names,
      # we ignore extras. If fewer components, the missing fields become NA.
      
      kv_pairs <- list()
      for (i in seq_along(manual_field_names)) {
        if (i <= length(components)) {
          val <- trimws(components[i])
          # If it's empty or looks like a header line, treat as value
          kv_pairs[[manual_field_names[i]]] <- val
        } else {
          # Not enough components for this field
          kv_pairs[[manual_field_names[i]]] <- NA
        }
      }
      return(kv_pairs)
    }
  }
}


parse_metadata <- function(df_filtered, manual = FALSE) {
  # Default behavior:
  if (!manual) {
    metadata_list <- lapply(df_filtered$Header, parse_header, manual = FALSE)
    all_keys <- unique(unlist(lapply(metadata_list, names)))
    
    metadata_list_filled <- lapply(metadata_list, function(kv_pairs) {
      filled <- rep(NA_real_, length(all_keys))
      names(filled) <- all_keys
      filled[names(kv_pairs)] <- kv_pairs
      filled
    })
    
    metadata_df <- do.call(rbind, lapply(metadata_list_filled, as.data.frame))
    metadata_df <- type.convert(metadata_df, as.is = TRUE)
    rownames(metadata_df) <- NULL
    
    df_with_metadata <- cbind(df_filtered, metadata_df)
    return(df_with_metadata)
  } else {
    # Manual mode:
    cat("Manual mode enabled for metadata parsing.\n")
    # Prompt user for the field separator
    field_sep_input <- readline("Enter the metadata field separator (e.g., '|'): ")
    if (nchar(field_sep_input) == 0) {
      field_sep_input <- "|"
    }
    # Escape special characters for strsplit if necessary
    field_sep_escaped <- gsub("\\|", "\\\\|", field_sep_input)
    
    # Prompt for key-value pairs
    kv_input <- readline("Do the metadata fields contain key-value pairs? (Y/N): ")
    is_kv <- toupper(trimws(kv_input)) == "Y"
    
    kv_sep <- ":"
    manual_field_names <- NULL
    
    if (is_kv) {
      # Ask for kv separator
      kv_sep_input <- readline("Enter the key-value separator (e.g., ':'): ")
      if (nchar(kv_sep_input) == 0) {
        kv_sep_input <- ":"
      }
      kv_sep <- kv_sep_input
      cat("Will parse metadata as key-value pairs using '", kv_sep, "'.\n", sep="")
    } else {
      # If no kv, ask user to define column labels for each field:
      # Take the first header as an example
      example_header <- df_filtered$Header[1]
      example_components <- unlist(strsplit(example_header, field_sep_escaped))
      
      cat("Example header:\n", example_header, "\n", sep="")
      cat("This header was split into the following fields:\n")
      for (i in seq_along(example_components)) {
        cat(i, ": ", example_components[i], "\n", sep="")
      }
      
      cat("Since no key-value pairs, we will assign column names manually.\n")
      manual_field_names <- character(length(example_components))
      for (i in seq_along(example_components)) {
        col_name <- readline(paste0("Enter a column name for field ", i, " (", example_components[i], "): "))
        if (nchar(col_name) == 0) {
          col_name <- paste0("Field_", i)
        }
        col_name <- gsub(" ", "_", col_name)
        manual_field_names[i] <- col_name
      }
      cat("Column names assigned.\n")
    }
    
    # Now parse all headers with the chosen method
    metadata_list <- lapply(
      df_filtered$Header,
      parse_header,
      manual = TRUE,
      field_sep = field_sep_escaped,
      is_kv = is_kv,
      kv_sep = kv_sep,
      manual_field_names = manual_field_names
    )
    
    # Collect all keys if KV mode
    if (is_kv) {
      all_keys <- unique(unlist(lapply(metadata_list, names)))
      metadata_list_filled <- lapply(metadata_list, function(kv_pairs) {
        filled <- rep(NA_real_, length(all_keys))
        names(filled) <- all_keys
        filled[names(kv_pairs)] <- kv_pairs
        filled
      })
    } else {
      # If not kv mode, we already have a fixed set of columns in manual_field_names
      all_keys <- manual_field_names
      # metadata_list already aligned fields in order of manual_field_names
      metadata_list_filled <- lapply(metadata_list, function(kv_pairs) {
        # Ensure all fields present
        filled <- rep(NA_real_, length(all_keys))
        names(filled) <- all_keys
        filled[names(kv_pairs)] <- kv_pairs
        filled
      })
    }
    
    metadata_df <- do.call(rbind, lapply(metadata_list_filled, as.data.frame))
    metadata_df <- type.convert(metadata_df, as.is = TRUE)
    rownames(metadata_df) <- NULL
    
    df_with_metadata <- cbind(df_filtered, metadata_df)
    return(df_with_metadata)
  }
}