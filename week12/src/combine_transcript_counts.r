# Combine per-sample Salmon quant.sf files into a single transcript-level
# count matrix, with gene names/IDs attached via the GTF (no biomaRt needed
# since the GTF already carries gene_id and gene_name for every transcript).
#
# Input:
#   ../week11/design.csv       sample, group
#   counts/<sample>/quant.sf   Salmon output (one directory per sample)
#   ../week11/gtf/chr22.gtf    transcript_id -> gene_id -> gene_name mapping
#
# Output:
#   results/transcript_counts.csv   transcript, gene, name, <sample1>, ...

suppressMessages({
  library(tximport)
  library(dplyr)
  library(readr)
})

design <- read_csv("../week11/design.csv", show_col_types = FALSE)

files <- file.path("counts", design$sample, "quant.sf")
names(files) <- design$sample

stopifnot(all(file.exists(files)))

# txOut = TRUE keeps per-transcript rows (not summarized to genes here).
# counts, not TPM: tximport's "counts" slot holds NumReads from Salmon.
txi <- tximport(files, type = "salmon", txOut = TRUE)

expr <- as.data.frame(txi$counts)
expr <- cbind(transcript = rownames(expr), expr)
rownames(expr) <- NULL

# ---- build transcript_id -> gene_id -> gene_name map from the GTF ----
gtf_lines <- readLines("../week11/gtf/chr22.gtf")
gtf_lines <- gtf_lines[!startsWith(gtf_lines, "#")]

extract_attr <- function(attr_string, key) {
  m <- regmatches(attr_string, regexpr(paste0(key, ' "[^"]+"'), attr_string))
  sub(paste0(key, ' "([^"]+)"'), "\\1", m)
}

tx_lines <- gtf_lines[grepl("\ttranscript\t", gtf_lines)]
fields <- strsplit(tx_lines, "\t")
attrs  <- sapply(fields, function(f) f[9])

transcript_id <- sapply(attrs, extract_attr, key = "transcript_id")
gene_id       <- sapply(attrs, extract_attr, key = "gene_id")
gene_name     <- sapply(attrs, extract_attr, key = "gene_name")

tx_map <- data.frame(
  transcript = transcript_id,
  gene = gene_id,
  name = gene_name,
  stringsAsFactors = FALSE
)
tx_map <- tx_map[!duplicated(tx_map$transcript), ]

expr <- expr %>%
  left_join(tx_map, by = "transcript") %>%
  relocate(gene, name, .after = transcript)

dir.create("results", showWarnings = FALSE)
write_csv(expr, "results/transcript_counts.csv")

cat("Wrote results/transcript_counts.csv with", nrow(expr), "transcripts and",
    length(design$sample), "samples\n")
