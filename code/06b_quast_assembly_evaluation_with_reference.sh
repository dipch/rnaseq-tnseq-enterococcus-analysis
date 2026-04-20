#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 02:00:00
#SBATCH -J quast_assembly_evaluation_with_reference
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/06b_quast_assembly_evaluation_with_reference.%x.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"

mkdir -p "${QUAST_WITH_REFERENCE_DIR}"

module purge
module load QUAST/5.3.0-gfbf-2024a

require_file "${REFERENCE_FA}"     "reference genome FASTA"
require_file "${REFERENCE_GFF}"    "reference GFF"
require_file "${CANU_PACBIO_FA}"   "Canu PacBio assembly FASTA"
require_file "${SPADES_SCAFFOLDS}" "SPAdes scaffolds FASTA"

run_quast() {
    local label="$1"
    local fa="$2"
    local outdir="${QUAST_WITH_REFERENCE_DIR}/${label}_ref"

    echo "[$(current_time)] running QUAST for ${label} (with reference)"
    local T_step=$(date +%s)
    quast.py \
        --threads 2 \
        --min-contig 500 \
        -r "${REFERENCE_FA}" \
        --features "${REFERENCE_GFF}" \
        --output-dir "${outdir}" \
        "${fa}"
    echo "[$(current_time)] ${label} complete ($(elapsed_time $T_step))"
    echo "[$(current_time)] report: ${outdir}"
}

run_quast "canu_pacbio"       "${CANU_PACBIO_FA}"
run_quast "spades_scaffolds"  "${SPADES_SCAFFOLDS}"
run_quast "spades_contigs"    "${SPADES_CONTIGS}"
# todo
# run_quast "canu_nanopore"     "${CANU_NANO_FA}"
