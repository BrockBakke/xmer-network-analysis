calculate_network <- function(sequence_presence_matrix_with_external, representative_sequences, method = "cpu") {
  sequence_presence_representative_final <- sequence_presence_matrix_with_external[representative_sequences$Sequence, ]
  
  # Compute similarity for representative sequences
  similarity_representative_final <- compute_jaccard_similarity(sequence_presence_representative_final, method = method)
  
  network_similarity_threshold <- 0.4
  adjacency_matrix_final <- similarity_representative_final >= network_similarity_threshold
  diag(adjacency_matrix_final) <- FALSE
  
  edge_list_final <- which(adjacency_matrix_final, arr.ind = TRUE)
  edges_df_final <- data.frame(
    from = rownames(adjacency_matrix_final)[edge_list_final[, 1]],
    to = rownames(adjacency_matrix_final)[edge_list_final[, 2]],
    stringsAsFactors = FALSE
  )
  
  # Remove duplicate edges
  edges_df_final <- edges_df_final[edge_list_final[, 1] < edge_list_final[, 2], ]
  
  g_representative_final <- graph_from_data_frame(d = edges_df_final, vertices = representative_sequences$Sequence, directed = FALSE)
  
  average_similarity <- sapply(representative_sequences$Sequence, function(seq) {
    sims <- similarity_representative_final[seq, ]
    sims <- sims[names(sims) != seq]
    mean(sims, na.rm = TRUE)
  })
  
  V(g_representative_final)$Avg_Similarity <- average_similarity[V(g_representative_final)$name]
  
  return(g_representative_final)
}