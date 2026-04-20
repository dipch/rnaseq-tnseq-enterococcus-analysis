#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 1
#SBATCH -t 02:00:00
#SBATCH -J busco_assembly_evaluation
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/07_busco_assembly_evaluation.%x.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"


mkdir -p "${BUSCO_DIR_AUTO_LINEAGE}" "${BUSCO_DIR_MANUAL_LINEAGE}"

module purge
module load BUSCO/5.8.2-gfbf-2024a


run_busco() {
    local label="$1"
    local fa="$2"
    local lineage="$3"   # lineage name or "auto"
    local out_label="${label}_${lineage}"

    check_file "${fa}" "${label}" || return

    echo "[$(current_time)] running BUSCO for ${label} (lineage: ${lineage})"
    local T0=$(date +%s)
    if [[ "${lineage}" == "auto" ]]; then
        busco \
            --in "${fa}" \
            --out "${out_label}" \
            --out_path "${BUSCO_DIR_AUTO_LINEAGE}" \
            --auto-lineage-prok \
            --mode genome \
            --cpu 1 \
            --force
        echo "[$(current_time)] ${out_label} complete ($(elapsed_time $T0))"
        echo "[$(current_time)] results: ${BUSCO_DIR_AUTO_LINEAGE}/${out_label}"
    else
        busco \
            --in "${fa}" \
            --out "${out_label}" \
            --out_path "${BUSCO_DIR_MANUAL_LINEAGE}" \
            --lineage_dataset "${lineage}" \
            --mode genome \
            --cpu 1 \
            --force
        echo "[$(current_time)] ${out_label} complete ($(elapsed_time $T0))"
        echo "[$(current_time)] results: ${BUSCO_DIR_MANUAL_LINEAGE}/${out_label}"
    fi
}

T0=$(date +%s)

# run with manual lineage from config
run_busco "canu_pacbio"      "${CANU_PACBIO_FA}"         "${BUSCO_LINEAGE}"
run_busco "spades_scaffolds" "${SPADES_SCAFFOLDS}" "${BUSCO_LINEAGE}"

# run with auto lineage detection
run_busco "canu_pacbio"      "${CANU_PACBIO_FA}"         "auto"
run_busco "spades_scaffolds" "${SPADES_SCAFFOLDS}" "auto"

echo "[$(current_time)] all BUSCO runs complete (total: $(elapsed_time $T0))"
