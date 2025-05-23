# Xmer Network Analysis

Welcome to the **Xmer Network Analysis** pipeline! This repository provides tools and scripts for analyzing sequences, extracting x-mers, clustering, and visualizing results as a network graph.

---

## Getting Started

### Prerequisites

1. **Clone the repository**:
   ```bash
   git clone https://github.com/BrockBakke/xmer-network-analysis.git
   cd xmer-network-analysis
   ```

2. **Restore the R environment**:
   Install R packages using `renv`:
   ```r
   renv::restore()
   ```

3. **Ensure required system dependencies are installed**:
   - GPU drivers are needed for `gpuR` (if GPU computation is enabled).
   - Other dependencies are specified in `scripts/00_setup_environment.R`.

---

### Modifying Parameters

Adjust key parameters in `scripts/00_setup_environment.R` as needed:
- `fasta_file`: Path to your input FASTA file.
- `xmer_l`: Length of the x-mers (default: 9).
- `unique_threshhold`: Minimum number of sequences an x-mer must appear in.

---

### Running the Pipeline

Execute the entire pipeline with:
```r
source("scripts/run_analysis.R")
```

To customize the workflow:
1. Modify parameters in `scripts/00_setup_environment.R`.
2. Run specific steps by sourcing the corresponding scripts in the `scripts/` directory.

---

## Example Output

### Network Graph
The network graph is saved to:
```
output/figures/network_graph1.svg
```

Here’s a preview of the graph:

![Network Graph](output/figures/network_graph1.svg)

---

# Xmer Network Analysis

[![DOI](https://zenodo.org/badge/901558465.svg)](https://doi.org/10.5281/zenodo.14398864)

## Citation

If you use this repository in your work, please cite it as:

>Diversifying T-cell responses: safeguarding against pandemic influenza with mosaic nucleoprotein. 
>Park H, Kingstad-Bakke B, Cleven T, Jung M, Kawaoka Y, Suresh M.
>J Virol. 2025 Mar 18;99(3):e0086724. doi: 10.1128/jvi.00867-24. Epub 2025 Feb 3. PMID: 39898643; PMCID: PMC11915837.



---

## Contact

For questions or feedback, contact me through github.
