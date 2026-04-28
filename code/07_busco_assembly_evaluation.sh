#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 1
#SBATCH -t 06:00:00
#SBATCH -J busco_assembly_evaluation
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/07_busco_assembly_evaluation.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"

rm -rf "${BUSCO_DIR_AUTO_LINEAGE:?}" "${BUSCO_DIR_MANUAL_LINEAGE:?}"
mkdir -p "${BUSCO_DIR_AUTO_LINEAGE}" "${BUSCO_DIR_MANUAL_LINEAGE}"

module purge
module load BUSCO/5.8.2-gfbf-2024a

require_file "${CANU_PACBIO_FA}"                                  "Canu PacBio assembly FASTA"
require_file "${CANU_NANOPORE_FA}"                                "Canu Nanopore assembly FASTA"
require_file "${SPADES_HYBRID_PACBIO_ILLUMINA_SCAFFOLDS}"         "SPAdes scaffolds (PacBio+Illumina hybrid) FASTA"
require_file "${SPADES_HYBRID_PACBIO_ILLUMINA_ISOLATE_SCAFFOLDS}" "SPAdes scaffolds (PacBio+Illumina isolate) FASTA"
require_file "${SPADES_ILLUMINA_SCAFFOLDS}"                       "SPAdes scaffolds (Illumina-only) FASTA"
require_file "${SPADES_HYBRID_NANOPORE_SCAFFOLDS}"                "SPAdes scaffolds (Nanopore+Illumina hybrid) FASTA"
require_file "${FLYE_PACBIO_FA}"                                  "Flye PacBio assembly FASTA"
require_file "${FLYE_NANOPORE_FA}"                                "Flye Nanopore assembly FASTA"

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

echo "[$(current_time)] running BUSCO with manual lineage (${BUSCO_LINEAGE})"
run_busco "canu_pacbio"                              "${CANU_PACBIO_FA}"                                  "${BUSCO_LINEAGE}"
run_busco "canu_nanopore"                            "${CANU_NANOPORE_FA}"                                "${BUSCO_LINEAGE}"
run_busco "spades_scaffolds_pacbio_illumina"         "${SPADES_HYBRID_PACBIO_ILLUMINA_SCAFFOLDS}"         "${BUSCO_LINEAGE}"
run_busco "spades_scaffolds_pacbio_illumina_isolate" "${SPADES_HYBRID_PACBIO_ILLUMINA_ISOLATE_SCAFFOLDS}" "${BUSCO_LINEAGE}"
run_busco "spades_scaffolds_illumina"                "${SPADES_ILLUMINA_SCAFFOLDS}"                       "${BUSCO_LINEAGE}"
run_busco "spades_scaffolds_nanopore_illumina"       "${SPADES_HYBRID_NANOPORE_SCAFFOLDS}"                "${BUSCO_LINEAGE}"
run_busco "flye_pacbio"                              "${FLYE_PACBIO_FA}"                                  "${BUSCO_LINEAGE}"
run_busco "flye_nanopore"                            "${FLYE_NANOPORE_FA}"                                "${BUSCO_LINEAGE}"

echo "[$(current_time)] running BUSCO with auto lineage detection"
run_busco "canu_pacbio"                              "${CANU_PACBIO_FA}"                                  "auto"
run_busco "canu_nanopore"                            "${CANU_NANOPORE_FA}"                                "auto"
run_busco "spades_scaffolds_pacbio_illumina"         "${SPADES_HYBRID_PACBIO_ILLUMINA_SCAFFOLDS}"         "auto"
run_busco "spades_scaffolds_pacbio_illumina_isolate" "${SPADES_HYBRID_PACBIO_ILLUMINA_ISOLATE_SCAFFOLDS}" "auto"
run_busco "spades_scaffolds_illumina"                "${SPADES_ILLUMINA_SCAFFOLDS}"                       "auto"
run_busco "spades_scaffolds_nanopore_illumina"       "${SPADES_HYBRID_NANOPORE_SCAFFOLDS}"                "auto"
run_busco "flye_pacbio"                              "${FLYE_PACBIO_FA}"                                  "auto"
run_busco "flye_nanopore"                            "${FLYE_NANOPORE_FA}"                                "auto"

echo "[$(current_time)] all BUSCO runs complete (total: $(elapsed_time $total_start))"
