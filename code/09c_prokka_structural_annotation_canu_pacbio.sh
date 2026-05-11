#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 06:00:00
#SBATCH -J 09c_prokka_canu_pacbio
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/09c_prokka_structural_annotation_canu_pacbio.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"

rm -rf "${PROKKA_NP_DIR:?}"
mkdir -p "${PROKKA_NP_DIR}"

module purge
module load prokka/1.14.5-gompi-2024a

require_file "${CANU_PACBIO_FA}" "Canu PacBio assembly (non-polished)"

run_prokka() {
    local label="$1"
    local query_fasta="$2"
    local outdir="${PROKKA_NP_DIR}"

    echo "[$(current_time)] running Prokka for ${label}"
    local step_start=$(date +%s)

    prokka \
        --outdir "${outdir}" \
        --prefix "${PROKKA_NP_PREFIX}" \
        --locustag "${PROKKA_LOCUS_TAG}" \
        --kingdom Bacteria \
        --genus "${PROKKA_GENUS}" \
        --species "${PROKKA_SPECIES}" \
        --strain "${PROKKA_STRAIN}" \
        --gcode 11 \
        --rfam \
        --compliant \
        --cpus 2 \
        --force \
        "${query_fasta}"

    echo "[$(current_time)] Prokka ${label} complete ($(elapsed_time $step_start))"
    echo "[$(current_time)] outputs: ${outdir}"
}

total_start=$(date +%s)

run_prokka "canu_pacbio_nonpolished" "${CANU_PACBIO_FA}"

echo "[$(current_time)] Prokka structural annotation complete (total: $(elapsed_time $total_start))"
