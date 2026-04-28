#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 06:00:00
#SBATCH -J spades_hybrid_nanopore_illumina_assembly
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/04_assembly_spades_hybrid_nanopore_illumina.%x.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"

mkdir -p "${ASSEMBLY_DIR}" "${NOBACKUP_SPADES_HYBRID_NANOPORE}"
ensure_nobackup_symlink "${SPADES_HYBRID_NANOPORE_OUT_DIR}" "${NOBACKUP_SPADES_HYBRID_NANOPORE}"

module purge
module load SPAdes/4.2.0-GCC-13.3.0

NANOPORE_FILES=("${RAW_DIR}"/${NANOPORE_GLOB})
require_file "${ILLUMINA_R1}" "Illumina R1"
require_file "${ILLUMINA_R2}" "Illumina R2"
require_files_in_array NANOPORE_FILES "Nanopore"

NANOPORE_ARGS=()
for nanopore_file in "${NANOPORE_FILES[@]}"; do
    NANOPORE_ARGS+=(--nanopore "${nanopore_file}")
done

echo "[$(current_time)] SPAdes hybrid assembly (Illumina + Nanopore) started"
echo "[$(current_time)] Illumina R1:  ${ILLUMINA_R1}"
echo "[$(current_time)] Illumina R2:  ${ILLUMINA_R2}"
echo "[$(current_time)] Nanopore: ${#NANOPORE_FILES[@]} files"
echo "[$(current_time)] output dir:   ${SPADES_HYBRID_NANOPORE_OUT_DIR}"
T0=$(date +%s)

spades.py \
    -1 "${ILLUMINA_R1}" \
    -2 "${ILLUMINA_R2}" \
    "${NANOPORE_ARGS[@]}" \
    --threads 2 \
    -o "${SPADES_HYBRID_NANOPORE_OUT_DIR}"

echo "[$(current_time)] SPAdes finished ($(elapsed_time $T0))"
echo "[$(current_time)] contigs:   ${SPADES_HYBRID_NANOPORE_CONTIGS}"
echo "[$(current_time)] scaffolds: ${SPADES_HYBRID_NANOPORE_SCAFFOLDS}"
