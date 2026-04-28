#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 4
#SBATCH -t 04:00:00
#SBATCH -J 05a_align_canu_pacbio_with_illumina
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/05a_align_canu_pacbio_with_illumina.%x.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"

mkdir -p "${NOBACKUP_CANU_PACBIO_ALIGN_R1}"
ensure_nobackup_symlink "${CANU_PACBIO_ALIGN_R1_DIR}" "${NOBACKUP_CANU_PACBIO_ALIGN_R1}"

module purge
module load BWA/0.7.19-GCCcore-13.3.0
module load SAMtools/1.22.1-GCC-13.3.0

require_file "${CANU_PACBIO_FA}"  "Canu PacBio assembly"
require_file "${ILLUMINA_R1}"     "Illumina R1"
require_file "${ILLUMINA_R2}"     "Illumina R2"

total_start=$(date +%s)

echo "[$(current_time)] indexing Canu PacBio assembly with BWA"
bwa index "${CANU_PACBIO_FA}"

echo "[$(current_time)] aligning Illumina reads to Canu PacBio assembly"
bwa mem -t 4 "${CANU_PACBIO_FA}" "${ILLUMINA_R1}" "${ILLUMINA_R2}" \
    | samtools sort -@ 4 -o "${CANU_PACBIO_SORTED_BAM_R1}"

echo "[$(current_time)] indexing BAM"
samtools index "${CANU_PACBIO_SORTED_BAM_R1}"

echo "[$(current_time)] running samtools flagstat"
samtools flagstat "${CANU_PACBIO_SORTED_BAM_R1}" \
    | tee "${NOBACKUP_CANU_PACBIO_ALIGN_R1}/flagstat.txt"

echo "[$(current_time)] all steps complete (total: $(elapsed_time $total_start))"
