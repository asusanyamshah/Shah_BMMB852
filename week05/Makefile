RUN ?= SRR2584863
ACCESSION := NC_000913.3
N ?= 155000
THREADS ?= 2

NCBI_URL := https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi

SEQUENCES_DIR := sequences
RAW_DIR := raw
TRIMMED_DIR := trimmed
BAM_DIR := bam
STATS_DIR := stats

FASTA := $(SEQUENCES_DIR)/$(ACCESSION).fasta
INDEX_DONE := $(SEQUENCES_DIR)/.indexed
DOWNLOAD_DONE := $(RAW_DIR)/.downloaded
TRIM_DONE := $(TRIMMED_DIR)/.trimmed
BAM := $(BAM_DIR)/$(RUN).sorted.bam
STATS := $(STATS_DIR)/$(RUN).flagstat.txt

.PHONY: all genome reads index trim align stats clean

all: stats

genome: $(FASTA)

$(FASTA):
	mkdir -p $(SEQUENCES_DIR)
	curl -fL "$(NCBI_URL)?db=nuccore&id=$(ACCESSION)&rettype=fasta&retmode=text" -o $@

index: $(INDEX_DONE)

$(INDEX_DONE): $(FASTA)
	bwa index $(FASTA)
	touch $@

reads: $(DOWNLOAD_DONE)

$(DOWNLOAD_DONE):
	mkdir -p $(RAW_DIR)
	prefetch $(RUN)
	fasterq-dump --split-files --threads $(THREADS) --outdir $(RAW_DIR) $(RUN)
	head -n $$(($(N) * 4)) "$(RAW_DIR)/$(RUN)_1.fastq" > "$(RAW_DIR)/$(RUN)_1.tmp.fastq"
	mv "$(RAW_DIR)/$(RUN)_1.tmp.fastq" "$(RAW_DIR)/$(RUN)_1.fastq"
	head -n $$(($(N) * 4)) "$(RAW_DIR)/$(RUN)_2.fastq" > "$(RAW_DIR)/$(RUN)_2.tmp.fastq"
	mv "$(RAW_DIR)/$(RUN)_2.tmp.fastq" "$(RAW_DIR)/$(RUN)_2.fastq"
	touch $@

trim: $(TRIM_DONE)

$(TRIM_DONE): $(DOWNLOAD_DONE)
	mkdir -p $(TRIMMED_DIR)
	fastp --thread $(THREADS) \
		-i "$(RAW_DIR)/$(RUN)_1.fastq" -I "$(RAW_DIR)/$(RUN)_2.fastq" \
		-o "$(TRIMMED_DIR)/$(RUN)_1.fastq" -O "$(TRIMMED_DIR)/$(RUN)_2.fastq" \
		--html "$(TRIMMED_DIR)/$(RUN).html" --json "$(TRIMMED_DIR)/$(RUN).json"
	touch $@

align: $(BAM)

$(BAM): $(INDEX_DONE) $(TRIM_DONE)
	mkdir -p $(BAM_DIR)
	bwa mem -t $(THREADS) $(FASTA) \
		$(TRIMMED_DIR)/$(RUN)_1.fastq \
		$(TRIMMED_DIR)/$(RUN)_2.fastq \
		| samtools sort -@ $(THREADS) -o $(BAM)
	samtools index $(BAM)

stats: $(STATS)

$(STATS): $(BAM)
	mkdir -p $(STATS_DIR)
	samtools flagstat $(BAM) > $@

clean:
	rm -rf $(SEQUENCES_DIR) $(RAW_DIR) $(TRIMMED_DIR) $(BAM_DIR) $(STATS_DIR)