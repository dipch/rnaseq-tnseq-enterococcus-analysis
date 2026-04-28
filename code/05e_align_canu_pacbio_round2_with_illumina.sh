#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 06:00:00
#SBATCH -J 05e_align_canu_pacbio_round2_with_illumina
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/05e_align_canu_pacbio_round2_with_illumina.%j.out

# Round 2: input genome is the Pilon R1 polished FASTA, not the original Canu assembly.
# Illumina reads must be re-aligned to the R1 output since coordinates changed.

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"

mkdir -p "${NOBACKUP_CANU_PACBIO_ALIGN_R2}"
ensure_nobackup_symlink "${CANU_PACBIO_ALIGN_R2_DIR}" "${NOBACKUP_CANU_PACBIO_ALIGN_R2}"

module purge
module load BWA/0.7.19-GCCcore-13.3.0
module load SAMtools/1.22.1-GCC-13.3.0

require_file "${PILON_CANU_PACBIO_R1_FA}" "Canu PacBio Pilon R1 FASTA"
require_file "${ILLUMINA_R1}"             "Illumina R1"
require_file "${ILLUMINA_R2}"             "Illumina R2"

total_start=$(date +%s)

echo "[$(current_time)] indexing Canu PacBio Pilon R1 assembly with BWA"
bwa index "${PILON_CANU_PACBIO_R1_FA}"

echo "[$(current_time)] aligning Illumina reads to Pilon R1 assembly"
bwa mem -t 2 "${PILON_CANU_PACBIO_R1_FA}" "${ILLUMINA_R1}" "${ILLUMINA_R2}" \
    | samtools sort -@ 2 -o "${CANU_PACBIO_SORTED_BAM_R2}"

echo "[$(current_time)] indexing BAM"
samtools index "${CANU_PACBIO_SORTED_BAM_R2}"

echo "[$(current_time)] running samtools flagstat"
samtools flagstat "${CANU_PACBIO_SORTED_BAM_R2}" \
    | tee "${NOBACKUP_CANU_PACBIO_ALIGN_R2}/flagstat.txt"

echo "[$(current_time)] all steps complete (total: $(elapsed_time $total_start))"
