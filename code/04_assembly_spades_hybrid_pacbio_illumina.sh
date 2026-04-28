#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 1
#SBATCH -t 06:00:00
#SBATCH -J spades_hybrid_assembly_2
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/04_assembly_spades_hybrid.%x.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"

SPADES_HYBRID_ISOLATE_OUT_DIR="${ASSEMBLY_DIR}/spades_hybrid_isolate"
NOBACKUP_SPADES_HYBRID_ISOLATE="${NOBACKUP_BASE}/spades_hybrid_isolate"

# symlink output dir to nobackup
mkdir -p "${ASSEMBLY_DIR}" "${NOBACKUP_SPADES_HYBRID_ISOLATE}"
ensure_nobackup_symlink "${SPADES_HYBRID_ISOLATE_OUT_DIR}" "${NOBACKUP_SPADES_HYBRID_ISOLATE}"
module purge
module load SPAdes/4.2.0-GCC-13.3.0
PACBIO_FILES=("${RAW_DIR}"/${PACBIO_GLOB})
require_file "${ILLUMINA_R1}" "Illumina R1"
require_file "${ILLUMINA_R2}" "Illumina R2"
require_files_in_array PACBIO_FILES "PacBio subreads"
PACBIO_ARGS=()
for pacbio_file in "${PACBIO_FILES[@]}"; do
    PACBIO_ARGS+=(--pacbio "${pacbio_file}")
done
echo "[$(current_time)] SPAdes hybrid assembly (--isolate) started"
echo "[$(current_time)] Illumina: ${ILLUMINA_R1} ${ILLUMINA_R2}"
echo "[$(current_time)] PacBio: ${#PACBIO_FILES[@]} files"
echo "[$(current_time)] output dir: ${SPADES_HYBRID_ISOLATE_OUT_DIR}"
T0=$(date +%s)
# hybrid: illumina+pacbio, isolate mode
spades.py \
    -1 "${ILLUMINA_R1}" \
    -2 "${ILLUMINA_R2}" \
    "${PACBIO_ARGS[@]}" \
    -k 33 \
    --isolate \
    --threads 1 \
    -o "${SPADES_HYBRID_ISOLATE_OUT_DIR}"
echo "[$(current_time)] SPAdes finished ($(elapsed_time $T0))"
echo "[$(current_time)] contigs : ${SPADES_HYBRID_ISOLATE_OUT_DIR}/contigs.fasta"
echo "[$(current_time)] scaffolds: ${SPADES_HYBRID_ISOLATE_OUT_DIR}/scaffolds.fasta"
