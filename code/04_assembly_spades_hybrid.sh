#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 4
#SBATCH -t 08:00:00
#SBATCH -J spades_hybrid_assembly_2
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/04_assembly_spades_hybrid.%x.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/paths.sh"
# symlink output dir to nobackup
mkdir -p "${ASSEMBLY_DIR}" "${NOBACKUP_SPADES_HYBRID}"
ensure_nobackup_symlink "${SPADES_HYBRID_OUT_DIR}" "${NOBACKUP_SPADES_HYBRID}"
module purge
module load SPAdes/4.2.0-GCC-13.3.0
ILLUMINA_R1="${RAW_DIR}/dna_illumina_R1.fq.gz"
ILLUMINA_R2="${RAW_DIR}/dna_illumina_R2.fq.gz"
PACBIO_FILES=("${RAW_DIR}"/dna_pacbio_*.subreads.fastq.gz)
[[ -f "${ILLUMINA_R1}" ]] || {
    echo "ERROR: Illumina R1 not found: ${ILLUMINA_R1}"
    exit 1
}
[[ -f "${ILLUMINA_R2}" ]] || {
    echo "ERROR: Illumina R2 not found: ${ILLUMINA_R2}"
    exit 1
}
if [[ ${#PACBIO_FILES[@]} -eq 0 ]]; then
    echo "ERROR: no PacBio subreads files found in ${RAW_DIR}"
    exit 1
fi
PACBIO_ARGS=()
for f in "${PACBIO_FILES[@]}"; do
    PACBIO_ARGS+=(--pacbio "${f}")
done
echo "[$(date '+%Y-%m-%d %H:%M:%S')] SPAdes hybrid assembly started"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Illumina: ${ILLUMINA_R1} ${ILLUMINA_R2}"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] PacBio: ${#PACBIO_FILES[@]} files"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] output dir: ${SPADES_HYBRID_OUT_DIR}"
T0=$(date +%s)
# hybrid: illumina+pacbio
spades.py \
    -1 "${ILLUMINA_R1}" \
    -2 "${ILLUMINA_R2}" \
    "${PACBIO_ARGS[@]}" \
    -k 33 \
    --threads 4 \
    -o "${SPADES_HYBRID_OUT_DIR}"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] SPAdes finished ($(elapsed $T0))"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] contigs : ${SPADES_HYBRID_OUT_DIR}/contigs.fasta"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] scaffolds: ${SPADES_HYBRID_OUT_DIR}/scaffolds.fasta"
