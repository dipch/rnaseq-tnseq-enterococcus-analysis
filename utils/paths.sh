# common preamble/paths for all scripts.
# source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/paths.sh"

BASE_DIR="${HOME}/rnaseq-tnseq-enterococcus-analysis"

set -euo pipefail

trap 'echo "[$(date "+%Y-%m-%d %H:%M:%S")] ERROR: script exited unexpectedly (exit code $?, line ${LINENO})"' ERR
trap 'echo "[$(date "+%Y-%m-%d %H:%M:%S")] script finished (exit code $?)"' EXIT

source "${BASE_DIR}/utils/calculate_elapsed_time.sh"
source "${BASE_DIR}/utils/symlink_check.sh"

# data
RAW_DIR="${BASE_DIR}/data/raw_data"
TRIMMED_DIR="${BASE_DIR}/data/trimmed_data"
REFERENCE_DIR="${BASE_DIR}/data/reference_genome"

# nobackup)
NOBACKUP_BASE="/proj/uppmax2026-1-61/nobackup/work/dich3309"
NOBACKUP_TRIMMED="${NOBACKUP_BASE}/trimmed_data"

# preprocessing
PREPROCESSING_DIR="${BASE_DIR}/analyses/01_preprocessing"
FASTQC_RAW_DIR="${PREPROCESSING_DIR}/fastqc_raw"
MULTIQC_RAW_DIR="${PREPROCESSING_DIR}/multiqc_raw"
FASTQC_TRIMMED_DIR="${PREPROCESSING_DIR}/fastqc_trimmed"
MULTIQC_TRIMMED_DIR="${PREPROCESSING_DIR}/multiqc_trimmed"

# assembly
ASSEMBLY_DIR="${BASE_DIR}/analyses/02_genome_assembly"
CANU_PACBIO_OUT_DIR="${ASSEMBLY_DIR}/canu_pacbio"
CANU_NANOPORE_OUT_DIR="${ASSEMBLY_DIR}/canu_nanopore"
SPADES_HYBRID_OUT_DIR="${ASSEMBLY_DIR}/spades_hybrid"

NOBACKUP_CANU_PACBIO="${NOBACKUP_BASE}/canu_pacbio"
NOBACKUP_CANU_NANOPORE="${NOBACKUP_BASE}/canu_nanopore"
NOBACKUP_SPADES_HYBRID="${NOBACKUP_BASE}/spades_hybrid"

# polishing alignment
POLISH_ALIGN_DIR="${ASSEMBLY_DIR}/polishing_pacbio_illumina"
NOBACKUP_POLISH="${NOBACKUP_BASE}/polishing_pacbio_illumina"

# assembly evaluation
EVAL_DIR="${BASE_DIR}/analyses/03_assembly_evaluation"
QUAST_DIR="${EVAL_DIR}/quast"

