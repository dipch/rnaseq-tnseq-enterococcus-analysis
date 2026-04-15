#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 01:00:00
#SBATCH -J qc_raw_2
#SBATCH --mail-type=ALL
#SBATCH --output=%x.%j.out


set -euo pipefail

elapsed() {
    local secs=$(( $(date +%s) - $1 ))
    printf '%dh %dm %ds' $(( secs/3600 )) $(( (secs%3600)/60 )) $(( secs%60 ))
}


BASE_DIR="${HOME}/rnaseq-tnseq-enterococcus-analysis"
RAW_DIR="${BASE_DIR}/data/raw_data"

FASTQC_OUTPUT_DIR_RAW="${BASE_DIR}/analyses/01_preprocessing/fastqc_raw"
MULTIQC_OUTPUT_DIR_RAW="${BASE_DIR}/analyses/01_preprocessing/multiqc_raw"

mkdir -p "${FASTQC_OUTPUT_DIR_RAW}" "${MULTIQC_OUTPUT_DIR_RAW}"

module purge
module load FastQC/0.12.1-Java-17 MultiQC/1.28-foss-2024a


if [[ ! -d "${RAW_DIR}" ]] || [[ -z "$(ls "${RAW_DIR}")" ]]; then
    echo "ERROR: No files found in ${RAW_DIR}"
    exit 1
fi

rm -rf "${FASTQC_OUTPUT_DIR_RAW:?}"/* "${MULTIQC_OUTPUT_DIR_RAW:?}"/*


# fastqc — FASTQ  (Illumina + PacBio)
echo "[$(date '+%H:%M:%S')] fastqc started"
T0=$(date +%s)
fastqc \
    --outdir "${FASTQC_OUTPUT_DIR_RAW}" \
    --threads 2 \
    --noextract \
    "${RAW_DIR}"/*.fastq.gz "${RAW_DIR}"/*.fq.gz
echo "[$(date '+%H:%M:%S')] fastqc ended ($(elapsed $T0))"

# fastqc — Nanopore FASTA
echo "[$(date '+%H:%M:%S')] fastqc nanopore started"
fastqc \
    --outdir "${FASTQC_OUTPUT_DIR_RAW}" \
    --format fasta \
    --noextract \
    "${RAW_DIR}"/*.fasta.gz
echo "[$(date '+%H:%M:%S')] fastqc nanopore ended"

# multiqc
echo "[$(date '+%H:%M:%S')] multiqc started"
T0=$(date +%s)
multiqc \
    "${FASTQC_OUTPUT_DIR_RAW}" \
    --outdir "${MULTIQC_OUTPUT_DIR_RAW}" \
    --filename "multiqc_raw" \
    --title "raw data fastqc reports" \
    --force
echo "[$(date '+%H:%M:%S')] multiqc ended ($(elapsed $T0))"
