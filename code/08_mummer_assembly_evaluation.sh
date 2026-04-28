#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 1
#SBATCH -t 02:00:00
#SBATCH -J mummer_assembly_evaluation_spades_isolate
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/08_mummer_assembly_evaluation.%x.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"

#todo: uncomment rm -rf "${MUMMER_DIR:?}"
mkdir -p "${MUMMER_DIR}/nucmer" "${MUMMER_DIR}/filter_rq" "${MUMMER_DIR}/filter_1"

module purge
module load MUMmer/4.0.1-GCCcore-13.3.0

require_file "${REFERENCE_FASTA}"         "reference genome FASTA"
#todo: uncomment require_file "${CANU_PACBIO_FA}"          "Canu PacBio assembly FASTA"
#todo: uncomment require_file "${SPADES_SCAFFOLDS}"        "SPAdes scaffolds FASTA"
require_file "${PILON_PACBIO_FA}"               "Pilon polished FASTA"

#temp
#todo: uncomment require_file "${SPADES_SCAFFOLDS_ISOLATE}"  "SPAdes scaffolds FASTA (isolate)"

run_nucmer() {
    local label="$1"
    local query_fasta="$2"
    local prefix="${MUMMER_DIR}/nucmer/${label}"

    echo "[$(current_time)] running nucmer for ${label}"
    local step_start=$(date +%s)
    nucmer \
        --threads 1 \
        --prefix "${prefix}" \
        "${REFERENCE_FASTA}" \
        "${query_fasta}"
    echo "[$(current_time)] nucmer ${label} complete ($(elapsed_time $step_start))"
}

run_filter_and_plot() {
    local label="$1"
    local query_fasta="$2"
    local filter_mode="$3"   # "rq" or "1"
    local delta="${MUMMER_DIR}/nucmer/${label}.delta"
    local outdir="${MUMMER_DIR}/filter_${filter_mode}/${label}"

    mkdir -p "${outdir}"
    local prefix="${outdir}/${label}"

    echo "[$(current_time)] filtering delta for ${label} (filter: ${filter_mode})"
    if [[ "${filter_mode}" == "1" ]]; then
        delta-filter -1 "${delta}" > "${prefix}.filter.delta"
    else
        delta-filter -r -q "${delta}" > "${prefix}.filter.delta"
    fi

    echo "[$(current_time)] running dnadiff for ${label} (filter: ${filter_mode})"
    local step_start=$(date +%s)
    dnadiff \
        -p "${prefix}_dnadiff" \
        -d "${delta}"
    echo "[$(current_time)] dnadiff ${label} complete ($(elapsed_time $step_start))"

    echo "[$(current_time)] generating mummerplot for ${label} (filter: ${filter_mode})"
    step_start=$(date +%s)
    mummerplot \
        --png \
	--large
        -R "${REFERENCE_FASTA}" \
        -Q "${query_fasta}" \
        --prefix "${prefix}_plot" \
        "${prefix}.filter.delta"
    echo "[$(current_time)] mummerplot ${label} complete ($(elapsed_time $step_start))"
    echo "[$(current_time)] outputs: ${outdir}"
}

total_start=$(date +%s)

echo "[$(current_time)]  nucmer alignment"
#todo: uncomment run_nucmer "canu_pacbio"             "${CANU_PACBIO_FA}"
#todo: uncomment run_nucmer "spades_scaffolds_pacbio_illumina"        "${SPADES_SCAFFOLDS}"
run_nucmer "pilon_polish_pacbio_illumina"            "${PILON_PACBIO_FA}"
#todo: uncomment run_nucmer "spades_scaffolds_pacbio_illumina_isolate" "${SPADES_SCAFFOLDS_ISOLATE}"  # temp

echo "[$(current_time)]  filter: -r -q "
#todo: uncomment run_filter_and_plot "canu_pacbio"             "${CANU_PACBIO_FA}"  "rq"
#todo: uncomment run_filter_and_plot "spades_scaffolds_pacbio_illumina"        "${SPADES_SCAFFOLDS}" "rq"
run_filter_and_plot "pilon_polish_pacbio_illumina"            "${PILON_PACBIO_FA}"         "rq"
#todo: uncomment run_filter_and_plot "spades_scaffolds_pacbio_illumina_isolate" "${SPADES_SCAFFOLDS_ISOLATE}" "rq"

echo "[$(current_time)]  filter: -1 "
#todo: uncomment run_filter_and_plot "canu_pacbio"             "${CANU_PACBIO_FA}"  "1"
#todo: uncomment run_filter_and_plot "spades_scaffolds_pacbio_illumina"        "${SPADES_SCAFFOLDS}" "1"
run_filter_and_plot "pilon_polish_pacbio_illumina"            "${PILON_PACBIO_FA}"         "1"
#todo: uncomment run_filter_and_plot "spades_scaffolds_pacbio_illumina_isolate" "${SPADES_SCAFFOLDS_ISOLATE}" "1"

echo "[$(current_time)] all MUMmer runs complete (total: $(elapsed_time $total_start))"
