#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 06:00:00
#SBATCH -J 11_rna_mapping
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/11_rna_mapping.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"

mkdir -p "${NOBACKUP_RNA_MAPPING}"
ensure_nobackup_symlink "${RNA_MAPPING_DIR}" "${NOBACKUP_RNA_MAPPING}"

module purge
module load BWA/0.7.19-GCCcore-13.3.0
module load SAMtools/1.22.1-GCC-13.3.0

REFERENCE="${PILON_CANU_PACBIO_R2_FA}"
require_file "${REFERENCE}" "Canu PacBio Pilon R2 assembly (RNA mapping reference)"
require_dir_nonempty "${TRIMMED_DIR}" "trimmed RNA reads directory"

total_start=$(date +%s)

echo "[$(current_time)] indexing reference with BWA: ${REFERENCE}"
bwa index "${REFERENCE}"

SAMPLES=("${TRIMMED_DIR}"/rna_*_R1_paired.fastq.gz)
TOTAL=${#SAMPLES[@]}
file_index=0

for R1 in "${SAMPLES[@]}"; do
    R2="${R1/_R1_paired.fastq.gz/_R2_paired.fastq.gz}"
    SAMPLE=$(basename "${R1}" _R1_paired.fastq.gz)
    BAM="${NOBACKUP_RNA_MAPPING}/${SAMPLE}.sorted.bam"
    file_index=$((file_index + 1))

    require_file "${R2}" "${SAMPLE} R2"

    echo "[$(current_time)] [sample ${file_index} of ${TOTAL}] mapping ${SAMPLE}"
    T0=$(date +%s)
    bwa mem -t 2 "${REFERENCE}" "${R1}" "${R2}" \
        | samtools sort -@ 2 -o "${BAM}"
    samtools index "${BAM}"
    samtools flagstat "${BAM}" \
        | tee "${NOBACKUP_RNA_MAPPING}/${SAMPLE}.flagstat.txt"
    echo "[$(current_time)] [sample ${file_index} of ${TOTAL}] ${SAMPLE} done ($(elapsed_time $T0))"
done

echo "[$(current_time)] RNA mapping complete (total: $(elapsed_time $total_start))"
