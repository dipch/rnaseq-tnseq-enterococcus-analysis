#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 06:00:00
#SBATCH -J trimming_1
#SBATCH --mail-type=ALL
#SBATCH --output=%x.%j.out


set -euo pipefail

elapsed() {
    local secs=$(( $(date +%s) - $1 ))
    printf '%dh %dm %ds' $(( secs/3600 )) $(( (secs%3600)/60 )) $(( secs%60 ))
}


BASE_DIR="${HOME}/rnaseq-tnseq-enterococcus-analysis"
RAW_DIR="${BASE_DIR}/data/raw_data"
TRIMMED_DIR="${BASE_DIR}/data/trimmed_data"

NOBACKUP_TRIMMED="/proj/uppmax2026-1-61/nobackup/work/dich3309/trimmed_data"

# symlink
mkdir -p "${NOBACKUP_TRIMMED}"
if [[ ! -L "${TRIMMED_DIR}" ]]; then
    ln -s "${NOBACKUP_TRIMMED}" "${TRIMMED_DIR}"
fi

module purge
module load Trimmomatic/0.39-Java-17

# TruSeq3-PE.fa
ADAPTERS="${EBROOTTRIMMOMATIC}/adapters/TruSeq3-PE-2.fa"


echo "[$(date '+%H:%M:%S')] trimmomatic started"


for R1 in "${RAW_DIR}"/rna_*_R1.fastq.gz; do
    R2="${R1/_R1.fastq.gz/_R2.fastq.gz}"
    SAMPLE=$(basename "${R1}" _R1.fastq.gz)

    echo "[$(date '+%H:%M:%S')]   trimming ${SAMPLE}..."
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
    echo "[$(date '+%H:%M:%S')]   ${SAMPLE} done ($(elapsed $T0))"
done
echo "[$(date '+%H:%M:%S')] trimmomatic ended"
