#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 03:00:00
#SBATCH -J qc_post_trimmed_1
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/03_postprocessing.%x.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"
rm -rf "${FASTQC_TRIMMED_DIR:?}" "${MULTIQC_TRIMMED_DIR:?}"
mkdir -p "${FASTQC_TRIMMED_DIR}" "${MULTIQC_TRIMMED_DIR}"
module purge
module load FastQC/0.12.1-Java-17 MultiQC/1.28-foss-2024a
# fastqc on paired reads only (R1 + R2 per sample)
SAMPLES=("${TRIMMED_DIR}"/*_R1_paired.fastq.gz)
TOTAL=${#SAMPLES[@]}
file_index=0
echo "[$(current_time)] fastqc started"
for R1 in "${SAMPLES[@]}"; do
    R2="${R1/_R1_paired.fastq.gz/_R2_paired.fastq.gz}"
    SAMPLE=$(basename "${R1}" _R1_paired.fastq.gz)
    file_index=$((file_index + 1))
    echo "[$(current_time)] [file ${file_index} of ${TOTAL}]   running fastqc on ${SAMPLE}..."
    T0=$(date +%s)
    fastqc \
        --outdir "${FASTQC_TRIMMED_DIR}" \
        --threads 2 \
        --noextract \
        "${R1}" "${R2}"
    echo "[$(current_time)] [file ${file_index} of ${TOTAL}]   ${SAMPLE} done ($(elapsed_time $T0))"
done
echo "[$(current_time)] fastqc ended"
# multiqc
echo "[$(current_time)] multiqc started"
T0=$(date +%s)
multiqc \
    "${FASTQC_TRIMMED_DIR}" \
    --outdir "${MULTIQC_TRIMMED_DIR}" \
    --filename "multiqc_trimmed" \
    --title "trimmed data fastqc reports" \
    --force
echo "[$(current_time)] multiqc ended ($(elapsed_time $T0))"
