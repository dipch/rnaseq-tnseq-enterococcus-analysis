#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 06:00:00
#SBATCH -J prokka_structural_annotation
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/09_prokka_structural_annotation.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"

rm -rf "${PROKKA_DIR:?}"
mkdir -p "${PROKKA_DIR}"

module purge
module load prokka/1.14.5-gompi-2024a

require_file "${PILON_CANU_PACBIO_R2_FA}" "Canu PacBio Pilon R2 FASTA (best assembly)"

run_prokka() {
    local label="$1"
    local query_fasta="$2"
    local outdir="${PROKKA_DIR}"

    echo "[$(current_time)] running Prokka for ${label}"
    local step_start=$(date +%s)

    # --kingdom Bacteria : bacterial gene models / databases
    # --gcode 11         : bacterial codon table (translation table 11)
    # --rfam             : also annotate ncRNAs via Rfam
    # --compliant        : produce GenBank/ENA/DDJB-compliant output
    # --force            : overwrite existing output directory
    prokka \
        --outdir "${outdir}" \
        --prefix "${PROKKA_PREFIX}" \
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

run_prokka "canu_pacbio_pilon_r2" "${PILON_CANU_PACBIO_R2_FA}"

echo "[$(current_time)] Prokka structural annotation complete (total: $(elapsed_time $total_start))"
