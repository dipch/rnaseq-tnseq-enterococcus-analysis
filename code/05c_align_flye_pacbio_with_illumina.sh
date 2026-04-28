#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 4
#SBATCH -t 04:00:00
#SBATCH -J 05c_align_flye_pacbio_with_illumina
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/05c_align_flye_pacbio_with_illumina.%x.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"

mkdir -p "${NOBACKUP_FLYE_PACBIO_ALIGN}"
ensure_nobackup_symlink "${FLYE_PACBIO_ALIGN_DIR}" "${NOBACKUP_FLYE_PACBIO_ALIGN}"

module purge
module load BWA/0.7.19-GCCcore-13.3.0
module load SAMtools/1.22.1-GCC-13.3.0

require_file "${FLYE_PACBIO_FA}"  "Flye PacBio assembly"
require_file "${ILLUMINA_R1}"     "Illumina R1"
require_file "${ILLUMINA_R2}"     "Illumina R2"

total_start=$(date +%s)

echo "[$(current_time)] indexing Flye PacBio assembly with BWA"
bwa index "${FLYE_PACBIO_FA}"

echo "[$(current_time)] aligning Illumina reads to Flye PacBio assembly"
bwa mem -t 4 "${FLYE_PACBIO_FA}" "${ILLUMINA_R1}" "${ILLUMINA_R2}" \
    | samtools sort -@ 4 -o "${FLYE_PACBIO_SORTED_BAM}"

echo "[$(current_time)] indexing BAM"
samtools index "${FLYE_PACBIO_SORTED_BAM}"

echo "[$(current_time)] running samtools flagstat"
samtools flagstat "${FLYE_PACBIO_SORTED_BAM}" \
    | tee "${NOBACKUP_FLYE_PACBIO_ALIGN}/flagstat.txt"

echo "[$(current_time)] all steps complete (total: $(elapsed_time $total_start))"
