#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 4
#SBATCH -t 06:00:00
#SBATCH -J canu_assembly_nanopore_1
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/04_assembly_canu_nanopore.%x.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/paths.sh"
# symlink output dir to nobackup
mkdir -p "${ASSEMBLY_DIR}" "${NOBACKUP_CANU_NANOPORE}"
ensure_nobackup_symlink "${CANU_NANOPORE_OUT_DIR}" "${NOBACKUP_CANU_NANOPORE}"
module purge
module load canu/2.3-GCCcore-13.3.0-Java-17
module load SAMtools/1.22.1-GCC-13.3.0
NANOPORE_FILES=("${RAW_DIR}"/dna_nanopore_*.fasta.gz)
require_files_in_array NANOPORE_FILES "Nanopore"
echo "[$(current_time)] canu assembly started"
echo "[$(current_time)] input: ${#NANOPORE_FILES[@]} Nanopore files"
echo "[$(current_time)] output dir: ${CANU_NANOPORE_OUT_DIR}"
T0=$(date +%s)
# Canu submits its own SLURM sub-jobs via gridOptions and returns immediately.
# Sub-jobs are constrained to 4 cores and 12 h each.
canu \
    -p efaecium_e745_nanopore \
    -d "${CANU_NANOPORE_OUT_DIR}" \
    genomeSize=3.3m \
    maxThreads=4 \
    useGrid=true \
    gridOptions="-A uppmax2026-1-61 -p pelle -c 4 -t 12:00:00" \
    -nanopore \
    "${NANOPORE_FILES[@]}"
echo "[$(current_time)] canu launched ($(elapsed_time $T0))"
echo "[$(current_time)] sub-jobs running independently — monitor with: squeue -u dich3309"
echo "[$(current_time)] assembly complete when efaecium_e745_nanopore.contigs.fasta appears in ${CANU_NANOPORE_OUT_DIR}"
