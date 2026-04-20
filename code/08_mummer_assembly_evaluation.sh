#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 1
#SBATCH -t 02:00:00
#SBATCH -J mummer_assembly_evaluation
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/08_mummer_assembly_evaluation.%x.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"

mkdir -p "${MUMMER_DIR}"

module purge
module load MUMmer/4.0.1-GCCcore-13.3.0

require_file "${REFERENCE_FA}"      "reference genome FASTA"
require_file "${CANU_PACBIO_FA}"    "Canu PacBio assembly FASTA"
require_file "${SPADES_SCAFFOLDS}"  "SPAdes scaffolds FASTA"

run_mummer() {
    local label="$1"
    local fa="$2"
    local outdir="${MUMMER_DIR}/${label}"

    mkdir -p "${outdir}"
    local prefix="${outdir}/${label}"

    echo "[$(current_time)] running nucmer for ${label}"
    local T_step=$(date +%s)
    nucmer \
        --threads 1 \
        --prefix "${prefix}" \
        "${REFERENCE_FA}" \
        "${fa}"
    echo "[$(current_time)] nucmer ${label} complete ($(elapsed_time $T_step))"

    echo "[$(current_time)] filtering delta for ${label}"
    delta-filter -r -q "${prefix}.delta" > "${prefix}.filter.delta"

    echo "[$(current_time)] running dnadiff for ${label}"
    T_step=$(date +%s)
    dnadiff \
        -p "${prefix}_dnadiff" \
        -d "${prefix}.delta"
    echo "[$(current_time)] dnadiff ${label} complete ($(elapsed_time $T_step))"

    echo "[$(current_time)] generating mummerplot for ${label}"
    T_step=$(date +%s)
    mummerplot \
        --png \
        -R "${REFERENCE_FA}" \
        -Q "${fa}" \
        --prefix "${prefix}_plot" \
        "${prefix}.filter.delta"
    echo "[$(current_time)] mummerplot ${label} complete ($(elapsed_time $T_step))"
    echo "[$(current_time)] outputs: ${outdir}"
}

T0=$(date +%s)

run_mummer "canu_pacbio"      "${CANU_PACBIO_FA}"
run_mummer "spades_scaffolds" "${SPADES_SCAFFOLDS}"

echo "[$(current_time)] all MUMmer runs complete (total: $(elapsed_time $T0))"
