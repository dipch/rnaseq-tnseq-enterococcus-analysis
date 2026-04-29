#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 1
#SBATCH -t 06:00:00
#SBATCH -J busco_assembly_evaluation
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/07_busco_assembly_evaluation.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"

# Re-running only the reference genome (GCF_001750885.1) BUSCO so existing
# per-assembly results are preserved. To do a full re-run, uncomment the rm -rf
# below and the assembly require_file / run_busco blocks further down.
# rm -rf "${BUSCO_DIR_ENTEROCOCCUS:?}" "${BUSCO_DIR_ENTEROCOCCACEAE:?}"
mkdir -p "${BUSCO_DIR_ENTEROCOCCUS}" "${BUSCO_DIR_ENTEROCOCCACEAE}"

module purge
module load BUSCO/5.8.2-gfbf-2024a

require_file "${EFAECIUM_CLINICAL_E745_FASTA}"                    "E. faecium E745 reference genome FASTA (GCF_001750885.1)"

# require_file "${CANU_PACBIO_FA}"                                  "Canu PacBio assembly FASTA"
# require_file "${CANU_NANOPORE_FA}"                                "Canu Nanopore assembly FASTA"
# require_file "${SPADES_HYBRID_PACBIO_ILLUMINA_SCAFFOLDS}"         "SPAdes scaffolds (PacBio+Illumina hybrid) FASTA"
# require_file "${SPADES_HYBRID_PACBIO_ILLUMINA_ISOLATE_SCAFFOLDS}" "SPAdes scaffolds (PacBio+Illumina isolate) FASTA"
# require_file "${SPADES_ILLUMINA_SCAFFOLDS}"                       "SPAdes scaffolds (Illumina-only) FASTA"
# require_file "${SPADES_HYBRID_NANOPORE_SCAFFOLDS}"                "SPAdes scaffolds (Nanopore+Illumina hybrid) FASTA"
# require_file "${FLYE_PACBIO_FA}"                                  "Flye PacBio assembly FASTA"
# require_file "${FLYE_NANOPORE_FA}"                                "Flye Nanopore assembly FASTA"
# require_file "${PILON_CANU_PACBIO_R1_FA}"                         "Canu PacBio Pilon R1 FASTA"
# require_file "${PILON_FLYE_PACBIO_FA}"                            "Flye PacBio Pilon FASTA"
# require_file "${PILON_CANU_PACBIO_R2_FA}"                         "Canu PacBio Pilon R2 FASTA"

run_busco() {
    local label="$1"
    local query_fasta="$2"
    local lineage="$3"
    local outdir="$4"
    local out_label="${label}_${lineage}"

    echo "[$(current_time)] running BUSCO for ${label} (lineage: ${lineage})"
    local step_start=$(date +%s)
    busco \
        --in "${query_fasta}" \
        --out "${out_label}" \
        --out_path "${outdir}" \
        --lineage_dataset "${lineage}" \
        --mode genome \
        --cpu 1 \
        --force
    echo "[$(current_time)] ${out_label} complete ($(elapsed_time $step_start))"
    echo "[$(current_time)] results: ${outdir}/${out_label}"
}

total_start=$(date +%s)

echo "[$(current_time)] running BUSCO with lineage ${BUSCO_LINEAGE_ENTEROCOCCUS}"
run_busco "reference_e745"                           "${EFAECIUM_CLINICAL_E745_FASTA}"                    "${BUSCO_LINEAGE_ENTEROCOCCUS}" "${BUSCO_DIR_ENTEROCOCCUS}"
# run_busco "canu_pacbio"                              "${CANU_PACBIO_FA}"                                  "${BUSCO_LINEAGE_ENTEROCOCCUS}" "${BUSCO_DIR_ENTEROCOCCUS}"
# run_busco "canu_nanopore"                            "${CANU_NANOPORE_FA}"                                "${BUSCO_LINEAGE_ENTEROCOCCUS}" "${BUSCO_DIR_ENTEROCOCCUS}"
# run_busco "spades_scaffolds_pacbio_illumina"         "${SPADES_HYBRID_PACBIO_ILLUMINA_SCAFFOLDS}"         "${BUSCO_LINEAGE_ENTEROCOCCUS}" "${BUSCO_DIR_ENTEROCOCCUS}"
# run_busco "spades_scaffolds_pacbio_illumina_isolate" "${SPADES_HYBRID_PACBIO_ILLUMINA_ISOLATE_SCAFFOLDS}" "${BUSCO_LINEAGE_ENTEROCOCCUS}" "${BUSCO_DIR_ENTEROCOCCUS}"
# run_busco "spades_scaffolds_illumina"                "${SPADES_ILLUMINA_SCAFFOLDS}"                       "${BUSCO_LINEAGE_ENTEROCOCCUS}" "${BUSCO_DIR_ENTEROCOCCUS}"
# run_busco "spades_scaffolds_nanopore_illumina"       "${SPADES_HYBRID_NANOPORE_SCAFFOLDS}"                "${BUSCO_LINEAGE_ENTEROCOCCUS}" "${BUSCO_DIR_ENTEROCOCCUS}"
# run_busco "flye_pacbio"                              "${FLYE_PACBIO_FA}"                                  "${BUSCO_LINEAGE_ENTEROCOCCUS}" "${BUSCO_DIR_ENTEROCOCCUS}"
# run_busco "flye_nanopore"                            "${FLYE_NANOPORE_FA}"                                "${BUSCO_LINEAGE_ENTEROCOCCUS}" "${BUSCO_DIR_ENTEROCOCCUS}"
# run_busco "canu_pacbio_pilon_r1"                     "${PILON_CANU_PACBIO_R1_FA}"                         "${BUSCO_LINEAGE_ENTEROCOCCUS}" "${BUSCO_DIR_ENTEROCOCCUS}"
# run_busco "flye_pacbio_pilon"                        "${PILON_FLYE_PACBIO_FA}"                            "${BUSCO_LINEAGE_ENTEROCOCCUS}" "${BUSCO_DIR_ENTEROCOCCUS}"
# run_busco "canu_pacbio_pilon_r2"                     "${PILON_CANU_PACBIO_R2_FA}"                         "${BUSCO_LINEAGE_ENTEROCOCCUS}" "${BUSCO_DIR_ENTEROCOCCUS}"

