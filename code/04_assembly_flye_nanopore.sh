#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 12:00:00
#SBATCH -J flye_assembly_nanopore
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/04_assembly_flye_nanopore.%x.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"

mkdir -p "${ASSEMBLY_DIR}" "${NOBACKUP_FLYE_NANOPORE}"
ensure_nobackup_symlink "${FLYE_NANOPORE_OUT_DIR}" "${NOBACKUP_FLYE_NANOPORE}"
rm -rf "${NOBACKUP_FLYE_NANOPORE:?}/"*

module purge
module load Flye/2.9.6-GCC-13.3.0

NANOPORE_FILES=("${RAW_DIR}"/${NANOPORE_GLOB})
require_files_in_array NANOPORE_FILES "Nanopore"

echo "[$(current_time)] Flye Nanopore assembly started"
echo "[$(current_time)] input: ${#NANOPORE_FILES[@]} Nanopore files"
echo "[$(current_time)] output dir: ${FLYE_NANOPORE_OUT_DIR}"
T0=$(date +%s)

flye \
    --nano-raw "${NANOPORE_FILES[@]}" \
    --genome-size "${GENOME_SIZE}" \
    --threads 2 \
    --out-dir "${FLYE_NANOPORE_OUT_DIR}"

echo "[$(current_time)] Flye finished ($(elapsed_time $T0))"
echo "[$(current_time)] assembly: ${FLYE_NANOPORE_FA}"
