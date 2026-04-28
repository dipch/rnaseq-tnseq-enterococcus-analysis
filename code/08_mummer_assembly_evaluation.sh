#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 1
#SBATCH -t 06:00:00
#SBATCH -J mummer_assembly_evaluation
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/08_mummer_assembly_evaluation.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"

rm -rf "${MUMMER_DIR:?}"
mkdir -p "${MUMMER_DIR}"

module purge
module load MUMmer/4.0.1-GCCcore-13.3.0

require_file "${EFAECIUM_CLINICAL_E745_FASTA}"                    "reference genome FASTA"
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

run_mummer() {
    local label="$1"
    local query_fasta="$2"
    local outdir="${MUMMER_DIR}/${label}"

    mkdir -p "${outdir}"
    local prefix="${outdir}/${label}"

    echo "[$(current_time)] running nucmer for ${label}"
    local step_start=$(date +%s)
    nucmer \
        --threads 1 \
        --prefix "${prefix}" \
        "${EFAECIUM_CLINICAL_E745_FASTA}" \
        "${query_fasta}"
    echo "[$(current_time)] nucmer ${label} complete ($(elapsed_time $step_start))"

    echo "[$(current_time)] filtering delta for ${label} (-1)"
    delta-filter -1 "${prefix}.delta" > "${prefix}.filter.delta"

    echo "[$(current_time)] running dnadiff for ${label}"
    step_start=$(date +%s)
    dnadiff \
        -p "${prefix}_dnadiff" \
        -d "${prefix}.delta"
    echo "[$(current_time)] dnadiff ${label} complete ($(elapsed_time $step_start))"

    echo "[$(current_time)] generating mummerplot for ${label}"
    step_start=$(date +%s)
    mummerplot \
        --png \
        --large \
        -R "${EFAECIUM_CLINICAL_E745_FASTA}" \
        -Q "${query_fasta}" \
        --prefix "${prefix}_plot" \
        "${prefix}.filter.delta"
    echo "[$(current_time)] mummerplot ${label} complete ($(elapsed_time $step_start))"
    echo "[$(current_time)] outputs: ${outdir}"
}

total_start=$(date +%s)

run_mummer "canu_pacbio"                              "${CANU_PACBIO_FA}"
run_mummer "canu_nanopore"                            "${CANU_NANOPORE_FA}"
run_mummer "spades_scaffolds_pacbio_illumina"         "${SPADES_HYBRID_PACBIO_ILLUMINA_SCAFFOLDS}"
run_mummer "spades_scaffolds_pacbio_illumina_isolate" "${SPADES_HYBRID_PACBIO_ILLUMINA_ISOLATE_SCAFFOLDS}"
run_mummer "spades_scaffolds_illumina"                "${SPADES_ILLUMINA_SCAFFOLDS}"
run_mummer "spades_scaffolds_nanopore_illumina"       "${SPADES_HYBRID_NANOPORE_SCAFFOLDS}"
run_mummer "flye_pacbio"                              "${FLYE_PACBIO_FA}"
run_mummer "flye_nanopore"                            "${FLYE_NANOPORE_FA}"
run_mummer "canu_pacbio_pilon_r1"                     "${PILON_CANU_PACBIO_R1_FA}"
run_mummer "flye_pacbio_pilon"                        "${PILON_FLYE_PACBIO_FA}"
run_mummer "canu_pacbio_pilon_r2"                     "${PILON_CANU_PACBIO_R2_FA}"

echo "[$(current_time)] all MUMmer runs complete (total: $(elapsed_time $total_start))"
