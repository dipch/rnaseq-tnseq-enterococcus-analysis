#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 06:00:00
#SBATCH -J quast_assembly_evaluation
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/06_quast_assembly_evaluation.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"

rm -rf "${QUAST_DIR:?}"
mkdir -p "${QUAST_DIR}"

module purge
module load QUAST/5.3.0-gfbf-2024a

require_file "${CANU_PACBIO_FA}"                                  "Canu PacBio assembly FASTA"
require_file "${CANU_NANOPORE_FA}"                                "Canu Nanopore assembly FASTA"
require_file "${SPADES_HYBRID_PACBIO_ILLUMINA_SCAFFOLDS}"         "SPAdes scaffolds (PacBio+Illumina hybrid) FASTA"
require_file "${SPADES_HYBRID_PACBIO_ILLUMINA_ISOLATE_SCAFFOLDS}" "SPAdes scaffolds (PacBio+Illumina isolate) FASTA"
require_file "${SPADES_ILLUMINA_SCAFFOLDS}"                       "SPAdes scaffolds (Illumina-only) FASTA"
require_file "${SPADES_HYBRID_NANOPORE_SCAFFOLDS}"                "SPAdes scaffolds (Nanopore+Illumina hybrid) FASTA"
require_file "${FLYE_PACBIO_FA}"                                  "Flye PacBio assembly FASTA"
require_file "${FLYE_NANOPORE_FA}"                                "Flye Nanopore assembly FASTA"
require_file "${PILON_CANU_PACBIO_R1_FA}"                         "Canu PacBio Pilon R1 FASTA"
require_file "${PILON_FLYE_PACBIO_FA}"                            "Flye PacBio Pilon FASTA"
require_file "${PILON_CANU_PACBIO_R2_FA}"                         "Canu PacBio Pilon R2 FASTA"

run_quast() {
    local label="$1"
    local query_fasta="$2"
    local outdir="${QUAST_DIR}/${label}"

    echo "[$(current_time)] running QUAST for ${label}"
    local step_start=$(date +%s)

    # --min-contig : default value 500
    # --est-ref-size : only needed when no reference genome file is provided
    quast.py \
        --threads 2 \
        --min-contig 500 \
        --est-ref-size ${GENOME_SIZE_BP} \
        --output-dir "${outdir}" \
        "${query_fasta}"
    echo "[$(current_time)] ${label} complete ($(elapsed_time $step_start))"
    echo "[$(current_time)] report: ${outdir}"
}

total_start=$(date +%s)

run_quast "canu_pacbio"                              "${CANU_PACBIO_FA}"
run_quast "canu_nanopore"                            "${CANU_NANOPORE_FA}"
run_quast "spades_scaffolds_pacbio_illumina"         "${SPADES_HYBRID_PACBIO_ILLUMINA_SCAFFOLDS}"
run_quast "spades_scaffolds_pacbio_illumina_isolate" "${SPADES_HYBRID_PACBIO_ILLUMINA_ISOLATE_SCAFFOLDS}"
run_quast "spades_scaffolds_illumina"                "${SPADES_ILLUMINA_SCAFFOLDS}"
run_quast "spades_scaffolds_nanopore_illumina"       "${SPADES_HYBRID_NANOPORE_SCAFFOLDS}"
run_quast "flye_pacbio"                              "${FLYE_PACBIO_FA}"
run_quast "flye_nanopore"                            "${FLYE_NANOPORE_FA}"
run_quast "canu_pacbio_pilon_r1"                     "${PILON_CANU_PACBIO_R1_FA}"
run_quast "flye_pacbio_pilon"                        "${PILON_FLYE_PACBIO_FA}"
run_quast "canu_pacbio_pilon_r2"                     "${PILON_CANU_PACBIO_R2_FA}"

echo "[$(current_time)] all QUAST runs complete (total: $(elapsed_time $total_start))"
