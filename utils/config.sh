# Shared configuration and paths for all scripts.

set -euo pipefail

BASE_DIR="${BASE_DIR:-${HOME}/rnaseq-tnseq-enterococcus-analysis}"
source "${BASE_DIR}/utils/time_check.sh"
source "${BASE_DIR}/utils/fs_check.sh"

trap 'echo "[$(current_time)] ERROR: script exited unexpectedly (exit code $?, line ${LINENO})"' ERR
trap 'echo "[$(current_time)] script finished (exit code $?)"' EXIT



# Organism (also used for assembly output names and bam file prefix)
ORGANISM="efaecium_e745"

# Estimated genome size — used by Canu (genomeSize) and QUAST (--est-ref-size).
GENOME_SIZE="3.3m"
GENOME_SIZE_BP=3300000

# BUSCO lineage datasets.
BUSCO_LINEAGE_ENTEROCOCCUS="enterococcus_odb12"
BUSCO_LINEAGE_ENTEROCOCCACEAE="enterococcaceae_odb12"

# Input file names / globs relative to RAW_DIR.
ILLUMINA_R1_FILENAME="dna_illumina_R1.fq.gz"
ILLUMINA_R2_FILENAME="dna_illumina_R2.fq.gz"
PACBIO_GLOB="dna_pacbio_*.subreads.fastq.gz"
NANOPORE_GLOB="dna_nanopore_*.fasta.gz"
RNA_GLOB="rna_*_R1.fastq.gz"

# data
RAW_DIR="${BASE_DIR}/data/raw_data"
TRIMMED_DIR="${BASE_DIR}/data/trimmed_data"
REFERENCE_DIR="${BASE_DIR}/data/reference_genome"

# Reference genome accession numbers (NCBI RefSeq)
EFAECIUM_CLINICAL_E745="GCF_001750885.1"
EFAECIUM_COMMUNITY_E980="GCF_000172615.1"
EFAECIUM_COMMUNITY_COM12="GCF_000157635.1"
EFACIUM_CLINICAL_1141733="GCF_000157575.1"
EFACIUM_CLINICAL_TX0133A="GCF_000148285.1"
EFAECALIS_CLINICAL_V583="GCF_000007785.1"
EFAECALIS_COMMUNITY_62="GCF_000211255.2"

# reference genome paths relative to REFERENCE_DIR.
NCBI_DATASET_REFSEQ_DIR="${REFERENCE_DIR}/ncbi_dataset_refseq"
EFAECIUM_CLINICAL_E745_FASTA_REL="ncbi_dataset_refseq/ncbi_dataset/data/${EFAECIUM_CLINICAL_E745}/${EFAECIUM_CLINICAL_E745}_ASM175088v1_genomic.fna"
EFAECIUM_CLINICAL_E745_GFF_REL="ncbi_dataset_refseq/ncbi_dataset/data/${EFAECIUM_CLINICAL_E745}/genomic.gff"

# nobackup (HPC-specific)
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
SPADES_HYBRID_OUT_DIR="${ASSEMBLY_DIR}/spades_hybrid_pacbio_illumina"
SPADES_HYBRID_ISOLATE_OUT_DIR="${ASSEMBLY_DIR}/spades_hybrid_pacbio_illumina_isolate"
SPADES_ILLUMINA_OUT_DIR="${ASSEMBLY_DIR}/spades_illumina"
SPADES_HYBRID_NANOPORE_OUT_DIR="${ASSEMBLY_DIR}/spades_hybrid_nanopore_illumina"
FLYE_PACBIO_OUT_DIR="${ASSEMBLY_DIR}/flye_pacbio"
FLYE_NANOPORE_OUT_DIR="${ASSEMBLY_DIR}/flye_nanopore"

