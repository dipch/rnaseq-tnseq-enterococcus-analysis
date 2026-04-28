#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 1
#SBATCH -t 06:00:00
#SBATCH -J spades_illumina_assembly
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/04_assembly_spades_illumina.%x.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"

mkdir -p "${ASSEMBLY_DIR}" "${NOBACKUP_SPADES_ILLUMINA}"
ensure_nobackup_symlink "${SPADES_ILLUMINA_OUT_DIR}" "${NOBACKUP_SPADES_ILLUMINA}"

module purge
module load SPAdes/4.2.0-GCC-13.3.0

require_file "${ILLUMINA_R1}" "Illumina R1"
require_file "${ILLUMINA_R2}" "Illumina R2"

echo "[$(current_time)] SPAdes Illumina-only assembly (--isolate) started"
echo "[$(current_time)] Illumina R1: ${ILLUMINA_R1}"
echo "[$(current_time)] Illumina R2: ${ILLUMINA_R2}"
echo "[$(current_time)] output dir:  ${SPADES_ILLUMINA_OUT_DIR}"
T0=$(date +%s)

spades.py \
    -1 "${ILLUMINA_R1}" \
    -2 "${ILLUMINA_R2}" \
    --isolate \
    --threads 1 \
    -o "${SPADES_ILLUMINA_OUT_DIR}"

echo "[$(current_time)] SPAdes finished ($(elapsed_time $T0))"
echo "[$(current_time)] contigs:  ${SPADES_ILLUMINA_CONTIGS}"
echo "[$(current_time)] scaffolds: ${SPADES_ILLUMINA_SCAFFOLDS}"
