#############################################
# Helper Functions
#############################################

# Function to extract x-mers of a specified length from a sequence
extract_xmer <- function(seq, l) {
  seq_length <- nchar(seq)
  if (seq_length >= l) {
    # Generate substrings of length l
    start_positions <- 1:(seq_length - l + 1)
    substring(seq, start_positions, start_positions + l - 1)
  } else {
    # Return empty if the sequence is too short
    character(0)
  }
}

# Function to compute the Jaccard similarity matrix, either on CPU or GPU
compute_jaccard_similarity <- function(mat, method = "gpu") {
  if (method == "cpu") {
    # CPU-based computation using proxy::simil
    # mat must be a standard matrix
    sim <- proxy::simil(as.matrix(mat), method = "Jaccard")
    similarity_matrix <- as.matrix(sim)
  } else if (method == "gpu") {
    # GPU-based computation
    X_gpu <- gpuMatrix(mat, type = "float")
    intersection_gpu <- tcrossprod(X_gpu)
    intersection_mat <- as.matrix(intersection_gpu)
    
    row_sums <- rowSums(mat)
    n <- nrow(mat)
    similarity_matrix <- matrix(0, n, n)
    
    for (i in seq_len(n)) {
      union_counts <- row_sums[i] + row_sums - intersection_mat[i, ]
      valid <- union_counts > 0
      similarity_matrix[i, valid] <- intersection_mat[i, valid] / union_counts[valid]
      similarity_matrix[i, i] <- 1
    }
  } else {
    stop("Invalid method. Choose 'cpu' or 'gpu'.")
  }
  
  return(similarity_matrix)
}
