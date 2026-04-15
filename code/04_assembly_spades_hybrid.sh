#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 4
#SBATCH -t 08:00:00
#SBATCH -J spades_hybrid_assembly_2
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/04_assembly_spades_hybrid.%x.%j.out


set -euo pipefail

trap 'echo "[$(date "+%Y-%m-%d %H:%M:%S")] ERROR: script exited unexpectedly (exit code $?, line ${LINENO})"' ERR
trap 'echo "[$(date "+%Y-%m-%d %H:%M:%S")] script finished (exit code $?)"' EXIT

BASE_DIR="${HOME}/rnaseq-tnseq-enterococcus-analysis"

source "${BASE_DIR}/utils/calculate_elapsed_time.sh"
RAW_DIR="${BASE_DIR}/data/raw_data"
SPADES_OUT_DIR="${BASE_DIR}/analyses/02_genome_assembly/spades_hybrid"

NOBACKUP_SPADES="/proj/uppmax2026-1-61/nobackup/work/dich3309/spades_hybrid"

# symlink output dir to nobackup
mkdir -p "${BASE_DIR}/analyses/02_genome_assembly" "${NOBACKUP_SPADES}"
if [[ -d "${SPADES_OUT_DIR}" && ! -L "${SPADES_OUT_DIR}" ]]; then
    rmdir "${SPADES_OUT_DIR}" 2>/dev/null || { echo "ERROR: ${SPADES_OUT_DIR} exists as a non-empty directory, cannot replace with symlink"; exit 1; }
fi
if [[ ! -L "${SPADES_OUT_DIR}" ]]; then
    ln -s "${NOBACKUP_SPADES}" "${SPADES_OUT_DIR}"
fi

module purge
module load SPAdes/4.2.0-GCC-13.3.0

ILLUMINA_R1="${RAW_DIR}/dna_illumina_R1.fq.gz"
ILLUMINA_R2="${RAW_DIR}/dna_illumina_R2.fq.gz"
PACBIO_FILES=("${RAW_DIR}"/dna_pacbio_*.subreads.fastq.gz)

[[ -f "${ILLUMINA_R1}" ]] || { echo "ERROR: Illumina R1 not found: ${ILLUMINA_R1}"; exit 1; }
[[ -f "${ILLUMINA_R2}" ]] || { echo "ERROR: Illumina R2 not found: ${ILLUMINA_R2}"; exit 1; }
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
echo "[$(date '+%Y-%m-%d %H:%M:%S')] output dir: ${SPADES_OUT_DIR}"
T0=$(date +%s)


# hybrid: illumina+pacbio
spades.py \
    -1 "${ILLUMINA_R1}" \
    -2 "${ILLUMINA_R2}" \
    "${PACBIO_ARGS[@]}" \
    -k 33 \
    --threads 4 \
    -o "${SPADES_OUT_DIR}"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] SPAdes finished ($(elapsed $T0))"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] contigs : ${SPADES_OUT_DIR}/contigs.fasta"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] scaffolds: ${SPADES_OUT_DIR}/scaffolds.fasta"
