ACCESSION := NC_007558.1
NCBI_URL := https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi
SEQUENCES_DIR := sequences
FASTA := $(SEQUENCES_DIR)/$(ACCESSION).fasta
GFF := $(SEQUENCES_DIR)/$(ACCESSION).gff

.PHONY: all download clean

all: download

download: $(FASTA) $(GFF)

$(FASTA):
	mkdir -p $(SEQUENCES_DIR)
	datasets download virus genome accession $(ACCESSION) --include genome --filename $(SEQUENCES_DIR)/$(ACCESSION)_genome.zip
	unzip -o $(SEQUENCES_DIR)/$(ACCESSION)_genome.zip -d $(SEQUENCES_DIR)/$(ACCESSION)_tmp
	cp $(SEQUENCES_DIR)/$(ACCESSION)_tmp/ncbi_dataset/data/genomic.fna $(FASTA)
	rm -rf $(SEQUENCES_DIR)/$(ACCESSION)_genome.zip $(SEQUENCES_DIR)/$(ACCESSION)_tmp

$(GFF):
	mkdir -p $(SEQUENCES_DIR)
	curl -fL "$(NCBI_URL)?db=nuccore&id=$(ACCESSION)&rettype=gff3&retmode=text" -o $@

clean:
	rm -rf $(SEQUENCES_DIR)