# assembly output files
CANU_PACBIO_FA="${CANU_PACBIO_OUT_DIR}/${ORGANISM}_pacbio.contigs.fasta"
CANU_NANOPORE_FA="${CANU_NANOPORE_OUT_DIR}/${ORGANISM}_nanopore.contigs.fasta"
SPADES_HYBRID_PACBIO_ILLUMINA_SCAFFOLDS="${SPADES_HYBRID_OUT_DIR}/scaffolds.fasta"
SPADES_HYBRID_PACBIO_ILLUMINA_CONTIGS="${SPADES_HYBRID_OUT_DIR}/contigs.fasta"
SPADES_HYBRID_PACBIO_ILLUMINA_ISOLATE_SCAFFOLDS="${SPADES_HYBRID_ISOLATE_OUT_DIR}/scaffolds.fasta"
SPADES_HYBRID_PACBIO_ILLUMINA_ISOLATE_CONTIGS="${SPADES_HYBRID_ISOLATE_OUT_DIR}/contigs.fasta"
SPADES_ILLUMINA_SCAFFOLDS="${SPADES_ILLUMINA_OUT_DIR}/scaffolds.fasta"
SPADES_ILLUMINA_CONTIGS="${SPADES_ILLUMINA_OUT_DIR}/contigs.fasta"
SPADES_HYBRID_NANOPORE_SCAFFOLDS="${SPADES_HYBRID_NANOPORE_OUT_DIR}/scaffolds.fasta"
SPADES_HYBRID_NANOPORE_CONTIGS="${SPADES_HYBRID_NANOPORE_OUT_DIR}/contigs.fasta"
FLYE_PACBIO_FA="${FLYE_PACBIO_OUT_DIR}/assembly.fasta"
FLYE_NANOPORE_FA="${FLYE_NANOPORE_OUT_DIR}/assembly.fasta"

# input reads
ILLUMINA_R1="${RAW_DIR}/${ILLUMINA_R1_FILENAME}"
ILLUMINA_R2="${RAW_DIR}/${ILLUMINA_R2_FILENAME}"

# reference genome — E. faecium clinical isolate E745 (primary assembly target)
EFAECIUM_CLINICAL_E745_FASTA="${REFERENCE_DIR}/${EFAECIUM_CLINICAL_E745_FASTA_REL}"
EFAECIUM_CLINICAL_E745_GFF="${REFERENCE_DIR}/${EFAECIUM_CLINICAL_E745_GFF_REL}"

# nobackup assembly dirs
NOBACKUP_CANU_PACBIO="${NOBACKUP_BASE}/canu_pacbio"
NOBACKUP_CANU_NANOPORE="${NOBACKUP_BASE}/canu_nanopore"
NOBACKUP_SPADES_HYBRID="${NOBACKUP_BASE}/spades_hybrid_pacbio_illumina"
NOBACKUP_SPADES_ILLUMINA="${NOBACKUP_BASE}/spades_illumina"
NOBACKUP_SPADES_HYBRID_NANOPORE="${NOBACKUP_BASE}/spades_hybrid_nanopore_illumina"
NOBACKUP_FLYE_PACBIO="${NOBACKUP_BASE}/flye_pacbio"
NOBACKUP_FLYE_NANOPORE="${NOBACKUP_BASE}/flye_nanopore"

# polishing — Canu PacBio round 1
CANU_PACBIO_ALIGN_R1_DIR="${ASSEMBLY_DIR}/canu_pacbio_align_r1"
NOBACKUP_CANU_PACBIO_ALIGN_R1="${NOBACKUP_BASE}/canu_pacbio_align_r1"
CANU_PACBIO_SORTED_BAM_R1="${NOBACKUP_CANU_PACBIO_ALIGN_R1}/${ORGANISM}_illumina_sorted.bam"
NOBACKUP_PILON_CANU_PACBIO_R1="${NOBACKUP_BASE}/canu_pacbio_pilon_r1"
PILON_CANU_PACBIO_R1_DIR="${ASSEMBLY_DIR}/canu_pacbio_pilon_r1"
PILON_CANU_PACBIO_R1_FA="${NOBACKUP_PILON_CANU_PACBIO_R1}/${ORGANISM}_canu_pacbio_pilon_r1.fasta"

