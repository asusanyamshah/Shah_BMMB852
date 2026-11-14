SHELL := /bin/bash

# ---- reuse week11's reference data and fastq files ----
WK11            := ../week11
TRANSCRIPTS_FA  := $(WK11)/fasta/chr22.transcripts.fa
GENOME_GTF      := $(WK11)/gtf/chr22.gtf
FASTQ_DIR       := $(WK11)/fastq
GENE_COUNTS_DIR := $(WK11)/counts
DESIGN          := $(WK11)/design.csv

# ---- salmon quantification ----
SALMON_INDEX := salmon_index
COUNTS_DIR   := counts
RESULTS_DIR  := results
THREADS      ?= 4

SALMON ?= salmon

SAMPLES := HBR_1 HBR_2 HBR_3 UHR_1 UHR_2 UHR_3

.PHONY: all index quant gene_counts transcript_counts transcripts_as_genes summarize compare clean print

all: transcript_counts transcripts_as_genes gene_counts compare summarize

print:
	@echo "SAMPLES = $(SAMPLES)"
	@echo "TRANSCRIPTS_FA = $(TRANSCRIPTS_FA)"

$(SALMON_INDEX) $(COUNTS_DIR) $(RESULTS_DIR):
	mkdir -p $@

# ---- build the salmon index once from the transcriptome FASTA ----
$(SALMON_INDEX)/info.json: $(TRANSCRIPTS_FA) | $(SALMON_INDEX)
	$(SALMON) index -t $(TRANSCRIPTS_FA) -i $(SALMON_INDEX) -k 31

index: $(SALMON_INDEX)/info.json

# ---- quantify a single sample ----
$(COUNTS_DIR)/%/quant.sf: $(SALMON_INDEX)/info.json | $(COUNTS_DIR)
	$(SALMON) quant -i $(SALMON_INDEX) -l A \
		-r $(FASTQ_DIR)/$*_R1.fq \
		-p $(THREADS) \
		--validateMappings \
		-o $(COUNTS_DIR)/$*

# ---- quantify every sample listed in SAMPLES ----
quant: $(foreach s,$(SAMPLES),$(COUNTS_DIR)/$(s)/quant.sf)

# ---- R-based downstream matrices ----
transcript_counts: quant | $(RESULTS_DIR)
	Rscript src/combine_transcript_counts.r

transcripts_as_genes: transcript_counts | $(RESULTS_DIR)
	Rscript src/summarize_transcripts_as_genes.r

gene_counts: | $(RESULTS_DIR)
	Rscript src/combine_gene_counts.r

summarize: gene_counts
	Rscript src/summarize_gene_counts.r

compare: transcripts_as_genes gene_counts
	Rscript src/compare_gene_counts.r

clean:
	rm -rf $(SALMON_INDEX) $(COUNTS_DIR) $(RESULTS_DIR)