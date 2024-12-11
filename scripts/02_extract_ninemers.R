#############################################
# Functions for Extracting and Filtering x-mers
#############################################

extract_and_filter_ninemers <- function(df_filtered) {
  ninemers_list <- lapply(df_filtered$Sequence, function(seq) {
    unique(extract_xmer(seq, xmer_l))
  })
  
  ninemer_counts <- table(unlist(ninemers_list))
  unique_ninemers <- names(ninemer_counts[ninemer_counts >= unique_threshhold])
  
  num_unique_ninemers <- length(unique_ninemers)
  cat("Total unique ", xmer_l, "-mers found that appear in at least ", unique_threshhold, " sequences:", num_unique_ninemers, "\n")
  
  sequence_presence_matrix <- matrix(
    0L,
    nrow = nrow(df_filtered),
    ncol = num_unique_ninemers,
    dimnames = list(df_filtered$Header, unique_ninemers)
  )
  
  all_ninemers <- unlist(ninemers_list)
  sequence_idx <- rep(seq_along(ninemers_list), lengths(ninemers_list))
  indices <- match(all_ninemers, unique_ninemers, nomatch = 0)
  valid <- indices > 0
  sequence_presence_matrix[cbind(sequence_idx[valid], indices[valid])] <- 1L
  
  return(list(matrix = sequence_presence_matrix, unique_ninemers = unique_ninemers))
}
