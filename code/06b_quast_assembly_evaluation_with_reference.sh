#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 02:00:00
#SBATCH -J quast_assembly_evaluation_with_reference
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/06b_quast_assembly_evaluation_with_reference.%x.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/paths.sh"

mkdir -p "${QUAST_DIR}"

module purge
module load QUAST/5.3.0-gfbf-2024a

# TODO: set path to reference genome FASTA (e.g. E. faecium Aus0004 from NCBI)
REFERENCE_FA="${REFERENCE_DIR}/TODO_reference_genome.fasta"

CANU_FA="${CANU_PACBIO_OUT_DIR}/efaecium_e745_pacbio.contigs.fasta"
SPADES_SCAFFOLDS="${SPADES_HYBRID_OUT_DIR}/scaffolds.fasta"
SPADES_CONTIGS="${SPADES_HYBRID_OUT_DIR}/contigs.fasta"

# todo: run nanopore assembly
CANU_NANO_FA="${CANU_NANOPORE_OUT_DIR}/efaecium_e745_nanopore.contigs.fasta"

[[ -f "${REFERENCE_FA}" ]] || {
    echo "ERROR: reference genome not found: ${REFERENCE_FA}"
    exit 1
}

run_quast() {
    local label="$1"
    local fa="$2"
    local outdir="${QUAST_DIR}/${label}_ref"

    if [[ ! -f "${fa}" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ${label}: file not found: ${fa}"
        return
    fi

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] running QUAST for ${label} (with reference)"
    local T=$(date +%s)
    quast.py \
        --threads 2 \
        --min-contig 500 \
        -r "${REFERENCE_FA}" \
        --output-dir "${outdir}" \
        "${fa}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ${label} complete ($(elapsed $T))"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] report: ${outdir}"
}

run_quast "canu_pacbio"       "${CANU_FA}"
run_quast "spades_scaffolds"  "${SPADES_SCAFFOLDS}"
run_quast "spades_contigs"    "${SPADES_CONTIGS}"
# todo
# run_quast "canu_nanopore"     "${CANU_NANO_FA}"
