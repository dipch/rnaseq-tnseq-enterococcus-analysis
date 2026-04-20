# common preamble/paths for all scripts.

set -euo pipefail

BASE_DIR="${HOME}/rnaseq-tnseq-enterococcus-analysis"
source "${BASE_DIR}/utils/time_check.sh"
source "${BASE_DIR}/utils/fs_check.sh"

trap 'echo "[$(current_time)] ERROR: script exited unexpectedly (exit code $?, line ${LINENO})"' ERR
trap 'echo "[$(current_time)] script finished (exit code $?)"' EXIT

# data
RAW_DIR="${BASE_DIR}/data/raw_data"
TRIMMED_DIR="${BASE_DIR}/data/trimmed_data"
REFERENCE_DIR="${BASE_DIR}/data/reference_genome"

# nobackup
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

# assembly output files
CANU_PACBIO_FA="${CANU_PACBIO_OUT_DIR}/efaecium_e745_pacbio.contigs.fasta"
CANU_NANOPORE_FA="${CANU_NANOPORE_OUT_DIR}/efaecium_e745_nanopore.contigs.fasta"
SPADES_SCAFFOLDS="${SPADES_HYBRID_OUT_DIR}/scaffolds.fasta"
SPADES_CONTIGS="${SPADES_HYBRID_OUT_DIR}/contigs.fasta"

NOBACKUP_CANU_PACBIO="${NOBACKUP_BASE}/canu_pacbio"
NOBACKUP_CANU_NANOPORE="${NOBACKUP_BASE}/canu_nanopore"
NOBACKUP_SPADES_HYBRID="${NOBACKUP_BASE}/spades_hybrid"

# polishing alignment
POLISH_ALIGN_DIR="${ASSEMBLY_DIR}/polishing_pacbio_illumina"
NOBACKUP_POLISH="${NOBACKUP_BASE}/polishing_pacbio_illumina"

# assembly evaluation
EVAL_DIR="${BASE_DIR}/analyses/03_assembly_evaluation"
QUAST_DIR="${EVAL_DIR}/quast"
QUAST_WITH_REFERENCE_DIR="${EVAL_DIR}/quast_with_reference"
BUSCO_DIR_AUTO_LINEAGE="${EVAL_DIR}/busco_auto_lineage"
BUSCO_DIR_MANUAL_LINEAGE="${EVAL_DIR}/busco_manual_lineage"

