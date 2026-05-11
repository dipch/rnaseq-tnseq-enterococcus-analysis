#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 2
#SBATCH -t 24:00:00
#SBATCH -J 12_htseq_read_counting
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/12_htseq_read_counting.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"

rm -rf "${HTSEQ_DIR:?}"
mkdir -p "${HTSEQ_DIR}"

module purge
module load HTSeq/2.1.2-gfbf-2024a

require_file "${PROKKA_GFF}" "Prokka GFF annotation"
require_dir_nonempty "${NOBACKUP_RNA_MAPPING}" "RNA mapping BAM directory"

# Prokka GFF embeds the genome FASTA after a ##FASTA line — htseq-count's GFF
# parser chokes on it. Strip everything from ##FASTA onward into a clean copy.
CLEAN_GFF="${HTSEQ_DIR}/$(basename "${PROKKA_GFF}" .gff).no_fasta.gff"
echo "[$(current_time)] stripping ##FASTA block from Prokka GFF -> ${CLEAN_GFF}"
awk 'BEGIN{keep=1} /^##FASTA/{keep=0} keep{print}' "${PROKKA_GFF}" > "${CLEAN_GFF}"

BAMS=("${NOBACKUP_RNA_MAPPING}"/rna_*.sorted.bam)
TOTAL=${#BAMS[@]}
file_index=0

total_start=$(date +%s)

# -f bam        : input format
# -r pos        : BAM is position-sorted (from RNA mapping step)
# -s no         : unstranded library (paper used non-stranded RNA-seq)
# -t CDS        : feature type in Prokka GFF (no "exon" in prokaryotic GFFs)
# -i ID         : group counts by the ID attribute (one row per CDS)
# -n 2          : parallel BAM workers (matches SBATCH -c 2)
# --nonunique=none : default; multi-mappers excluded (conservative)
for BAM in "${BAMS[@]}"; do
    SAMPLE=$(basename "${BAM}" .sorted.bam)
    OUT="${HTSEQ_DIR}/${SAMPLE}.counts.tsv"
    file_index=$((file_index + 1))

    echo "[$(current_time)] [sample ${file_index} of ${TOTAL}] counting ${SAMPLE}"
    T0=$(date +%s)
    htseq-count \
        -f bam \
        -r pos \
        -s no \
        -t CDS \
        -i ID \
        -n 2 \
        "${BAM}" "${CLEAN_GFF}" \
        > "${OUT}"
    echo "[$(current_time)] [sample ${file_index} of ${TOTAL}] ${SAMPLE} done ($(elapsed_time $T0))"
done

# Merge per-sample count files into a single matrix.
# Each htseq-count output has two columns: gene_id <TAB> count, with summary
# rows (__no_feature, __ambiguous, etc.) appended at the bottom.
echo "[$(current_time)] merging per-sample counts into matrix: ${HTSEQ_COUNT_MATRIX}"
export HTSEQ_DIR HTSEQ_COUNT_MATRIX
python3 - <<'PY'
import os, glob, sys
htseq_dir = os.environ["HTSEQ_DIR"]
out = os.environ["HTSEQ_COUNT_MATRIX"]
files = sorted(glob.glob(os.path.join(htseq_dir, "rna_*.counts.tsv")))
samples, data, gene_order = [], {}, []
for f in files:
    sample = os.path.basename(f).replace(".counts.tsv", "")
    samples.append(sample)
    data[sample] = {}
    with open(f) as fh:
        for line in fh:
            gene, count = line.rstrip("\n").split("\t")
            data[sample][gene] = count
            if sample == samples[0]:
                gene_order.append(gene)
with open(out, "w") as fh:
    fh.write("gene_id\t" + "\t".join(samples) + "\n")
    for g in gene_order:
        fh.write(g + "\t" + "\t".join(data[s].get(g, "0") for s in samples) + "\n")
print(f"wrote matrix: {out}  ({len(gene_order)} rows, {len(samples)} samples)")
PY

echo "[$(current_time)] HTSeq read counting complete (total: $(elapsed_time $total_start))"
