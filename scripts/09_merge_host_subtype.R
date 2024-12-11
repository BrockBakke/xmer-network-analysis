#############################################
# 9. Merge Host and Subtype Information
#############################################
merge_host_subtype <- function(g, df_with_metadata, representative_sequences) {
  representative_sequences <- representative_sequences %>%
    left_join(df_with_metadata %>% select(Header, Host, Subtype),
              by = c("Sequence" = "Header"))
  
  if(!"Mosaic NP" %in% representative_sequences$Sequence) {
    representative_sequences <- rbind(representative_sequences,
      data.frame(Sequence = "Mosaic NP", Host = "Mosaic", Subtype = "Synthetic", stringsAsFactors = FALSE))
  }
  
  representative_sequences$Sequence <- as.character(representative_sequences$Sequence)
  V(g)$name <- as.character(V(g)$name)
  
  if(any(duplicated(representative_sequences$Sequence))) {
    stop("Duplicate sequence names found in representative_sequences$Sequence. Please ensure all sequences are unique.")
  }
  
  host_lookup <- setNames(representative_sequences$Host, representative_sequences$Sequence)
  subtype_lookup <- setNames(representative_sequences$Subtype, representative_sequences$Sequence)
  
  matched_hosts <- host_lookup[V(g)$name]
  if(any(is.na(matched_hosts))) {
    warning("Some sequences did not match and will be assigned 'Avian' as Host.")
    matched_hosts[is.na(matched_hosts)] <- "Avian"
  }
  
  # Special handling for "Mosaic NP"
  matched_hosts <- ifelse(V(g)$name == "Mosaic NP", "Mosaic",
                          ifelse(matched_hosts == "Human", "Mammalian",
                                 ifelse(matched_hosts == "Avian", "Avian", "Avian")))
  
  V(g)$Host <- matched_hosts
  
  matched_subtypes <- subtype_lookup[V(g)$name]
  if(any(is.na(matched_subtypes))) {
    warning("Some sequences did not match and will be assigned 'Unknown' as Subtype.")
    matched_subtypes[is.na(matched_subtypes)] <- "Unknown"
  }
  
  matched_subtypes <- ifelse(V(g)$name == "Mosaic NP", "Synthetic", matched_subtypes)
  V(g)$Subtype <- matched_subtypes
  
  # Assign "Reference" to external reference sequences (excluding "Mosaic NP")
  V(g)$Host <- ifelse(
    V(g)$name %in% external_sequences_to_prioritize & V(g)$name != "Mosaic NP",
    "Reference",
    V(g)$Host
  )
  
  V(g)$Host <- ifelse(V(g)$name == "Mosaic NP", "Mosaic", V(g)$Host)
  
  # Assign subtype for Reference sequences
  V(g)$Subtype <- ifelse(
    V(g)$Host == "Reference",
    V(g)$name,
    V(g)$Subtype
  )
  
  V(g)$Subtype <- ifelse(V(g)$name == "Mosaic NP", "Synthetic", V(g)$Subtype)
  
  return(g)
}