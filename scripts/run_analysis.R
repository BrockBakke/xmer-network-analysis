#############################################
# Xmer Network Analysis Driver Script
# Author: Brock Kingstad-Bakke
# Date: `r format(Sys.Date(), '%Y-%m-%d')`
# Description: Runs the full pipeline for analyzing sequences
#############################################

# Load Libraries and Global Variables
cat("Initializing environment...\n")
source("scripts/00_setup_environment.R")
source("scripts/00_helpers.R")

# Validate input file
if (!file.exists(fasta_file)) {
  stop("Error: Input FASTA file not found at: ", fasta_file)
}
cat("FASTA file found at: ", fasta_file, "\n")

# Validate output directories
output_dirs <- c("output", "output/figures", "output/logs", "output/intermediate")
for (dir in output_dirs) {
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
    cat("Created missing directory: ", dir, "\n")
  }
}

# Log progress
log_file <- "output/logs/run_analysis.log"
sink(log_file, split = TRUE)  # Log output to file

cat("Starting pipeline...\n")
cat("Global constants:\n")
cat("  xmer_l = ", xmer_l, "\n")
cat("  unique_threshhold = ", unique_threshhold, "\n")

#############################################
# Step 1: Read and Filter Sequences
#############################################
cat("\nStep 1: Reading and filtering sequences...\n")
source("scripts/01_filter_sequences.R")
df_filtered <- read_and_filter_sequences(fasta_file)

#############################################
# Step 2: Extract and Filter x-mers
#############################################
cat("\nStep 2: Extracting and filtering x-mers...\n")
source("scripts/02_extract_ninemers.R")
ninemer_results <- extract_and_filter_ninemers(df_filtered)
sequence_presence_matrix <- ninemer_results$matrix
unique_ninemers <- ninemer_results$unique_ninemers

#############################################
# Step 3: Add External Sequences
#############################################
cat("\nStep 3: Adding external sequences...\n")
source("scripts/03_add_external_sequences.R")
sequence_presence_matrix_with_external <- add_external_sequences(
  sequence_presence_matrix, 
  unique_ninemers, 
  external_sequence_info
)

#############################################
# Step 4: Parse Metadata
#############################################
cat("\nStep 4: Parsing metadata...\n")
source("scripts/04_parse_metadata.R")
df_with_metadata <- parse_metadata(df_filtered)  # Default mode
# Uncomment the next line for manual mode
# df_with_metadata <- parse_metadata(df_filtered, manual = TRUE)

#############################################
# Step 5: Extract and Assign Year
#############################################
cat("\nStep 5: Extracting and assigning years...\n")
source("scripts/05_extract_years.R")
df_with_metadata <- assign_years(df_with_metadata, manual_years)

#############################################
# Step 6: Compute Similarity and Perform Clustering
#############################################
cat("\nStep 6: Computing similarity and performing clustering...\n")
source("scripts/06_hierarchical_clustering.R")
cluster_results <- compute_similarity_and_cluster(
  sequence_presence_matrix_with_external, 
  method = cpu_gpu_full
)
df_clusters <- cluster_results$df_clusters

#############################################
# Step 7: Select Representative Sequences
#############################################
cat("\nStep 7: Selecting representative sequences...\n")
source("scripts/07_select_representatives.R")
representative_sequences <- select_representatives(
  df_clusters, 
  external_sequences_to_prioritize
)

#############################################
# Step 8: Calculate Network (Representatives)
#############################################
cat("\nStep 8: Calculating network of representative sequences...\n")
source("scripts/08_compute_similarity.R")
g_representative_final <- calculate_network(
  sequence_presence_matrix_with_external, 
  representative_sequences, 
  method = cpu_gpu_reps
)

#############################################
# Step 9: Merge Host and Subtype
#############################################
cat("\nStep 9: Merging host and subtype information...\n")
source("scripts/09_merge_host_subtype.R")
g_representative_final <- merge_host_subtype(
  g_representative_final, 
  df_with_metadata, 
  representative_sequences
)

#############################################
# Step 10: Plot and Save
#############################################
cat("\nStep 10: Plotting and saving network graph...\n")
source("scripts/10_plot_network.R")
plot_and_save_graph(g_representative_final, "output/figures/network_graph1.svg")

cat("\nPipeline completed successfully.\n")
cat("Results:\n")
cat("  Network graph saved to: output/figures/network_graph1.svg\n")
cat("  Log saved to: ", log_file, "\n")

