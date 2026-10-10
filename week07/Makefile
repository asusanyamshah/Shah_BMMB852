REF := ../week05/sequences/NC_000913.3.fasta
BAM := ../week05/bam/SRR2584863.sorted.bam
RESULTS_DIR := results
VCF := $(RESULTS_DIR)/SRR2584863.vcf
STATS := $(RESULTS_DIR)/SRR2584863.stats.txt
BCFTOOLS ?= /opt/homebrew/Caskroom/miniforge/base/envs/variantcall/bin/bcftools

.PHONY: all vcf stats clean

all: stats

vcf: $(VCF)

stats: $(STATS)

$(RESULTS_DIR):
	mkdir -p $@

$(VCF): $(BAM) $(REF) | $(RESULTS_DIR)
	$(BCFTOOLS) mpileup -f $(REF) $(BAM) -Ou | $(BCFTOOLS) call -m -v --ploidy 1 -o $@

$(STATS): $(VCF) | $(RESULTS_DIR)
	$(BCFTOOLS) stats $(VCF) > $@

clean:
	rm -rf $(RESULTS_DIR)
