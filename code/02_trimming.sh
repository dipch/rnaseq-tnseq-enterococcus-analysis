#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 08:00:00
#SBATCH -J trimming_2
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/02_trimming.%x.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"
# symlink
mkdir -p "${NOBACKUP_TRIMMED}"
ensure_nobackup_symlink "${TRIMMED_DIR}" "${NOBACKUP_TRIMMED}"
module purge
module load Trimmomatic/0.39-Java-17
# TruSeq3-PE.fa
ADAPTERS="${EBROOTTRIMMOMATIC}/adapters/TruSeq3-PE-2.fa"
SAMPLES=("${RAW_DIR}"/rna_*_R1.fastq.gz)
TOTAL=${#SAMPLES[@]}
file_index=0
echo "[$(current_time)] trimmomatic started"
for R1 in "${SAMPLES[@]}"; do
    R2="${R1/_R1.fastq.gz/_R2.fastq.gz}"
    SAMPLE=$(basename "${R1}" _R1.fastq.gz)
    file_index=$((file_index + 1))
    echo "[$(current_time)] [file ${file_index} of ${TOTAL}]   trimming ${SAMPLE}..."
    T0=$(date +%s)
    # default params for now, will experiment later
    trimmomatic PE \
        "${R1}" "${R2}" \
        "${TRIMMED_DIR}/${SAMPLE}_R1_paired.fastq.gz" "${TRIMMED_DIR}/${SAMPLE}_R1_unpaired.fastq.gz" \
        "${TRIMMED_DIR}/${SAMPLE}_R2_paired.fastq.gz" "${TRIMMED_DIR}/${SAMPLE}_R2_unpaired.fastq.gz" \
        ILLUMINACLIP:"${ADAPTERS}":2:30:10 \
        LEADING:3 \
        TRAILING:3 \
        SLIDINGWINDOW:4:15 \
        MINLEN:36
    echo "[$(current_time)] [file ${file_index} of ${TOTAL}]   ${SAMPLE} done ($(elapsed_time $T0))"
    echo "[$(current_time)] [file ${file_index} of ${TOTAL}]   trimmed_data disk usage: $(du -shL ${TRIMMED_DIR} | cut -f1)"
done
echo "[$(current_time)] trimmomatic ended"
