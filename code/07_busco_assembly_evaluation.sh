#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 1
#SBATCH -t 02:00:00
#SBATCH -J busco_assembly_evaluation
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/07_busco_assembly_evaluation.%x.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/paths.sh"


mkdir -p "${BUSCO_DIR_AUTO_LINEAGE}"
mkdir -p "${BUSCO_DIR_MANUAL_LINEAGE}"

module purge
module load BUSCO/5.8.2-gfbf-2024a

CANU_FA="${CANU_PACBIO_OUT_DIR}/efaecium_e745_pacbio.contigs.fasta"
SPADES_SCAFFOLDS="${SPADES_HYBRID_OUT_DIR}/scaffolds.fasta"

# todo: run nanopore assembly
# CANU_NANO_FA="${CANU_NANOPORE_OUT_DIR}/efaecium_e745_nanopore.contigs.fasta"

# todo: BUSCO datasets citation
run_busco() {
    local label="$1"
    local fa="$2"
    local lineage="$3"
    local out_label="${label}_${lineage}"

    if [[ ! -f "${fa}" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ${label}: file not found: ${fa}"
        return
    fi

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] running BUSCO for ${label} (lineage: ${lineage})"
    local T=$(date +%s)
    busco \
        --in "${fa}" \
        --out "${out_label}" \
        --out_path "${BUSCO_DIR_MANUAL_LINEAGE}" \
        --lineage_dataset "${lineage}" \
        --mode genome \
        --cpu 1 \
        --force
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ${out_label} complete ($(elapsed $T))"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] results: ${BUSCO_DIR_MANUAL_LINEAGE}/${out_label}"
}

run_busco_auto() {
    local label="$1"
    local fa="$2"
    local out_label="${label}_auto"

    if [[ ! -f "${fa}" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ${label}: file not found: ${fa}"
        return
    fi

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] running BUSCO for ${label} (lineage: auto)"
    local T=$(date +%s)
    busco \
        --in "${fa}" \
        --out "${out_label}" \
        --out_path "${BUSCO_DIR_AUTO_LINEAGE}" \
        --auto-lineage-prok \
        --mode genome \
        --cpu 1 \
        --force
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ${out_label} complete ($(elapsed $T))"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] results: ${BUSCO_DIR_AUTO_LINEAGE}/${out_label}"
}

T0=$(date +%s)

# run with enterococcus_odb12
run_busco "canu_pacbio"      "${CANU_FA}"         "enterococcus_odb12"
run_busco "spades_scaffolds" "${SPADES_SCAFFOLDS}" "enterococcus_odb12"

# run with auto lineage detection
run_busco_auto "canu_pacbio"      "${CANU_FA}"
run_busco_auto "spades_scaffolds" "${SPADES_SCAFFOLDS}"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] all BUSCO runs complete (total: $(elapsed $T0))"
