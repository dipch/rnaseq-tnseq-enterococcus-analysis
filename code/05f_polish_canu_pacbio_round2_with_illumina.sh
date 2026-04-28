#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 4
#SBATCH -t 12:00:00
#SBATCH -J 05f_polish_canu_pacbio_round2_with_illumina
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/05f_polish_canu_pacbio_round2_with_illumina.%x.%j.out

# Round 2: input genome is the Pilon R1 polished FASTA.
# Check the R2 .changes file after completion — if near-zero changes, polishing has converged.

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"

mkdir -p "${NOBACKUP_PILON_CANU_PACBIO_R2}"
ensure_nobackup_symlink "${PILON_CANU_PACBIO_R2_DIR}" "${NOBACKUP_PILON_CANU_PACBIO_R2}"

module purge
module load Pilon/1.24-Java-17

require_file "${PILON_CANU_PACBIO_R1_FA}"          "Canu PacBio Pilon R1 FASTA"
require_file "${CANU_PACBIO_SORTED_BAM_R2}"         "Illumina alignment BAM (R2)"
require_file "${CANU_PACBIO_SORTED_BAM_R2}.bai"     "Illumina alignment BAM index (R2)"

total_start=$(date +%s)

echo "[$(current_time)] running Pilon round 2 on Canu PacBio assembly"
pilon \
    --genome  "${PILON_CANU_PACBIO_R1_FA}" \
    --frags   "${CANU_PACBIO_SORTED_BAM_R2}" \
    --output  "${ORGANISM}_canu_pacbio_pilon_r2" \
    --outdir  "${NOBACKUP_PILON_CANU_PACBIO_R2}" \
    --changes \
    --vcf \
    --minmq   20 \
    --threads 4

echo "[$(current_time)] Pilon R2 complete ($(elapsed_time $total_start))"
echo "[$(current_time)] polished FASTA: ${PILON_CANU_PACBIO_R2_FA}"
echo "[$(current_time)] changes file:   ${NOBACKUP_PILON_CANU_PACBIO_R2}/${ORGANISM}_canu_pacbio_pilon_r2.changes"
echo "[$(current_time)] check changes file line count to assess convergence"
wc -l "${NOBACKUP_PILON_CANU_PACBIO_R2}/${ORGANISM}_canu_pacbio_pilon_r2.changes"
