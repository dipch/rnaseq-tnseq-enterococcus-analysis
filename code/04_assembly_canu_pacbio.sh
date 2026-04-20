#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 4
#SBATCH -t 06:00:00
#SBATCH -J canu_assembly_pacbio_1
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/04_assembly_canu.%x.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"
# symlink output dir to nobackup
mkdir -p "${ASSEMBLY_DIR}" "${NOBACKUP_CANU_PACBIO}"
ensure_nobackup_symlink "${CANU_PACBIO_OUT_DIR}" "${NOBACKUP_CANU_PACBIO}"
module purge
module load canu/2.3-GCCcore-13.3.0-Java-17
module load SAMtools/1.22.1-GCC-13.3.0
PACBIO_FILES=("${RAW_DIR}"/${PACBIO_GLOB})
require_files_in_array PACBIO_FILES "PacBio subreads"
echo "[$(current_time)] canu assembly started"
echo "[$(current_time)] input: ${#PACBIO_FILES[@]} PacBio SMRT cell files"
echo "[$(current_time)] output dir: ${CANU_PACBIO_OUT_DIR}"
T0=$(date +%s)
# Canu submits its own SLURM sub-jobs via gridOptions and returns immediately.
# Sub-jobs are constrained to 4 cores and 12 h each.
canu \
    -p "${ORGANISM}_pacbio" \
    -d "${CANU_PACBIO_OUT_DIR}" \
    genomeSize=${GENOME_SIZE} \
    maxThreads=4 \
    useGrid=true \
    gridOptions="-A uppmax2026-1-61 -p pelle -c 4 -t 12:00:00" \
    -pacbio \
    "${PACBIO_FILES[@]}"
echo "[$(current_time)] canu launched ($(elapsed_time $T0))"
echo "[$(current_time)] sub-jobs running independently — monitor with: squeue -u dich3309"
echo "[$(current_time)] assembly complete when ${ORGANISM}_pacbio.contigs.fasta appears in ${CANU_PACBIO_OUT_DIR}"
