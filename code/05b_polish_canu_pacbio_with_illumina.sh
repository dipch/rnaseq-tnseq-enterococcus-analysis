#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 12:00:00
#SBATCH -J 05b_polish_canu_pacbio_with_illumina
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/05b_polish_canu_pacbio_with_illumina.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"

mkdir -p "${NOBACKUP_PILON_CANU_PACBIO_R1}"
ensure_nobackup_symlink "${PILON_CANU_PACBIO_R1_DIR}" "${NOBACKUP_PILON_CANU_PACBIO_R1}"

module purge
module load Pilon/1.24-Java-17

require_file "${CANU_PACBIO_FA}"               "Canu PacBio assembly"
require_file "${CANU_PACBIO_SORTED_BAM_R1}"    "Illumina alignment BAM (R1)"
require_file "${CANU_PACBIO_SORTED_BAM_R1}.bai" "Illumina alignment BAM index (R1)"

total_start=$(date +%s)

echo "[$(current_time)] running Pilon round 1 on Canu PacBio assembly"
pilon \
    --genome  "${CANU_PACBIO_FA}" \
    --frags   "${CANU_PACBIO_SORTED_BAM_R1}" \
    --output  "${ORGANISM}_canu_pacbio_pilon_r1" \
    --outdir  "${NOBACKUP_PILON_CANU_PACBIO_R1}" \
    --changes \
    --vcf \
    --minmq   20 \
    --threads 2

echo "[$(current_time)] Pilon R1 complete ($(elapsed_time $total_start))"
echo "[$(current_time)] polished FASTA: ${PILON_CANU_PACBIO_R1_FA}"
echo "[$(current_time)] changes file:   ${NOBACKUP_PILON_CANU_PACBIO_R1}/${ORGANISM}_canu_pacbio_pilon_r1.changes"
