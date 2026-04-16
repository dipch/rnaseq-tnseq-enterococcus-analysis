#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 04:00:00
#SBATCH -J align_polish_canu_pacbio_with_illumina
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/05_align_polish_canu_pacbio_with_illumina.%x.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/paths.sh"

# all outputs go to nobackup (bam, index, flagstat); symlink into analyses/
mkdir -p "${ASSEMBLY_DIR}" "${NOBACKUP_POLISH}"
ensure_nobackup_symlink "${POLISH_ALIGN_DIR}" "${NOBACKUP_POLISH}"

module purge
module load BWA/0.7.19-GCCcore-13.3.0
module load SAMtools/1.22.1-GCC-13.3.0
#module load Bowtie2/2.5.4-GCC-13.3.0

ASSEMBLY_FA="${CANU_PACBIO_OUT_DIR}/efaecium_e745_pacbio.contigs.fasta"
ILLUMINA_R1="${RAW_DIR}/dna_illumina_R1.fq.gz"
ILLUMINA_R2="${RAW_DIR}/dna_illumina_R2.fq.gz"
SORTED_BAM="${NOBACKUP_POLISH}/efaecium_e745_illumina_sorted.bam"
FLAGSTAT_TXT="${NOBACKUP_POLISH}/flagstat.txt"

[[ -f "${ASSEMBLY_FA}" ]] || {
    echo "ERROR: Canu assembly not found: ${ASSEMBLY_FA}"
    exit 1
}
[[ -f "${ILLUMINA_R1}" ]] || {
    echo "ERROR: Illumina R1 not found: ${ILLUMINA_R1}"
    exit 1
}
[[ -f "${ILLUMINA_R2}" ]] || {
    echo "ERROR: Illumina R2 not found: ${ILLUMINA_R2}"
    exit 1
}

# index assembly with bwa
echo "[$(date '+%Y-%m-%d %H:%M:%S')] indexing Canu PacBio assembly with BWA"
T0=$(date +%s)
bwa index "${ASSEMBLY_FA}"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] indexing complete ($(elapsed $T0))"

# align+sort
echo "[$(date '+%Y-%m-%d %H:%M:%S')] aligning Illumina reads to assembly"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] R1: ${ILLUMINA_R1}"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] R2: ${ILLUMINA_R2}"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] output BAM: ${SORTED_BAM}"
T1=$(date +%s)
bwa mem -t 2 "${ASSEMBLY_FA}" "${ILLUMINA_R1}" "${ILLUMINA_R2}" \
    | samtools sort -@ 2 -o "${SORTED_BAM}"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] alignment + sort complete ($(elapsed $T1))"

# index bam
echo "[$(date '+%Y-%m-%d %H:%M:%S')] indexing BAM"
T2=$(date +%s)
samtools index "${SORTED_BAM}"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] BAM index complete ($(elapsed $T2))"


echo "[$(date '+%Y-%m-%d %H:%M:%S')] running samtools flagstat"
samtools flagstat "${SORTED_BAM}" | tee "${FLAGSTAT_TXT}"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] flagstat saved to ${FLAGSTAT_TXT}"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] all steps complete (total: $(elapsed $T0))"
