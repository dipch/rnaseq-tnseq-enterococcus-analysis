#!/bin/bash
# Creates symbolic links from the course data dir to the project data dir 

set -euo pipefail

# ── Paths ──────────────────────────────────────────────────────────────────────
DATA=/proj/uppmax2026-1-61/Genome_Analysis/1_Zhang_2017
RAW=$HOME/rnaseq-tnseq-enterococcus-analysis/data/raw_data
TRIMMED=$HOME/rnaseq-tnseq-enterococcus-analysis/data/trimmed_data

# check if source data dir exists
if [[ ! -d "$DATA" ]]; then
    echo "error: source data dir not found: $DATA"
    exit 1
fi

# create target dir 
mkdir -p "$RAW"
mkdir -p "$TRIMMED"

echo "Creating symlinks..."
echo "  Source : $DATA"
echo "  Raw    : $RAW"
echo ""

# dna - illumina 
ln -sf "$DATA/genomics_data/Illumina/E745-1.L500_SZAXPI015146-56_1_clean.fq.gz"  "$RAW/dna_illumina_R1.fq.gz"
ln -sf "$DATA/genomics_data/Illumina/E745-1.L500_SZAXPI015146-56_2_clean.fq.gz"  "$RAW/dna_illumina_R2.fq.gz"

# dna - nanopore
ln -sf "$DATA/genomics_data/Nanopore/E745_all.fasta.gz"  "$RAW/dna_nanopore_all.fasta.gz"



# pacbio run1
ln -sf "$DATA/genomics_data/PacBio/m131023_233432_42174_c100519312550000001823081209281335_s1_X0.1.subreads.fastq.gz"  "$RAW/dna_pacbio_run1_cell1.subreads.fastq.gz"
ln -sf "$DATA/genomics_data/PacBio/m131023_233432_42174_c100519312550000001823081209281335_s1_X0.2.subreads.fastq.gz"  "$RAW/dna_pacbio_run1_cell2.subreads.fastq.gz"
ln -sf "$DATA/genomics_data/PacBio/m131023_233432_42174_c100519312550000001823081209281335_s1_X0.3.subreads.fastq.gz"  "$RAW/dna_pacbio_run1_cell3.subreads.fastq.gz"

# pacbio run2
ln -sf "$DATA/genomics_data/PacBio/m131024_200535_42174_c100563672550000001823084212221342_s1_p0.1.subreads.fastq.gz"  "$RAW/dna_pacbio_run2_cell1.subreads.fastq.gz"
ln -sf "$DATA/genomics_data/PacBio/m131024_200535_42174_c100563672550000001823084212221342_s1_p0.2.subreads.fastq.gz"  "$RAW/dna_pacbio_run2_cell2.subreads.fastq.gz"
ln -sf "$DATA/genomics_data/PacBio/m131024_200535_42174_c100563672550000001823084212221342_s1_p0.3.subreads.fastq.gz"  "$RAW/dna_pacbio_run2_cell3.subreads.fastq.gz"



# rna - bhi - raw
ln -sf "$DATA/transcriptomics_data/RNA-Seq_BH/raw/ERR1797972_1.fastq.gz"  "$RAW/rna_bhi_rep1_R1.fastq.gz"
ln -sf "$DATA/transcriptomics_data/RNA-Seq_BH/raw/ERR1797972_2.fastq.gz"  "$RAW/rna_bhi_rep1_R2.fastq.gz"
ln -sf "$DATA/transcriptomics_data/RNA-Seq_BH/raw/ERR1797973_1.fastq.gz"  "$RAW/rna_bhi_rep2_R1.fastq.gz"
ln -sf "$DATA/transcriptomics_data/RNA-Seq_BH/raw/ERR1797973_2.fastq.gz"  "$RAW/rna_bhi_rep2_R2.fastq.gz"
ln -sf "$DATA/transcriptomics_data/RNA-Seq_BH/raw/ERR1797974_1.fastq.gz"  "$RAW/rna_bhi_rep3_R1.fastq.gz"
ln -sf "$DATA/transcriptomics_data/RNA-Seq_BH/raw/ERR1797974_2.fastq.gz"  "$RAW/rna_bhi_rep3_R2.fastq.gz"

