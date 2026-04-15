#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 4
#SBATCH -t 06:00:00
#SBATCH -J canu_assembly_nanopore_1
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/04_assembly_canu_nanopore.%x.%j.out


set -euo pipefail

trap 'echo "[$(date "+%Y-%m-%d %H:%M:%S")] ERROR: script exited unexpectedly (exit code $?, line ${LINENO})"' ERR
trap 'echo "[$(date "+%Y-%m-%d %H:%M:%S")] script finished (exit code $?)"' EXIT

BASE_DIR="${HOME}/rnaseq-tnseq-enterococcus-analysis"

source "${BASE_DIR}/utils/calculate_elapsed_time.sh"
RAW_DIR="${BASE_DIR}/data/raw_data"
CANU_NANOPORE_OUT_DIR="${BASE_DIR}/analyses/02_genome_assembly/canu_nanopore"

NOBACKUP_CANU="/proj/uppmax2026-1-61/nobackup/work/dich3309/canu_nanopore"

# symlink output dir to nobackup
mkdir -p "${BASE_DIR}/analyses/02_genome_assembly" "${NOBACKUP_CANU}"
if [[ -d "${CANU_NANOPORE_OUT_DIR}" && ! -L "${CANU_NANOPORE_OUT_DIR}" ]]; then
    rmdir "${CANU_NANOPORE_OUT_DIR}" 2>/dev/null || { echo "ERROR: ${CANU_NANOPORE_OUT_DIR} exists as a non-empty directory, cannot replace with symlink"; exit 1; }
fi
if [[ ! -L "${CANU_NANOPORE_OUT_DIR}" ]]; then
    ln -s "${NOBACKUP_CANU}" "${CANU_NANOPORE_OUT_DIR}"
fi

module purge
module load canu/2.3-GCCcore-13.3.0-Java-17
module load SAMtools/1.22.1-GCC-13.3.0

NANOPORE_FILES=("${RAW_DIR}"/dna_nanopore_*.fasta.gz)
if [[ ${#NANOPORE_FILES[@]} -eq 0 ]]; then
    echo "ERROR: no Nanopore files found in ${RAW_DIR}"
    exit 1
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] canu assembly started"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] input: ${#NANOPORE_FILES[@]} Nanopore files"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] output dir: ${CANU_NANOPORE_OUT_DIR}"
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

echo "[$(date '+%Y-%m-%d %H:%M:%S')] canu launched ($(elapsed $T0))"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] sub-jobs running independently — monitor with: squeue -u dich3309"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] assembly complete when efaecium_e745_nanopore.contigs.fasta appears in ${CANU_NANOPORE_OUT_DIR}"
