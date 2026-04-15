#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 4
#SBATCH -t 06:00:00
#SBATCH -J canu_assembly_pacbio_1
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/04_assembly_canu.%x.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/paths.sh"
# symlink output dir to nobackup
mkdir -p "${ASSEMBLY_DIR}" "${NOBACKUP_CANU_PACBIO}"
ensure_nobackup_symlink "${CANU_PACBIO_OUT_DIR}" "${NOBACKUP_CANU_PACBIO}"
module purge
module load canu/2.3-GCCcore-13.3.0-Java-17
module load SAMtools/1.22.1-GCC-13.3.0
PACBIO_FILES=("${RAW_DIR}"/dna_pacbio_*.subreads.fastq.gz)
if [[ ${#PACBIO_FILES[@]} -eq 0 ]]; then
    echo "ERROR: no PacBio subreads files found in ${RAW_DIR}"
    exit 1
fi
echo "[$(date '+%Y-%m-%d %H:%M:%S')] canu assembly started"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] input: ${#PACBIO_FILES[@]} PacBio SMRT cell files"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] output dir: ${CANU_PACBIO_OUT_DIR}"
T0=$(date +%s)
# Canu submits its own SLURM sub-jobs via gridOptions and returns immediately.
# Sub-jobs are constrained to 2 cores and 12 h each.
canu \
    -p efaecium_e745_pacbio \
    -d "${CANU_PACBIO_OUT_DIR}" \
    genomeSize=3.3m \
    maxThreads=4 \
    useGrid=true \
    gridOptions="-A uppmax2026-1-61 -p pelle -c 4 -t 12:00:00" \
    -pacbio \
    "${PACBIO_FILES[@]}"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] canu launched ($(elapsed $T0))"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] sub-jobs running independently — monitor with: squeue -u dich3309"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] assembly complete when efaecium_e745_pacbio.contigs.fasta appears in ${CANU_PACBIO_OUT_DIR}"
