#!/bin/bash
# Local (macOS) eggNOG-mapper annotation on Bakta proteins.
#   pixi run bash code/10b_eggnog_functional_annotation_from_bakta_local.sh
#
# Prereqs (one-time):
#   pixi add eggnog-mapper                              # bioconda
#   mkdir -p ${HOME}/eggnog_db
#   pixi run download_eggnog_data.py --data_dir ${HOME}/eggnog_db -y
# Override EGGNOG_DATA_DIR if you put the DB elsewhere.

set -euo pipefail

BASE_DIR="${BASE_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "${BASE_DIR}/utils/config.sh"

EGGNOG_DATA_DIR="${EGGNOG_DATA_DIR:-${HOME}/eggnog_db}"

require_file "${BAKTA_FAA}" "Bakta protein FASTA (.faa)"
require_dir "${EGGNOG_DATA_DIR}" "eggNOG-mapper data dir (set EGGNOG_DATA_DIR if not at default)"

rm -rf "${EGGNOG_BAKTA_DIR:?}"
mkdir -p "${EGGNOG_BAKTA_DIR}"

CPUS="${CPUS:-$(sysctl -n hw.ncpu 2>/dev/null || echo 4)}"

run_emapper() {
    local label="$1"
    local query_faa="$2"
    local outdir="${EGGNOG_BAKTA_DIR}"

    echo "[$(current_time)] running eggNOG-mapper for ${label} (threads=${CPUS})"
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
        --cpu "${CPUS}" \
        --override

    echo "[$(current_time)] eggNOG-mapper ${label} complete ($(elapsed_time $step_start))"
    echo "[$(current_time)] outputs: ${outdir}"
}

total_start=$(date +%s)

run_emapper "bakta_canu_pacbio_pilon_r2" "${BAKTA_FAA}"

echo "[$(current_time)] eggNOG-mapper (Bakta input) complete (total: $(elapsed_time $total_start))"
