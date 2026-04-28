#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 12:00:00
#SBATCH -J flye_assembly_pacbio
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/04_assembly_flye_pacbio.%x.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"

mkdir -p "${ASSEMBLY_DIR}" "${NOBACKUP_FLYE_PACBIO}"
ensure_nobackup_symlink "${FLYE_PACBIO_OUT_DIR}" "${NOBACKUP_FLYE_PACBIO}"
rm -rf "${NOBACKUP_FLYE_PACBIO:?}/"*

module purge
module load Flye/2.9.6-GCC-13.3.0

PACBIO_FILES=("${RAW_DIR}"/${PACBIO_GLOB})
require_files_in_array PACBIO_FILES "PacBio subreads"

echo "[$(current_time)] Flye PacBio assembly started"
echo "[$(current_time)] input: ${#PACBIO_FILES[@]} PacBio SMRT cell files"
echo "[$(current_time)] output dir: ${FLYE_PACBIO_OUT_DIR}"
T0=$(date +%s)

flye \
    --pacbio-raw "${PACBIO_FILES[@]}" \
    --genome-size "${GENOME_SIZE}" \
    --threads 2 \
    --out-dir "${FLYE_PACBIO_OUT_DIR}"

echo "[$(current_time)] Flye finished ($(elapsed_time $T0))"
echo "[$(current_time)] assembly: ${FLYE_PACBIO_FA}"
