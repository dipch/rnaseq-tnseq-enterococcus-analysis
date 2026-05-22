#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle
#SBATCH -c 4
#SBATCH -t 02:00:00
#SBATCH -J 14_plasmid_identification
#SBATCH --mail-type=ALL
#SBATCH --output=/home/dich3309/rnaseq-tnseq-enterococcus-analysis/log/14_plasmid_identification.%j.out

source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/config.sh"

rm -rf "${PLASMID_DIR:?}"
mkdir -p "${PLASMID_DIR}"

module purge
module load BLAST+/2.17.0-gompi-2024a
module load SAMtools/1.22.1-GCC-13.3.0
module load MUMmer/4.0.1-GCCcore-13.3.0

# Use the polished (Pilon r2) Canu PacBio assembly — same one used downstream
# for Bakta/Prokka annotation. Falls back to the non-polished Canu FASTA if
# the polished one isn't on this host.
ASSEMBLY="${PILON_CANU_PACBIO_R2_FA}"
if [[ ! -s "${ASSEMBLY}" ]]; then
    echo "[$(current_time)] polished assembly not found at ${ASSEMBLY}"
    echo "[$(current_time)] falling back to non-polished Canu PacBio assembly"
    ASSEMBLY="${CANU_PACBIO_FA}"
fi
require_file "${ASSEMBLY}" "Canu PacBio assembly (for plasmid ID)"

BLASTDB="/sw/data/blast_databases/ref_prok_rep_genomes"
SMALL_CONTIGS="${PLASMID_DIR}/small_contigs.fasta"
SMALL_NAMES="${PLASMID_DIR}/small_contig_names.txt"
BLAST_OUT="${PLASMID_DIR}/plasmid_blast_results.tsv"
BLAST_BEST="${PLASMID_DIR}/plasmid_blast_best_hit_per_contig.tsv"
NUCMER_PREFIX="${PLASMID_DIR}/vs_refseq_e745"

total_start=$(date +%s)

# ── 1. Extract plasmid-sized contigs (5–500 kbp) ──────────────────────
echo "[$(current_time)] indexing assembly with samtools faidx"
samtools faidx "${ASSEMBLY}"

echo "[$(current_time)] selecting contigs in [${PLASMID_MIN_SIZE}, ${PLASMID_MAX_SIZE}] bp"
awk -v MIN="${PLASMID_MIN_SIZE}" -v MAX="${PLASMID_MAX_SIZE}" \
    '$2 > MIN && $2 < MAX {print $1"\t"$2}' \
    "${ASSEMBLY}.fai" \
    | sort -k2 -n \
    > "${PLASMID_DIR}/contig_sizes.tsv"

cut -f1 "${PLASMID_DIR}/contig_sizes.tsv" > "${SMALL_NAMES}"
N_CONTIGS=$(wc -l < "${SMALL_NAMES}")
echo "[$(current_time)] ${N_CONTIGS} plasmid-candidate contigs:"
cat "${PLASMID_DIR}/contig_sizes.tsv"

if [[ "${N_CONTIGS}" -eq 0 ]]; then
    echo "[$(current_time)] no plasmid-sized contigs found — exiting"
    exit 0
fi

xargs samtools faidx "${ASSEMBLY}" \
    < "${SMALL_NAMES}" \
    > "${SMALL_CONTIGS}"

# ── 2. BLAST against ref_prok_rep_genomes ─────────────────────────────
echo "[$(current_time)] verifying BLAST database"
blastdbcmd -db "${BLASTDB}" -info | awk 'NR<=5'

echo "[$(current_time)] running blastn (this is the slow step)"
blast_start=$(date +%s)
blastn \
    -query "${SMALL_CONTIGS}" \
    -db "${BLASTDB}" \
    -out "${BLAST_OUT}" \
    -evalue 1e-10 \
    -num_threads 4 \
    -outfmt "6 qseqid sseqid pident length qlen slen evalue bitscore stitle"
echo "[$(current_time)] blastn done ($(elapsed_time $blast_start))"

# Best hit per query contig (highest bitscore).
echo -e "contig\tsubject\tpident\taln_len\tcontig_len\tref_len\tevalue\tbitscore\tdescription" \
    > "${BLAST_BEST}"
sort -k1,1 -k8,8gr "${BLAST_OUT}" \
    | awk '!seen[$1]++' \
    >> "${BLAST_BEST}"

echo "[$(current_time)] best BLAST hit per contig:"
column -t -s $'\t' "${BLAST_BEST}" | head -20

# ── 3. Whole-assembly nucmer vs NCBI RefSeq E745 reference ─────────────
# Confirms which contig corresponds to which paper plasmid (the paper
# deposited E745 to NCBI; the RefSeq assembly has chromosome + 6 plasmids
# as separate records).
if [[ -s "${EFAECIUM_CLINICAL_E745_FASTA}" ]]; then
    echo "[$(current_time)] running nucmer vs NCBI RefSeq E745 reference"
    nucmer_start=$(date +%s)
    nucmer --prefix="${NUCMER_PREFIX}" \
        "${EFAECIUM_CLINICAL_E745_FASTA}" "${ASSEMBLY}"
    # delta-filter: best 1-to-1 mapping, min identity 90%, min length 1 kbp
    delta-filter -1 -i 90 -l 1000 \
        "${NUCMER_PREFIX}.delta" > "${NUCMER_PREFIX}.1delta"
    show-coords -rcl "${NUCMER_PREFIX}.1delta" \
        > "${NUCMER_PREFIX}.coords"
    # Per-query summary: which reference sequence each contig maps to.
    echo "[$(current_time)] per-contig reference assignment:"
    awk 'NR>5 {print $NF, "<-", $(NF-1), "("$5" bp aln, "$7"% id)"}' \
        "${NUCMER_PREFIX}.coords" \
        | sort -u
else
    echo "[$(current_time)] RefSeq E745 reference not at ${EFAECIUM_CLINICAL_E745_FASTA} — skipping nucmer step"
fi

echo "[$(current_time)] plasmid identification complete (total: $(elapsed_time $total_start))"
echo "[$(current_time)] outputs in: ${PLASMID_DIR}"
