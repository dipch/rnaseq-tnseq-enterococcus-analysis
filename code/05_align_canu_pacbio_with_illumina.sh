#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 04:00:00
#SBATCH -J align_canu_pacbio_with_illumina
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/05_align_canu_pacbio_with_illumina.%x.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"

# all outputs go to nobackup (bam, index, flagstat); symlink into analyses/
mkdir -p "${ASSEMBLY_DIR}" "${NOBACKUP_POLISH_PACBIO}"
ensure_nobackup_symlink "${POLISH_PACBIO_ALIGN_DIR}" "${NOBACKUP_POLISH_PACBIO}"

module purge
module load BWA/0.7.19-GCCcore-13.3.0
module load SAMtools/1.22.1-GCC-13.3.0
#module load Bowtie2/2.5.4-GCC-13.3.0

SORTED_BAM="${POLISH_PACBIO_SORTED_BAM}"
FLAGSTAT_TXT="${NOBACKUP_POLISH_PACBIO}/flagstat.txt"

require_file "${CANU_PACBIO_FA}" "Canu assembly"
require_file "${ILLUMINA_R1}" "Illumina R1"
require_file "${ILLUMINA_R2}" "Illumina R2"

total_start=$(date +%s)

# index assembly with bwa
echo "[$(current_time)] indexing Canu PacBio assembly with BWA"
index_start=$(date +%s)
bwa index "${CANU_PACBIO_FA}"
echo "[$(current_time)] indexing complete ($(elapsed_time $index_start))"

# align+sort
echo "[$(current_time)] aligning Illumina reads to assembly"
echo "[$(current_time)] R1: ${ILLUMINA_R1}"
echo "[$(current_time)] R2: ${ILLUMINA_R2}"
echo "[$(current_time)] output BAM: ${SORTED_BAM}"
align_start=$(date +%s)
bwa mem -t 2 "${CANU_PACBIO_FA}" "${ILLUMINA_R1}" "${ILLUMINA_R2}" \
    | samtools sort -@ 2 -o "${SORTED_BAM}"
echo "[$(current_time)] alignment + sort complete ($(elapsed_time $align_start))"

# index bam
echo "[$(current_time)] indexing BAM"
bam_start=$(date +%s)
samtools index "${SORTED_BAM}"
echo "[$(current_time)] BAM index complete ($(elapsed_time $bam_start))"
echo "[$(current_time)] running samtools flagstat"
samtools flagstat "${SORTED_BAM}" | tee "${FLAGSTAT_TXT}"
echo "[$(current_time)] flagstat saved to ${FLAGSTAT_TXT}"
echo "[$(current_time)] all steps complete (total: $(elapsed_time $total_start))"
