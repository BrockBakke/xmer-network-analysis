#############################################
# 3. Add External Sequences
#############################################
add_external_sequences <- function(sequence_presence_matrix, unique_ninemers, external_info) {
  sequence_presence_matrix_with_external <- sequence_presence_matrix
  num_external <- nrow(external_info)
  
  external_presence_matrix <- matrix(
    0L,
    nrow = num_external,
    ncol = length(unique_ninemers),
    dimnames = list(external_info$Header, unique_ninemers)
  )
  
  # Pre-hash for faster lookups
  fmatch(unique_ninemers, unique_ninemers)
  
  for (i in seq_len(num_external)) {
    external_seq <- external_info$Sequence[i]
    external_ninemers <- unique(extract_xmer(external_seq, xmer_l))
    nm_indices <- fmatch(external_ninemers, unique_ninemers, nomatch = 0L)
    nm_indices <- nm_indices[nm_indices > 0]
    if (length(nm_indices) > 0) {
      external_presence_matrix[i, nm_indices] <- 1L
    }
  }
  
  sequence_presence_matrix_with_external <- rbind(
    sequence_presence_matrix_with_external,
    external_presence_matrix
  )
  
  cat("Number of sequences after adding external sequences:", nrow(sequence_presence_matrix_with_external), "\n")
  
  return(sequence_presence_matrix_with_external)
}