# Stop logging
sink()
#############################################
# Xmer Network Analysis Driver Script
# Author: Brock Kingstad-Bakke
# Date: `r format(Sys.Date(), '%Y-%m-%d')`
# Description: Runs the full pipeline for analyzing sequences
#############################################

# Load Libraries, Helper Functions, and Global Variables
cat("Initializing environment...\n")
source("scripts/00_setup_environment.R")
source("scripts/00_helpers.R")  # Load helper functions

# Validate input file
if (!file.exists(fasta_file)) {
  stop("Error: Input FASTA file not found at: ", fasta_file)
}
cat("FASTA file found at: ", fasta_file, "\n")

# Validate output directories
output_dirs <- c("output", "output/figures", "output/logs", "output/intermediate")
for (dir in output_dirs) {
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
    cat("Created missing directory: ", dir, "\n")
  }
}

# Log progress
log_file <- "output/logs/run_analysis.log"
sink(log_file, split = TRUE)  # Log output to file

cat("Starting pipeline...\n")
cat("Global constants:\n")
cat("  xmer_l = ", xmer_l, "\n")
cat("  unique_threshhold = ", unique_threshhold, "\n")

#############################################
# Step 1: Read and Filter Sequences
#############################################
cat("\nStep 1: Reading and filtering sequences...\n")
source("scripts/01_filter_sequences.R")
df_filtered <- read_and_filter_sequences(fasta_file)

#############################################
# Step 2: Extract and Filter x-mers
#############################################
cat("\nStep 2: Extracting and filtering x-mers...\n")
source("scripts/02_extract_ninemers.R")
ninemer_results <- extract_and_filter_ninemers(df_filtered)
sequence_presence_matrix <- ninemer_results$matrix
unique_ninemers <- ninemer_results$unique_ninemers

#############################################
# Step 3: Add External Sequences
#############################################
cat("\nStep 3: Adding external sequences...\n")
source("scripts/03_add_external_sequences.R")
sequence_presence_matrix_with_external <- add_external_sequences(
  sequence_presence_matrix, 
  unique_ninemers, 
  external_sequence_info
)

#############################################
# Step 4: Parse Metadata
#############################################
cat("\nStep 4: Parsing metadata...\n")
source("scripts/04_parse_metadata.R")
df_with_metadata <- parse_metadata(df_filtered)  # Default mode
# Uncomment the next line for manual mode
# df_with_metadata <- parse_metadata(df_filtered, manual = TRUE)

#############################################
# Step 5: Extract and Assign Year
#############################################
cat("\nStep 5: Extracting and assigning years...\n")
source("scripts/05_extract_years.R")
df_with_metadata <- assign_years(df_with_metadata, manual_years)

#############################################
# Step 6: Compute Similarity and Perform Clustering
#############################################
cat("\nStep 6: Computing similarity and performing clustering...\n")
source("scripts/06_hierarchical_clustering.R")
cluster_results <- compute_similarity_and_cluster(
  sequence_presence_matrix_with_external, 
  method = cpu_gpu_full
)
df_clusters <- cluster_results$df_clusters

#############################################
# Step 7: Select Representative Sequences
#############################################
cat("\nStep 7: Selecting representative sequences...\n")
source("scripts/07_select_representatives.R")
representative_sequences <- select_representatives(
  df_clusters, 
  external_sequences_to_prioritize
)

#############################################
# Step 8: Calculate Network (Representatives)
#############################################
cat("\nStep 8: Calculating network of representative sequences...\n")
source("scripts/08_compute_similarity.R")
g_representative_final <- calculate_network(
  sequence_presence_matrix_with_external, 
  representative_sequences, 
  method = cpu_gpu_reps
)

#############################################
# Step 9: Merge Host and Subtype
#############################################
cat("\nStep 9: Merging host and subtype information...\n")
source("scripts/09_merge_host_subtype.R")
g_representative_final <- merge_host_subtype(
  g_representative_final, 
  df_with_metadata, 
  representative_sequences
)

#############################################
# Step 10: Plot and Save
#############################################
cat("\nStep 10: Plotting and saving network graph...\n")
source("scripts/10_plot_network.R")
plot_and_save_graph(g_representative_final, "output/figures/network_graph1.svg")

cat("\nPipeline completed successfully.\n")
cat("Results:\n")
cat("  Network graph saved to: output/figures/network_graph1.svg\n")
cat("  Log saved to: ", log_file, "\n")

# Stop logging
sink()