echo "[$(current_time)] running BUSCO with lineage ${BUSCO_LINEAGE_ENTEROCOCCACEAE}"
run_busco "reference_e745"                           "${EFAECIUM_CLINICAL_E745_FASTA}"                    "${BUSCO_LINEAGE_ENTEROCOCCACEAE}" "${BUSCO_DIR_ENTEROCOCCACEAE}"
# run_busco "canu_pacbio"                              "${CANU_PACBIO_FA}"                                  "${BUSCO_LINEAGE_ENTEROCOCCACEAE}" "${BUSCO_DIR_ENTEROCOCCACEAE}"
# run_busco "canu_nanopore"                            "${CANU_NANOPORE_FA}"                                "${BUSCO_LINEAGE_ENTEROCOCCACEAE}" "${BUSCO_DIR_ENTEROCOCCACEAE}"
# run_busco "spades_scaffolds_pacbio_illumina"         "${SPADES_HYBRID_PACBIO_ILLUMINA_SCAFFOLDS}"         "${BUSCO_LINEAGE_ENTEROCOCCACEAE}" "${BUSCO_DIR_ENTEROCOCCACEAE}"
# run_busco "spades_scaffolds_pacbio_illumina_isolate" "${SPADES_HYBRID_PACBIO_ILLUMINA_ISOLATE_SCAFFOLDS}" "${BUSCO_LINEAGE_ENTEROCOCCACEAE}" "${BUSCO_DIR_ENTEROCOCCACEAE}"
# run_busco "spades_scaffolds_illumina"                "${SPADES_ILLUMINA_SCAFFOLDS}"                       "${BUSCO_LINEAGE_ENTEROCOCCACEAE}" "${BUSCO_DIR_ENTEROCOCCACEAE}"
# run_busco "spades_scaffolds_nanopore_illumina"       "${SPADES_HYBRID_NANOPORE_SCAFFOLDS}"                "${BUSCO_LINEAGE_ENTEROCOCCACEAE}" "${BUSCO_DIR_ENTEROCOCCACEAE}"
# run_busco "flye_pacbio"                              "${FLYE_PACBIO_FA}"                                  "${BUSCO_LINEAGE_ENTEROCOCCACEAE}" "${BUSCO_DIR_ENTEROCOCCACEAE}"
# run_busco "flye_nanopore"                            "${FLYE_NANOPORE_FA}"                                "${BUSCO_LINEAGE_ENTEROCOCCACEAE}" "${BUSCO_DIR_ENTEROCOCCACEAE}"
# run_busco "canu_pacbio_pilon_r1"                     "${PILON_CANU_PACBIO_R1_FA}"                         "${BUSCO_LINEAGE_ENTEROCOCCACEAE}" "${BUSCO_DIR_ENTEROCOCCACEAE}"
# run_busco "flye_pacbio_pilon"                        "${PILON_FLYE_PACBIO_FA}"                            "${BUSCO_LINEAGE_ENTEROCOCCACEAE}" "${BUSCO_DIR_ENTEROCOCCACEAE}"
# run_busco "canu_pacbio_pilon_r2"                     "${PILON_CANU_PACBIO_R2_FA}"                         "${BUSCO_LINEAGE_ENTEROCOCCACEAE}" "${BUSCO_DIR_ENTEROCOCCACEAE}"

echo "[$(current_time)] all BUSCO runs complete (total: $(elapsed_time $total_start))"
