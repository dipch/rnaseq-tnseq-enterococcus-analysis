#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 01:00:00
#SBATCH -J qc_raw_3
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/01_preprocessing.%x.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/paths.sh"

mkdir -p "${FASTQC_RAW_DIR}" "${MULTIQC_RAW_DIR}"
module purge
module load FastQC/0.12.1-Java-17 MultiQC/1.28-foss-2024a
require_dir_nonempty "${RAW_DIR}" "raw data directory"
rm -rf "${FASTQC_RAW_DIR:?}"/* "${MULTIQC_RAW_DIR:?}"/*
# fastqc — FASTQ (Illumina + PacBio)
echo "[$(current_time)] fastqc started"
T0=$(date +%s)
fastqc \
    --outdir "${FASTQC_RAW_DIR}" \
    --threads 2 \
    --noextract \
    "${RAW_DIR}"/*.fastq.gz "${RAW_DIR}"/*.fq.gz
echo "[$(current_time)] fastqc ended ($(elapsed_time $T0))"
# multiqc
echo "[$(current_time)] multiqc started"
T0=$(date +%s)
multiqc \
    "${FASTQC_RAW_DIR}" \
    --outdir "${MULTIQC_RAW_DIR}" \
    --filename "multiqc_raw" \
    --title "raw data fastqc reports" \
    --force
echo "[$(current_time)] multiqc ended ($(elapsed_time $T0))"