# polishing — Flye PacBio
FLYE_PACBIO_ALIGN_DIR="${ASSEMBLY_DIR}/flye_pacbio_align"
NOBACKUP_FLYE_PACBIO_ALIGN="${NOBACKUP_BASE}/flye_pacbio_align"
FLYE_PACBIO_SORTED_BAM="${NOBACKUP_FLYE_PACBIO_ALIGN}/${ORGANISM}_illumina_sorted.bam"
NOBACKUP_PILON_FLYE_PACBIO="${NOBACKUP_BASE}/flye_pacbio_pilon"
PILON_FLYE_PACBIO_DIR="${ASSEMBLY_DIR}/flye_pacbio_pilon"
PILON_FLYE_PACBIO_FA="${NOBACKUP_PILON_FLYE_PACBIO}/${ORGANISM}_flye_pacbio_pilon.fasta"

# polishing — Canu PacBio round 2 (input: Pilon R1 output)
CANU_PACBIO_ALIGN_R2_DIR="${ASSEMBLY_DIR}/canu_pacbio_align_r2"
NOBACKUP_CANU_PACBIO_ALIGN_R2="${NOBACKUP_BASE}/canu_pacbio_align_r2"
CANU_PACBIO_SORTED_BAM_R2="${NOBACKUP_CANU_PACBIO_ALIGN_R2}/${ORGANISM}_illumina_sorted.bam"
NOBACKUP_PILON_CANU_PACBIO_R2="${NOBACKUP_BASE}/canu_pacbio_pilon_r2"
PILON_CANU_PACBIO_R2_DIR="${ASSEMBLY_DIR}/canu_pacbio_pilon_r2"
PILON_CANU_PACBIO_R2_FA="${NOBACKUP_PILON_CANU_PACBIO_R2}/${ORGANISM}_canu_pacbio_pilon_r2.fasta"

# annotation
ANNOTATION_DIR="${BASE_DIR}/analyses/04_annotation"
PROKKA_DIR="${ANNOTATION_DIR}/structural/prokka"
PROKKA_GFF="${PROKKA_DIR}/${ORGANISM}.gff"
PROKKA_FAA="${PROKKA_DIR}/${ORGANISM}.faa"
PROKKA_FFN="${PROKKA_DIR}/${ORGANISM}.ffn"
PROKKA_GBK="${PROKKA_DIR}/${ORGANISM}.gbk"
PROKKA_TSV="${PROKKA_DIR}/${ORGANISM}.tsv"

# assembly evaluation
EVAL_DIR="${BASE_DIR}/analyses/03_assembly_evaluation"
QUAST_DIR="${EVAL_DIR}/quast"
QUAST_WITH_REFERENCE_DIR="${EVAL_DIR}/quast_with_reference"
QUAST_MULTI_WITH_REFERENCE_DIR="${EVAL_DIR}/quast_multi_with_reference"
BUSCO_DIR_ENTEROCOCCUS="${EVAL_DIR}/busco_enterococcus_odb12"
BUSCO_DIR_ENTEROCOCCACEAE="${EVAL_DIR}/busco_enterococcaceae_odb12"
MUMMER_DIR="${EVAL_DIR}/mummer"

# NCBI download commands for each accession:
# datasets download genome accession GCF_001750885.1 --include gff3,rna,cds,protein,genome,seq-report  # EFAECIUM_CLINICAL_E745
# datasets download genome accession GCF_000172615.1 --include gff3,rna,cds,protein,genome,seq-report  # EFAECIUM_COMMUNITY_E980
# datasets download genome accession GCF_000157635.1 --include gff3,rna,cds,protein,genome,seq-report  # EFAECIUM_COMMUNITY_COM12
# datasets download genome accession GCF_000157575.1 --include gff3,rna,cds,protein,genome,seq-report  # EFACIUM_CLINICAL_1141733
# datasets download genome accession GCF_000148285.1 --include gff3,rna,cds,protein,genome,seq-report  # EFACIUM_CLINICAL_TX0133A
# datasets download genome accession GCF_000007785.1 --include gff3,rna,cds,protein,genome,seq-report  # EFAECALIS_CLINICAL_V583
# datasets download genome accession GCF_000211255.2 --include gff3,rna,cds,protein,genome,seq-report  # EFAECALIS_COMMUNITY_62
