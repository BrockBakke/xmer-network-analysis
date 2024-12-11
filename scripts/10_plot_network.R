#############################################
# 10. Plot the Network Graph and Save as SVG
#############################################
plot_and_save_graph <- function(g, output_file = "network_graph1.svg") {
  shape_mapping <- c("Mammalian" = 16, "Avian" = 15, "Mosaic" = 17, "Reference" = 18)
  
  p <- ggraph(g, layout = "fr") + 
    geom_edge_link(alpha = 0.3, color = "grey") +
    geom_node_point(aes(color = Avg_Similarity, shape = Host), size = 4) +
    
    # Label external sequences ("Reference") and "Mosaic NP"
    geom_node_text(
      aes(label = ifelse(Host == "Reference" | name == "Mosaic NP", name, "")),
      repel = TRUE, size = 3, vjust = 1.5
    ) +
    
    # Label non-external sequences with their Subtype
    geom_node_text(
      aes(label = ifelse(Host != "Reference" & name != "Mosaic NP", Subtype, "")),
      repel = TRUE, size = 2, vjust = -1.5, color = "black"
    ) +
    
    scale_shape_manual(values = shape_mapping) +
    scale_color_viridis_c(option = "plasma") + 
    theme_minimal() +
    theme(
      panel.grid = element_blank(),
      axis.title = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank()
    ) +
    labs(
      title = "Simplified Network Graph of Representative Influenza Sequences",
      color = "Avg Shared 9-mer Overlap",
      shape = "Category"
    )
  
  print(p)
  ggsave(filename = output_file, plot = p, device = "svg", width = 12, height = 8)
}