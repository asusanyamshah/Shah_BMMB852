SHELL := /bin/bash

REFERENCE_SAMPLE := SRR2584863
EXTRA_SAMPLES := SRR2584405 SRR2584406
N ?= 155000
THREADS ?= 2

REF := ../week05/sequences/NC_000913.3.fasta
REFERENCE_BAM := ../week05/bam/$(REFERENCE_SAMPLE).sorted.bam
RAW_DIR := raw
TRIMMED_DIR := trimmed
BAM_DIR := bam
ANNOTATION_DIR := annotations
RESULTS_DIR := results

REFERENCE_BAM_WITH_RG := $(BAM_DIR)/$(REFERENCE_SAMPLE).sorted.bam
SAMPLE_BAMS := $(REFERENCE_BAM_WITH_RG) $(addprefix $(BAM_DIR)/,$(addsuffix .sorted.bam,$(EXTRA_SAMPLES)))
VCF := $(RESULTS_DIR)/ecoli.multisample.vcf.gz
ANNOTATED_VCF := $(RESULTS_DIR)/ecoli.multisample.annotated.vcf.gz
STATS := $(RESULTS_DIR)/ecoli.multisample.stats.txt
ANNOTATED_STATS := $(RESULTS_DIR)/ecoli.multisample.annotated.stats.txt
GFF := $(ANNOTATION_DIR)/NC_000913.3.coding.gff3
GFF_URL := https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.gff.gz

BWA ?= bwa
BCFTOOLS ?= /opt/homebrew/Caskroom/miniforge/base/envs/variantcall/bin/bcftools
SAMTOOLS ?= samtools
FASTP ?= fastp
PREFETCH ?= prefetch
FASTERQ_DUMP ?= fasterq-dump

.PHONY: all variants annotate stats clean
.SECONDARY:

all: $(STATS) $(ANNOTATED_STATS)

variants: $(VCF)

annotate: $(ANNOTATED_VCF)

stats: $(STATS) $(ANNOTATED_STATS)

$(RAW_DIR) $(TRIMMED_DIR) $(BAM_DIR) $(ANNOTATION_DIR) $(RESULTS_DIR):
	mkdir -p $@

$(REF).bwt: $(REF)
	$(BWA) index $<

$(RAW_DIR)/%.done: | $(RAW_DIR)
	$(PREFETCH) $*
	$(FASTERQ_DUMP) --split-files --threads $(THREADS) --outdir $(RAW_DIR) $*
	test -s "$(RAW_DIR)/$*_1.fastq"
	test -s "$(RAW_DIR)/$*_2.fastq"
	head -n $$(( $(N) * 4 )) "$(RAW_DIR)/$*_1.fastq" > "$(RAW_DIR)/$*_1.tmp.fastq"
	head -n $$(( $(N) * 4 )) "$(RAW_DIR)/$*_2.fastq" > "$(RAW_DIR)/$*_2.tmp.fastq"
	mv "$(RAW_DIR)/$*_1.tmp.fastq" "$(RAW_DIR)/$*_1.fastq"
	mv "$(RAW_DIR)/$*_2.tmp.fastq" "$(RAW_DIR)/$*_2.fastq"
	touch $@

$(TRIMMED_DIR)/%.trimmed: $(RAW_DIR)/%.done | $(TRIMMED_DIR)
	$(FASTP) --thread $(THREADS) \
		-i "$(RAW_DIR)/$*_1.fastq" -I "$(RAW_DIR)/$*_2.fastq" \
		-o "$(TRIMMED_DIR)/$*_1.fastq" -O "$(TRIMMED_DIR)/$*_2.fastq" \
		--html "$(TRIMMED_DIR)/$*.html" --json "$(TRIMMED_DIR)/$*.json"
	touch $@

$(REFERENCE_BAM_WITH_RG): $(REFERENCE_BAM) | $(BAM_DIR)
	$(SAMTOOLS) addreplacerg -m overwrite_all \
		-r "@RG\tID:$(REFERENCE_SAMPLE)\tSM:$(REFERENCE_SAMPLE)\tPL:ILLUMINA" \
		-o $@ $<
	$(SAMTOOLS) index $@

$(BAM_DIR)/%.sorted.bam: $(TRIMMED_DIR)/%.trimmed $(REF).bwt | $(BAM_DIR)
	$(BWA) mem -t $(THREADS) \
		-R "@RG\tID:$*\tSM:$*\tPL:ILLUMINA" \
		$(REF) "$(TRIMMED_DIR)/$*_1.fastq" "$(TRIMMED_DIR)/$*_2.fastq" \
		| $(SAMTOOLS) sort -@ $(THREADS) -o $@
	$(SAMTOOLS) index $@

$(VCF): $(SAMPLE_BAMS) $(REF) | $(RESULTS_DIR)
	set -o pipefail; \
	$(BCFTOOLS) mpileup -f $(REF) \
		--annotate FORMAT/DP,FORMAT/AD,FORMAT/ADF,FORMAT/ADR \
		-Ou $(SAMPLE_BAMS) \
		| $(BCFTOOLS) call --ploidy 1 -m -v -Ou \
		| $(BCFTOOLS) norm -f $(REF) -d all -Oz -o "$@.tmp"
	$(BCFTOOLS) index -f "$@.tmp"
	mv "$@.tmp" $@
	mv "$@.tmp.csi" "$@.csi"

$(GFF): | $(ANNOTATION_DIR)
	set -o pipefail; \
	curl -fsSL "$(GFF_URL)" | gzip -dc > "$@.raw"
	awk -F '\t' 'BEGIN { OFS = "\t" } \
		/^#/ { print; next } \
		$$1 != "NC_000913.3" { next } \
		$$3 == "gene" { print; next } \
		$$3 == "CDS" { \
			count = split($$9, attrs, ";"); \
			id = parent = gene = ""; \
			for (i = 1; i <= count; i++) { \
				if (attrs[i] ~ /^ID=/) id = substr(attrs[i], 4); \
				else if (attrs[i] ~ /^Parent=/) parent = substr(attrs[i], 8); \
				else if (attrs[i] ~ /^gene=/) gene = substr(attrs[i], 6); \
			} \
			transcript = "transcript-" id; \
			$$3 = "mRNA"; \
			$$9 = "ID=" transcript ";Parent=" parent ";biotype=protein_coding"; \
			if (gene != "") $$9 = $$9 ";gene=" gene; \
			print; \
			$$3 = "CDS"; \
			sub(/Parent=[^;]*/, "Parent=" transcript, $$9); \
			print; \
		}' "$@.raw" > "$@.tmp"
	mv "$@.tmp" $@
	rm -f "$@.raw"

$(ANNOTATED_VCF): $(VCF) $(GFF) | $(RESULTS_DIR)
	$(BCFTOOLS) csq -f $(REF) -g $(GFF) -Oz -o "$@.tmp" $(VCF)
	$(BCFTOOLS) index -f "$@.tmp"
	mv "$@.tmp" $@
	mv "$@.tmp.csi" "$@.csi"

$(STATS): $(VCF) | $(RESULTS_DIR)
	$(BCFTOOLS) stats $(VCF) > $@

$(ANNOTATED_STATS): $(ANNOTATED_VCF) | $(RESULTS_DIR)
	$(BCFTOOLS) stats $(ANNOTATED_VCF) > $@

clean:
	rm -rf $(RAW_DIR) $(TRIMMED_DIR) $(BAM_DIR) $(ANNOTATION_DIR) $(RESULTS_DIR)
