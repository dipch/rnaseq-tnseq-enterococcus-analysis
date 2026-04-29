#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 06:00:00
#SBATCH -J quast_assembly_evaluation_multi_with_reference
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/06c_quast_assembly_evaluation_multi_with_reference.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"

rm -rf "${QUAST_MULTI_WITH_REFERENCE_DIR:?}"
mkdir -p "${QUAST_MULTI_WITH_REFERENCE_DIR}"

module purge
module load QUAST/5.3.0-gfbf-2024a

require_file "${EFAECIUM_CLINICAL_E745_FASTA}"                    "reference genome FASTA"
require_file "${EFAECIUM_CLINICAL_E745_GFF}"                      "reference GFF"
require_file "${CANU_PACBIO_FA}"                                  "Canu PacBio assembly FASTA"
require_file "${PILON_CANU_PACBIO_R1_FA}"                         "Canu PacBio Pilon R1 FASTA"
require_file "${PILON_CANU_PACBIO_R2_FA}"                         "Canu PacBio Pilon R2 FASTA"
require_file "${FLYE_PACBIO_FA}"                                  "Flye PacBio assembly FASTA"
require_file "${PILON_FLYE_PACBIO_FA}"                            "Flye PacBio Pilon FASTA"
require_file "${SPADES_HYBRID_PACBIO_ILLUMINA_SCAFFOLDS}"         "SPAdes scaffolds (PacBio+Illumina hybrid) FASTA"
require_file "${SPADES_HYBRID_PACBIO_ILLUMINA_ISOLATE_SCAFFOLDS}" "SPAdes scaffolds (PacBio+Illumina isolate) FASTA"

echo "[$(current_time)] running QUAST multi-assembly evaluation (with reference)"
total_start=$(date +%s)

quast.py \
    --threads 2 \
    --min-contig 500 \
    -r "${EFAECIUM_CLINICAL_E745_FASTA}" \
    --features "${EFAECIUM_CLINICAL_E745_GFF}" \
    --output-dir "${QUAST_MULTI_WITH_REFERENCE_DIR}" \
    --labels "canu_pacbio,canu_pacbio_pilon_r1,canu_pacbio_pilon_r2,flye_pacbio,flye_pacbio_pilon,spades_pacbio_illumina,spades_pacbio_illumina_isolate" \
    "${CANU_PACBIO_FA}" \
    "${PILON_CANU_PACBIO_R1_FA}" \
    "${PILON_CANU_PACBIO_R2_FA}" \
    "${FLYE_PACBIO_FA}" \
    "${PILON_FLYE_PACBIO_FA}" \
    "${SPADES_HYBRID_PACBIO_ILLUMINA_SCAFFOLDS}" \
    "${SPADES_HYBRID_PACBIO_ILLUMINA_ISOLATE_SCAFFOLDS}"

echo "[$(current_time)] multi-assembly QUAST complete ($(elapsed_time $total_start))"
echo "[$(current_time)] report: ${QUAST_MULTI_WITH_REFERENCE_DIR}"
