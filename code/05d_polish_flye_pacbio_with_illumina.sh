#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 12:00:00
#SBATCH -J 05d_polish_flye_pacbio_with_illumina
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/05d_polish_flye_pacbio_with_illumina.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"

mkdir -p "${NOBACKUP_PILON_FLYE_PACBIO}"
ensure_nobackup_symlink "${PILON_FLYE_PACBIO_DIR}" "${NOBACKUP_PILON_FLYE_PACBIO}"

module purge
module load Pilon/1.24-Java-17

require_file "${FLYE_PACBIO_FA}"             "Flye PacBio assembly"
require_file "${FLYE_PACBIO_SORTED_BAM}"     "Illumina alignment BAM"
require_file "${FLYE_PACBIO_SORTED_BAM}.bai" "Illumina alignment BAM index"

total_start=$(date +%s)

echo "[$(current_time)] running Pilon on Flye PacBio assembly"
pilon \
    --genome  "${FLYE_PACBIO_FA}" \
    --frags   "${FLYE_PACBIO_SORTED_BAM}" \
    --output  "${ORGANISM}_flye_pacbio_pilon" \
    --outdir  "${NOBACKUP_PILON_FLYE_PACBIO}" \
    --changes \
    --vcf \
    --minmq   20 \
    --threads 2

echo "[$(current_time)] Pilon complete ($(elapsed_time $total_start))"
echo "[$(current_time)] polished FASTA: ${PILON_FLYE_PACBIO_FA}"
echo "[$(current_time)] changes file:   ${NOBACKUP_PILON_FLYE_PACBIO}/${ORGANISM}_flye_pacbio_pilon.changes"