# rna - serum - raw
ln -sf "$DATA/transcriptomics_data/RNA-Seq_Serum/raw/ERR1797969_1.fastq.gz"  "$RAW/rna_serum_rep1_R1.fastq.gz"
ln -sf "$DATA/transcriptomics_data/RNA-Seq_Serum/raw/ERR1797969_2.fastq.gz"  "$RAW/rna_serum_rep1_R2.fastq.gz"
ln -sf "$DATA/transcriptomics_data/RNA-Seq_Serum/raw/ERR1797970_1.fastq.gz"  "$RAW/rna_serum_rep2_R1.fastq.gz"
ln -sf "$DATA/transcriptomics_data/RNA-Seq_Serum/raw/ERR1797970_2.fastq.gz"  "$RAW/rna_serum_rep2_R2.fastq.gz"
ln -sf "$DATA/transcriptomics_data/RNA-Seq_Serum/raw/ERR1797971_1.fastq.gz"  "$RAW/rna_serum_rep3_R1.fastq.gz"
ln -sf "$DATA/transcriptomics_data/RNA-Seq_Serum/raw/ERR1797971_2.fastq.gz"  "$RAW/rna_serum_rep3_R2.fastq.gz"

# # rna - bhi - trimmed
# ln -sf "$DATA/transcriptomics_data/RNA-Seq_BH/trimmed/trim_paired_ERR1797972_pass_1.fastq.gz"  "$TRIMMED/rna_bhi_rep1_paired_R1.fastq.gz"
# ln -sf "$DATA/transcriptomics_data/RNA-Seq_BH/trimmed/trim_paired_ERR1797972_pass_2.fastq.gz"  "$TRIMMED/rna_bhi_rep1_paired_R2.fastq.gz"
# ln -sf "$DATA/transcriptomics_data/RNA-Seq_BH/trimmed/trim_single_ERR1797972_pass_1.fastq.gz"  "$TRIMMED/rna_bhi_rep1_single_R1.fastq.gz"
# ln -sf "$DATA/transcriptomics_data/RNA-Seq_BH/trimmed/trim_single_ERR1797972_pass_2.fastq.gz"  "$TRIMMED/rna_bhi_rep1_single_R2.fastq.gz"
# ln -sf "$DATA/transcriptomics_data/RNA-Seq_BH/trimmed/trim_paired_ERR1797973_pass_1.fastq.gz"  "$TRIMMED/rna_bhi_rep2_paired_R1.fastq.gz"
# ln -sf "$DATA/transcriptomics_data/RNA-Seq_BH/trimmed/trim_paired_ERR1797973_pass_2.fastq.gz"  "$TRIMMED/rna_bhi_rep2_paired_R2.fastq.gz"
# ln -sf "$DATA/transcriptomics_data/RNA-Seq_BH/trimmed/trim_single_ERR1797973_pass_1.fastq.gz"  "$TRIMMED/rna_bhi_rep2_single_R1.fastq.gz"
# ln -sf "$DATA/transcriptomics_data/RNA-Seq_BH/trimmed/trim_single_ERR1797973_pass_2.fastq.gz"  "$TRIMMED/rna_bhi_rep2_single_R2.fastq.gz"
# ln -sf "$DATA/transcriptomics_data/RNA-Seq_BH/trimmed/trim_paired_ERR1797974_pass_1.fastq.gz"  "$TRIMMED/rna_bhi_rep3_paired_R1.fastq.gz"
# ln -sf "$DATA/transcriptomics_data/RNA-Seq_BH/trimmed/trim_paired_ERR1797974_pass_2.fastq.gz"  "$TRIMMED/rna_bhi_rep3_paired_R2.fastq.gz"
# ln -sf "$DATA/transcriptomics_data/RNA-Seq_BH/trimmed/trim_single_ERR1797974_pass_1.fastq.gz"  "$TRIMMED/rna_bhi_rep3_single_R1.fastq.gz"
# ln -sf "$DATA/transcriptomics_data/RNA-Seq_BH/trimmed/trim_single_ERR1797974_pass_2.fastq.gz"  "$TRIMMED/rna_bhi_rep3_single_R2.fastq.gz"

