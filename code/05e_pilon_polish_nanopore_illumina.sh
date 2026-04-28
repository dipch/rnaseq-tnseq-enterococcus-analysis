#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 12:00:00
#SBATCH -J pilon_polish_nanopore_illumina
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/05e_pilon_polish_nanopore_illumina.%x.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"

mkdir -p "${NOBACKUP_PILON_NANOPORE}"
ensure_nobackup_symlink "${PILON_NANOPORE_OUT_DIR}" "${NOBACKUP_PILON_NANOPORE}"

module purge
module load Pilon/1.24-Java-17

require_file "${CANU_NANOPORE_FA}"              "Canu Nanopore assembly FASTA"
require_file "${POLISH_NANOPORE_SORTED_BAM}"    "Illumina alignment BAM"
require_file "${POLISH_NANOPORE_SORTED_BAM}.bai" "Illumina alignment BAM index"

total_start=$(date +%s)

echo "[$(current_time)] running Pilon (Nanopore + Illumina)"
echo "[$(current_time)] genome:  ${CANU_NANOPORE_FA}"
echo "[$(current_time)] frags:   ${POLISH_NANOPORE_SORTED_BAM}"
echo "[$(current_time)] output:  ${NOBACKUP_PILON_NANOPORE}/${ORGANISM}_pilon_nanopore"
step_start=$(date +%s)

pilon \
    --genome  "${CANU_NANOPORE_FA}" \
    --frags   "${POLISH_NANOPORE_SORTED_BAM}" \
    --output  "${ORGANISM}_pilon_nanopore" \
    --outdir  "${NOBACKUP_PILON_NANOPORE}" \
    --changes \
    --vcf \
    --minmq   20 \
    --threads 2

echo "[$(current_time)] Pilon complete ($(elapsed_time $step_start))"
echo "[$(current_time)] polished FASTA: ${PILON_NANOPORE_FA}"
echo "[$(current_time)] all steps complete (total: $(elapsed_time $total_start))"
