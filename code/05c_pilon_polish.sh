#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 12:00:00
#SBATCH -J pilon_polish
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/05c_pilon_polish.%x.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"

mkdir -p "${NOBACKUP_PILON}"
ensure_nobackup_symlink "${PILON_OUT_DIR}" "${NOBACKUP_PILON}"

module purge
module load Pilon/1.24-Java-17

require_file "${CANU_PACBIO_FA}"       "Canu PacBio assembly FASTA"
require_file "${POLISH_SORTED_BAM}"    "Illumina alignment BAM"
require_file "${POLISH_SORTED_BAM}.bai" "Illumina alignment BAM index"

total_start=$(date +%s)

echo "[$(current_time)] running Pilon"
echo "[$(current_time)] genome:  ${CANU_PACBIO_FA}"
echo "[$(current_time)] frags:   ${POLISH_SORTED_BAM}"
echo "[$(current_time)] output:  ${NOBACKUP_PILON}/${ORGANISM}_pilon"
step_start=$(date +%s)

pilon \
    --genome  "${CANU_PACBIO_FA}" \
    --frags   "${POLISH_SORTED_BAM}" \
    --output  "${ORGANISM}_pilon" \
    --outdir  "${NOBACKUP_PILON}" \
    --changes \
    --vcf \
    --minmq   20 \
    --threads 2

echo "[$(current_time)] Pilon complete ($(elapsed_time $step_start))"
echo "[$(current_time)] polished FASTA: ${PILON_FA}"
echo "[$(current_time)] all steps complete (total: $(elapsed_time $total_start))"
