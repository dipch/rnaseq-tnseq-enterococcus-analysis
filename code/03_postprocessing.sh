#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 03:00:00
#SBATCH -J qc_post_trimmed_1
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/03_postprocessing.%x.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/paths.sh"
mkdir -p "${FASTQC_TRIMMED_DIR}" "${MULTIQC_TRIMMED_DIR}"
module purge
module load FastQC/0.12.1-Java-17 MultiQC/1.28-foss-2024a
rm -rf "${FASTQC_TRIMMED_DIR:?}"/* "${MULTIQC_TRIMMED_DIR:?}"/*
# fastqc on paired reads only (R1 + R2 per sample)
SAMPLES=("${TRIMMED_DIR}"/*_R1_paired.fastq.gz)
TOTAL=${#SAMPLES[@]}
IDX=0
echo "[$(date '+%Y-%m-%d %H:%M:%S')] fastqc started"
for R1 in "${SAMPLES[@]}"; do
    R2="${R1/_R1_paired.fastq.gz/_R2_paired.fastq.gz}"
    SAMPLE=$(basename "${R1}" _R1_paired.fastq.gz)
    IDX=$((IDX + 1))
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [file ${IDX} of ${TOTAL}]   running fastqc on ${SAMPLE}..."
    T0=$(date +%s)
    fastqc \
        --outdir "${FASTQC_TRIMMED_DIR}" \
        --threads 2 \
        --noextract \
        "${R1}" "${R2}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [file ${IDX} of ${TOTAL}]   ${SAMPLE} done ($(elapsed $T0))"
done
echo "[$(date '+%Y-%m-%d %H:%M:%S')] fastqc ended"
# multiqc
echo "[$(date '+%Y-%m-%d %H:%M:%S')] multiqc started"
T0=$(date +%s)
multiqc \
    "${FASTQC_TRIMMED_DIR}" \
    --outdir "${MULTIQC_TRIMMED_DIR}" \
    --filename "multiqc_trimmed" \
    --title "trimmed data fastqc reports" \
    --force
echo "[$(date '+%Y-%m-%d %H:%M:%S')] multiqc ended ($(elapsed $T0))"
