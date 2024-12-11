select_representatives <- function(df_clusters, external_sequences) {
  representative_sequences <- df_clusters %>%
    group_by(Cluster) %>%
    arrange(desc(Sequence %in% external_sequences)) %>%
    dplyr::slice(1) %>%
    ungroup() %>%
    select(Sequence)
  
  # Check missing external sequences
  missing_external_sequences <- setdiff(external_sequences, representative_sequences$Sequence)
  if (length(missing_external_sequences) > 0) {
    additional_reps <- df_clusters %>% filter(Sequence %in% missing_external_sequences) %>% select(Sequence)
    representative_sequences <- bind_rows(representative_sequences, additional_reps)
    cat("Added the following external sequences as representatives:", paste(missing_external_sequences, collapse = ", "), "\n")
  }
  
  representative_sequences <- distinct(representative_sequences)
  return(representative_sequences)
}