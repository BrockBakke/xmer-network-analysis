#############################################
# 1. Read and Filter Sequences
#############################################
read_and_filter_sequences <- function(fasta_path) {
  sequences <- readAAStringSet(fasta_path)
  headers <- names(sequences)
  seqs <- as.character(sequences)
  df <- data.frame(Header = headers, Sequence = seqs, stringsAsFactors = FALSE)
  
  # Define standard amino acids
  amino_acids <- c("A","C","D","E","F","G","H","I","K","L",
                   "M","N","P","Q","R","S","T","V","W","Y")
  
  pattern <- paste0("[^", paste(amino_acids, collapse = ""), "]")
  invalid_sequences <- grepl(pattern, df$Sequence)
  
  df_filtered <- df[!invalid_sequences, ]
  
  cat("Number of sequences before filtering:", nrow(df), "\n")
  cat("Number of sequences after filtering:", nrow(df_filtered), "\n")
  
  return(df_filtered)
}