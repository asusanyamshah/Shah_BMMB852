RUN ?= ERR13704263
N ?= 10000
THREADS ?= 2

RAW_DIR := raw
TRIMMED_DIR := trimmed
RAW_QC_DIR := qc/raw
TRIMMED_QC_DIR := qc/trimmed

DOWNLOAD_DONE := $(RAW_DIR)/.downloaded
TRIM_DONE := $(TRIMMED_DIR)/.trimmed
RAW_QC_DONE := $(RAW_QC_DIR)/.complete
TRIMMED_QC_DONE := $(TRIMMED_QC_DIR)/.complete

.PHONY: all download raw-qc trim trimmed-qc clean

all: raw-qc trimmed-qc

download: $(DOWNLOAD_DONE)

$(DOWNLOAD_DONE):
	mkdir -p $(RAW_DIR)
	prefetch $(RUN)
	fasterq-dump --split-files --threads $(THREADS) --outdir $(RAW_DIR) $(RUN)
	if [ -f "$(RAW_DIR)/$(RUN)_1.fastq" ]; then \
		head -n $$(($(N) * 4)) "$(RAW_DIR)/$(RUN)_1.fastq" > "$(RAW_DIR)/$(RUN)_1.tmp.fastq"; \
		mv "$(RAW_DIR)/$(RUN)_1.tmp.fastq" "$(RAW_DIR)/$(RUN)_1.fastq"; \
		head -n $$(($(N) * 4)) "$(RAW_DIR)/$(RUN)_2.fastq" > "$(RAW_DIR)/$(RUN)_2.tmp.fastq"; \
		mv "$(RAW_DIR)/$(RUN)_2.tmp.fastq" "$(RAW_DIR)/$(RUN)_2.fastq"; \
	else \
		head -n $$(($(N) * 4)) "$(RAW_DIR)/$(RUN).fastq" > "$(RAW_DIR)/$(RUN).tmp.fastq"; \
		mv "$(RAW_DIR)/$(RUN).tmp.fastq" "$(RAW_DIR)/$(RUN).fastq"; \
	fi
	touch $@

raw-qc: $(RAW_QC_DONE)

$(RAW_QC_DONE): $(DOWNLOAD_DONE)
	mkdir -p $(RAW_QC_DIR)
	fastqc --threads $(THREADS) --outdir $(RAW_QC_DIR) $(RAW_DIR)/*.fastq
	touch $@

trim: $(TRIM_DONE)

$(TRIM_DONE): $(DOWNLOAD_DONE)
	mkdir -p $(TRIMMED_DIR)
	set -eu; \
	for read1 in $(RAW_DIR)/*_1.fastq; do \
		[ -e "$$read1" ] || continue; \
		read2="$${read1%_1.fastq}_2.fastq"; \
		sample="$$(basename "$${read1%_1.fastq}")"; \
		fastp --thread $(THREADS) \
			-i "$$read1" -I "$$read2" \
			-o "$(TRIMMED_DIR)/$${sample}_1.fastq" \
			-O "$(TRIMMED_DIR)/$${sample}_2.fastq" \
			--html "$(TRIMMED_DIR)/$${sample}.html" \
			--json "$(TRIMMED_DIR)/$${sample}.json"; \
	done; \
	for read1 in $(RAW_DIR)/*.fastq; do \
		case "$$read1" in *_1.fastq|*_2.fastq) continue ;; esac; \
		sample="$$(basename "$$read1" .fastq)"; \
		fastp --thread $(THREADS) \
			-i "$$read1" \
			-o "$(TRIMMED_DIR)/$${sample}.fastq" \
			--html "$(TRIMMED_DIR)/$${sample}.html" \
			--json "$(TRIMMED_DIR)/$${sample}.json"; \
	done
	touch $@

trimmed-qc: $(TRIMMED_QC_DONE)

$(TRIMMED_QC_DONE): $(TRIM_DONE)
	mkdir -p $(TRIMMED_QC_DIR)
	fastqc --threads $(THREADS) --outdir $(TRIMMED_QC_DIR) $(TRIMMED_DIR)/*.fastq
	touch $@

clean:
	rm -rf $(RAW_DIR) $(TRIMMED_DIR) qc