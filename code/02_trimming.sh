#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 08:00:00
#SBATCH -J trimming_2
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/02_trimming.%x.%j.out



set -euo pipefail

trap 'echo "[$(date +%Y-%m-%d %H:%M:%S)] ERROR: script exited unexpectedly (exit code $?, line ${LINENO})"' ERR
trap 'echo "[$(date +%Y-%m-%d %H:%M:%S)] script finished (exit code $?)"' EXIT

BASE_DIR="${HOME}/rnaseq-tnseq-enterococcus-analysis"

source "${BASE_DIR}/utils/calculate_elapsed_time.sh"
RAW_DIR="${BASE_DIR}/data/raw_data"
TRIMMED_DIR="${BASE_DIR}/data/trimmed_data"

NOBACKUP_TRIMMED="/proj/uppmax2026-1-61/nobackup/work/dich3309/trimmed_data"

# symlink
mkdir -p "${NOBACKUP_TRIMMED}"
if [[ -d "${TRIMMED_DIR}" && ! -L "${TRIMMED_DIR}" ]]; then
    rmdir "${TRIMMED_DIR}" 2>/dev/null || { echo "ERROR: ${TRIMMED_DIR} exists as a non-empty directory, cannot replace with symlink"; exit 1; }
fi
if [[ ! -L "${TRIMMED_DIR}" ]]; then
    ln -s "${NOBACKUP_TRIMMED}" "${TRIMMED_DIR}"
fi

module purge
module load Trimmomatic/0.39-Java-17

# TruSeq3-PE.fa
ADAPTERS="${EBROOTTRIMMOMATIC}/adapters/TruSeq3-PE-2.fa"


SAMPLES=("${RAW_DIR}"/rna_*_R1.fastq.gz)
TOTAL=${#SAMPLES[@]}
IDX=0

echo "[$(date '+%Y-%m-%d %H:%M:%S')] trimmomatic started"


for R1 in "${SAMPLES[@]}"; do
    R2="${R1/_R1.fastq.gz/_R2.fastq.gz}"
    SAMPLE=$(basename "${R1}" _R1.fastq.gz)
    IDX=$(( IDX + 1 ))

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [file ${IDX} of ${TOTAL}]   trimming ${SAMPLE}..."
    T0=$(date +%s)

    # default params for now, will experiment later
    trimmomatic PE \
        "${R1}" "${R2}" \
        "${TRIMMED_DIR}/${SAMPLE}_R1_paired.fastq.gz"   "${TRIMMED_DIR}/${SAMPLE}_R1_unpaired.fastq.gz" \
        "${TRIMMED_DIR}/${SAMPLE}_R2_paired.fastq.gz"   "${TRIMMED_DIR}/${SAMPLE}_R2_unpaired.fastq.gz" \
        ILLUMINACLIP:"${ADAPTERS}":2:30:10 \
        LEADING:3 \
        TRAILING:3 \
        SLIDINGWINDOW:4:15 \
        MINLEN:36
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [file ${IDX} of ${TOTAL}]   ${SAMPLE} done ($(elapsed $T0))"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [file ${IDX} of ${TOTAL}]   trimmed_data disk usage: $(du -shL ${TRIMMED_DIR} | cut -f1)"
done
echo "[$(date '+%Y-%m-%d %H:%M:%S')] trimmomatic ended"
