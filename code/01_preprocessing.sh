#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 01:00:00
#SBATCH -J qc_raw_3
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/logs/01_preprocessing.%x.%j.out


set -euo pipefail

trap 'echo "[$(date +%H:%M:%S)] ERROR: script exited unexpectedly (exit code $?, line ${LINENO})"' ERR
trap 'echo "[$(date +%H:%M:%S)] script finished (exit code $?)"' EXIT

BASE_DIR="${HOME}/rnaseq-tnseq-enterococcus-analysis"

source "${BASE_DIR}/utils/calculate_elapsed_time.sh"
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
