#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 1
#SBATCH -t 02:00:00
#SBATCH -J busco_assembly_evaluation
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/07_busco_assembly_evaluation.%x.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"


rm -rf "${BUSCO_DIR_AUTO_LINEAGE:?}" "${BUSCO_DIR_MANUAL_LINEAGE:?}"
mkdir -p "${BUSCO_DIR_AUTO_LINEAGE}" "${BUSCO_DIR_MANUAL_LINEAGE}"

module purge
module load BUSCO/5.8.2-gfbf-2024a

require_file "${CANU_PACBIO_FA}"   "Canu PacBio assembly FASTA"
require_file "${SPADES_SCAFFOLDS}" "SPAdes scaffolds FASTA"
require_file "${SPADES_SCAFFOLDS_ISOLATE}" "SPAdes scaffolds FASTA (isolate)"

run_busco() {
    local label="$1"
    local query_fasta="$2"
    local lineage="$3"   # lineage name or "auto"
    local out_label="${label}_${lineage}"

    echo "[$(current_time)] running BUSCO for ${label} (lineage: ${lineage})"
    local step_start=$(date +%s)
    if [[ "${lineage}" == "auto" ]]; then
        busco \
            --in "${query_fasta}" \
            --out "${out_label}" \
            --out_path "${BUSCO_DIR_AUTO_LINEAGE}" \
            --auto-lineage-prok \
            --mode genome \
            --cpu 1 \
            --force
        echo "[$(current_time)] ${out_label} complete ($(elapsed_time $step_start))"
        echo "[$(current_time)] results: ${BUSCO_DIR_AUTO_LINEAGE}/${out_label}"
    else
        busco \
            --in "${query_fasta}" \
            --out "${out_label}" \
            --out_path "${BUSCO_DIR_MANUAL_LINEAGE}" \
            --lineage_dataset "${lineage}" \
            --mode genome \
            --cpu 1 \
            --force
        echo "[$(current_time)] ${out_label} complete ($(elapsed_time $step_start))"
        echo "[$(current_time)] results: ${BUSCO_DIR_MANUAL_LINEAGE}/${out_label}"
    fi
}

total_start=$(date +%s)

# run with manual lineage from config
run_busco "canu_pacbio"      "${CANU_PACBIO_FA}"         "${BUSCO_LINEAGE}"
run_busco "spades_scaffolds" "${SPADES_SCAFFOLDS}" "${BUSCO_LINEAGE}"

# run with auto lineage detection
run_busco "canu_pacbio"      "${CANU_PACBIO_FA}"         "auto"
run_busco "spades_scaffolds" "${SPADES_SCAFFOLDS}" "auto"

#temp
run_busco "spades_scaffolds_isolate" "${SPADES_SCAFFOLDS_ISOLATE}" "${BUSCO_LINEAGE}"
run_busco "spades_scaffolds_isolate" "${SPADES_SCAFFOLDS_ISOLATE}" "auto"

echo "[$(current_time)] all BUSCO runs complete (total: $(elapsed_time $total_start))"
