# TO DO

#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 04:00:00
#SBATCH -J align_canu_pacbio_with_illumina_bowtie2
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/05b_align_canu_pacbio_with_illumina_bowtie2.%x.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"

# all outputs go to nobackup (bam, index, flagstat); symlink into analyses/
mkdir -p "${ASSEMBLY_DIR}" "${NOBACKUP_POLISH_PACBIO}"
ensure_nobackup_symlink "${POLISH_PACBIO_ALIGN_DIR}" "${NOBACKUP_POLISH_PACBIO}"

module purge
module load Bowtie2/2.5.4-GCC-13.3.0
module load SAMtools/1.22.1-GCC-13.3.0

