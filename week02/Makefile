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
	curl -fL "$(NCBI_URL)?db=nuccore&id=$(ACCESSION)&rettype=fasta&retmode=text" -o $@

$(GFF):
	mkdir -p $(SEQUENCES_DIR)
	curl -fL "$(NCBI_URL)?db=nuccore&id=$(ACCESSION)&rettype=gff3&retmode=text" -o $@

clean:
	rm -f $(FASTA) $(GFF)


