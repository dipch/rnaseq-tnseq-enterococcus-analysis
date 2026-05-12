#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 17:00:00
#SBATCH -J eggnog_functional_annotation
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/10_eggnog_functional_annotation.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"

rm -rf "${EGGNOG_DIR:?}"
mkdir -p "${EGGNOG_DIR}"

module purge
module load eggnog-mapper/2.1.13-gfbf-2024a

require_file "${PROKKA_FAA}" "Prokka protein FASTA (.faa)"
require_dir "${EGGNOG_DATA_DIR}" "eggNOG-mapper data dir"

run_emapper() {
    local label="$1"
    local query_faa="$2"
    local outdir="${EGGNOG_DIR}"

    echo "[$(current_time)] running eggNOG-mapper for ${label}"
    local step_start=$(date +%s)


    emapper.py \
        -i "${query_faa}" \
        --itype proteins \
        -m diamond \
        --tax_scope Bacteria \
        --go_evidence non-electronic \
        --data_dir "${EGGNOG_DATA_DIR}" \
        --output "${EGGNOG_PREFIX}" \
        --output_dir "${outdir}" \
        --temp_dir "${outdir}" \
        --cpu 2 \
        --override

    echo "[$(current_time)] eggNOG-mapper ${label} complete ($(elapsed_time $step_start))"
    echo "[$(current_time)] outputs: ${outdir}"
}

total_start=$(date +%s)

run_emapper "canu_pacbio_pilon_r2" "${PROKKA_FAA}"

echo "[$(current_time)] eggNOG-mapper functional annotation complete (total: $(elapsed_time $total_start))"
