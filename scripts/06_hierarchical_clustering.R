# Modified to accept a method parameter for CPU/GPU similarity calculation
compute_similarity_and_cluster <- function(sequence_presence_matrix_with_external, method = "gpu") {
  sequence_presence_matrix_filtered <- sequence_presence_matrix_with_external[rowSums(sequence_presence_matrix_with_external) > 0, ]
  seq_names <- rownames(sequence_presence_matrix_filtered)
  
  # Compute similarity (CPU or GPU) using the unified function
  similarity_matrix <- compute_jaccard_similarity(sequence_presence_matrix_filtered, method = method)
  
  hc <- hclust(as.dist(1 - similarity_matrix), method = "average")
  similarity_threshold <- 0.7
  clusters <- cutree(hc, h = 1 - similarity_threshold)
  
  df_clusters <- data.frame(Sequence = seq_names, Cluster = clusters, stringsAsFactors = FALSE)
  
  return(list(df_clusters = df_clusters, similarity_matrix = similarity_matrix))
}