# # rna - serum - trimmed
# ln -sf "$DATA/transcriptomics_data/RNA-Seq_Serum/trimmed/trim_paired_ERR1797969_pass_1.fastq.gz"  "$TRIMMED/rna_serum_rep1_paired_R1.fastq.gz"
# ln -sf "$DATA/transcriptomics_data/RNA-Seq_Serum/trimmed/trim_paired_ERR1797969_pass_2.fastq.gz"  "$TRIMMED/rna_serum_rep1_paired_R2.fastq.gz"
# ln -sf "$DATA/transcriptomics_data/RNA-Seq_Serum/trimmed/trim_single_ERR1797969_pass_1.fastq.gz"  "$TRIMMED/rna_serum_rep1_single_R1.fastq.gz"
# ln -sf "$DATA/transcriptomics_data/RNA-Seq_Serum/trimmed/trim_single_ERR1797969_pass_2.fastq.gz"  "$TRIMMED/rna_serum_rep1_single_R2.fastq.gz"
# ln -sf "$DATA/transcriptomics_data/RNA-Seq_Serum/trimmed/trim_paired_ERR1797970_pass_1.fastq.gz"  "$TRIMMED/rna_serum_rep2_paired_R1.fastq.gz"
# ln -sf "$DATA/transcriptomics_data/RNA-Seq_Serum/trimmed/trim_paired_ERR1797970_pass_2.fastq.gz"  "$TRIMMED/rna_serum_rep2_paired_R2.fastq.gz"
# ln -sf "$DATA/transcriptomics_data/RNA-Seq_Serum/trimmed/trim_single_ERR1797970_pass_1.fastq.gz"  "$TRIMMED/rna_serum_rep2_single_R1.fastq.gz"
# ln -sf "$DATA/transcriptomics_data/RNA-Seq_Serum/trimmed/trim_single_ERR1797970_pass_2.fastq.gz"  "$TRIMMED/rna_serum_rep2_single_R2.fastq.gz"
# ln -sf "$DATA/transcriptomics_data/RNA-Seq_Serum/trimmed/trim_paired_ERR1797971_pass_1.fastq.gz"  "$TRIMMED/rna_serum_rep3_paired_R1.fastq.gz"
# ln -sf "$DATA/transcriptomics_data/RNA-Seq_Serum/trimmed/trim_paired_ERR1797971_pass_2.fastq.gz"  "$TRIMMED/rna_serum_rep3_paired_R2.fastq.gz"
# ln -sf "$DATA/transcriptomics_data/RNA-Seq_Serum/trimmed/trim_single_ERR1797971_pass_1.fastq.gz"  "$TRIMMED/rna_serum_rep3_single_R1.fastq.gz"
# ln -sf "$DATA/transcriptomics_data/RNA-Seq_Serum/trimmed/trim_single_ERR1797971_pass_2.fastq.gz"  "$TRIMMED/rna_serum_rep3_single_R2.fastq.gz"

# # tn-seq - trimmed
# ln -sf "$DATA/transcriptomics_data/Tn-Seq_BHI/trim_ERR1801012_pass.fastq.gz"  "$TRIMMED/tnseq_bhi_rep1.fastq.gz"
# ln -sf "$DATA/transcriptomics_data/Tn-Seq_BHI/trim_ERR1801013_pass.fastq.gz"  "$TRIMMED/tnseq_bhi_rep2.fastq.gz"
# ln -sf "$DATA/transcriptomics_data/Tn-Seq_BHI/trim_ERR1801014_pass.fastq.gz"  "$TRIMMED/tnseq_bhi_rep3.fastq.gz"
# ln -sf "$DATA/transcriptomics_data/Tn-Seq_HSerum/trim_ERR1801009_pass.fastq.gz"  "$TRIMMED/tnseq_hserum_rep1.fastq.gz"
# ln -sf "$DATA/transcriptomics_data/Tn-Seq_HSerum/trim_ERR1801010_pass.fastq.gz"  "$TRIMMED/tnseq_hserum_rep2.fastq.gz"
# ln -sf "$DATA/transcriptomics_data/Tn-Seq_HSerum/trim_ERR1801011_pass.fastq.gz"  "$TRIMMED/tnseq_hserum_rep3.fastq.gz"
# ln -sf "$DATA/transcriptomics_data/Tn-Seq_Serum/trim_ERR1801006_pass.fastq.gz"  "$TRIMMED/tnseq_serum_rep1.fastq.gz"
# ln -sf "$DATA/transcriptomics_data/Tn-Seq_Serum/trim_ERR1801007_pass.fastq.gz"  "$TRIMMED/tnseq_serum_rep2.fastq.gz"
# ln -sf "$DATA/transcriptomics_data/Tn-Seq_Serum/trim_ERR1801008_pass.fastq.gz"  "$TRIMMED/tnseq_serum_rep3.fastq.gz"



# check for broken symlinks
BROKEN=$(find "$RAW" -maxdepth 1 -type l ! -e 2>/dev/null | wc -l)
if [[ "$BROKEN" -gt 0 ]]; then
    echo "WARNING: $BROKEN broken symlink(s) found!"
    find "$RAW" -maxdepth 1 -type l ! -e
else
    echo "All symlinks working."
fi
