#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 17:00:00
#SBATCH -J eggnog_functional_annotation_from_bakta
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/10b_eggnog_functional_annotation_from_bakta.%j.out

set -euo pipefail

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"

rm -rf "${EGGNOG_BAKTA_DIR:?}"
mkdir -p "${EGGNOG_BAKTA_DIR}"

module purge
module load eggnog-mapper/2.1.13-gfbf-2024a

require_file "${BAKTA_FAA}" "Bakta protein FASTA (.faa)"
require_dir "${EGGNOG_DATA_DIR}" "eggNOG-mapper data dir"

run_emapper() {
    local label="$1"
    local query_faa="$2"
    local outdir="${EGGNOG_BAKTA_DIR}"

    echo "[$(current_time)] running eggNOG-mapper for ${label}"
    local step_start=$(date +%s)

    emapper.py \
        -i "${query_faa}" \
        --itype proteins \
        -m diamond \
        --tax_scope Bacteria \
        --go_evidence non-electronic \
        --data_dir "${EGGNOG_DATA_DIR}" \
        --output "${EGGNOG_BAKTA_PREFIX}" \
        --output_dir "${outdir}" \
        --temp_dir "${outdir}" \
        --cpu 2 \
        --override

    echo "[$(current_time)] eggNOG-mapper ${label} complete ($(elapsed_time $step_start))"
    echo "[$(current_time)] outputs: ${outdir}"
}

total_start=$(date +%s)

run_emapper "bakta_canu_pacbio_pilon_r2" "${BAKTA_FAA}"

echo "[$(current_time)] eggNOG-mapper (Bakta input) complete (total: $(elapsed_time $total_start))"
