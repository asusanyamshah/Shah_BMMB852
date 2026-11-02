SHELL := /bin/bash

# ---- single-sample parameters (overridden by batch/parallel) ----
SRR      ?= SRR949136
SAMPLE   ?= ChIP_H3K4me1_rep1
N        ?= 10000000
THREADS  ?= 4

# ---- genome (human chr3 subset, Ensembl) ----
GENOME_FASTA := genome/chr3.fasta
GENOME_URL   := https://ftp.ensembl.org/pub/release-112/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.chromosome.3.fa.gz
EFFECTIVE_GENOME_SIZE := hs

# ---- shared paths ----
RAW_DIR      := raw
TRIMMED_DIR  := trimmed
BAM_DIR      := bam
PEAKS_DIR    := peaks
RESULTS_DIR  := results
DESIGN       := design.csv

# the input/background sample name (must match a row in design.csv with type=Input)
CONTROL_SAMPLE ?= ChIP_Input

# ---- tools ----
BWA           ?= bwa
SAMTOOLS      ?= samtools
FASTP         ?= fastp
PREFETCH      ?= prefetch
FASTERQ_DUMP  ?= fasterq-dump
MACS3         ?= macs3

PARALLEL := parallel --colsep , --header : --eta --lb -j 2

BAM := $(BAM_DIR)/$(SAMPLE).sorted.bam
CONTROL_BAM := $(BAM_DIR)/$(CONTROL_SAMPLE).sorted.bam

.PHONY: all background peaks batch batch-background stats clean print
.SECONDARY:

all: $(BAM)

print:
	@echo "SRR=$(SRR) SAMPLE=$(SAMPLE) N=$(N) GENOME=$(GENOME_FASTA)"

$(RAW_DIR) $(TRIMMED_DIR) $(BAM_DIR) $(RESULTS_DIR) genome:
	mkdir -p $@

# ---- reference genome: download + index once ----
$(GENOME_FASTA): | genome
	curl -fsSL $(GENOME_URL) | gunzip -c > $@

$(GENOME_FASTA).bwt: $(GENOME_FASTA)
	$(BWA) index $<

# ---- download + subsample single-end reads for one run accession ----
$(RAW_DIR)/$(SAMPLE).done: | $(RAW_DIR)
	$(PREFETCH) $(SRR) -O $(RAW_DIR)
	$(FASTERQ_DUMP) --threads $(THREADS) --outdir $(RAW_DIR) $(RAW_DIR)/$(SRR)/$(SRR).sra
	test -s "$(RAW_DIR)/$(SRR).fastq"
	head -n $$(( $(N) * 4 )) "$(RAW_DIR)/$(SRR).fastq" > "$(RAW_DIR)/$(SAMPLE).fastq"
	rm -rf "$(RAW_DIR)/$(SRR)" "$(RAW_DIR)/$(SRR).fastq"
	touch $@

# ---- trim (single-end) ----
$(TRIMMED_DIR)/$(SAMPLE).trimmed: $(RAW_DIR)/$(SAMPLE).done | $(TRIMMED_DIR)
	$(FASTP) --thread $(THREADS) \
		-i "$(RAW_DIR)/$(SAMPLE).fastq" \
		-o "$(TRIMMED_DIR)/$(SAMPLE).fastq" \
		--html "$(TRIMMED_DIR)/$(SAMPLE).html" --json "$(TRIMMED_DIR)/$(SAMPLE).json"
	touch $@

# ---- align (single-end) ----
$(BAM): $(TRIMMED_DIR)/$(SAMPLE).trimmed $(GENOME_FASTA).bwt | $(BAM_DIR)
	$(BWA) mem -t $(THREADS) \
		-R "@RG\tID:$(SAMPLE)\tSM:$(SAMPLE)\tPL:ILLUMINA" \
		$(GENOME_FASTA) "$(TRIMMED_DIR)/$(SAMPLE).fastq" \
		| $(SAMTOOLS) sort -@ $(THREADS) -o $@
	$(SAMTOOLS) index $@

# ---- build the background/input BAM (same pipeline, forced to CONTROL_SAMPLE) ----
background:
	$(MAKE) SRR=SRR949142 SAMPLE=$(CONTROL_SAMPLE) all

# ---- call peaks for ONE ChIP sample against the shared control BAM ----
peaks: $(BAM) $(CONTROL_BAM)
	mkdir -p $(PEAKS_DIR)
	$(MACS3) callpeak \
		-t $(BAM) \
		-c $(CONTROL_BAM) \
		-n $(SAMPLE) \
		-g $(EFFECTIVE_GENOME_SIZE) \
		-q 0.01 \
		--outdir $(PEAKS_DIR)

# ---- batch processing: align every ChIP sample listed in design.csv ----
batch:
	cat $(DESIGN) | $(PARALLEL) \
		$(MAKE) SRR={run} SAMPLE={sample} N=$(N) THREADS=$(THREADS) all

# ---- call peaks for every ChIP sample (skips the Input row) ----
batch-peaks:
	awk -F, 'NR==1{next} $$2!="Input"{print}' $(DESIGN) | $(PARALLEL) --colsep , \
		$(MAKE) SRR={1} SAMPLE={4} N=$(N) THREADS=$(THREADS) peaks

stats:
	$(SAMTOOLS) flagstat $(BAM)

clean:
	rm -rf $(RAW_DIR) $(TRIMMED_DIR) $(BAM_DIR) $(PEAKS_DIR) $(RESULTS_DIR)
