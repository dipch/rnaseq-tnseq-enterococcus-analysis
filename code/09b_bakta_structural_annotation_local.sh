#!/bin/bash
# Local (macOS) Bakta annotation — run from the repo root with:
#   pixi run bash code/09b_bakta_structural_annotation_local.sh
#
# Prereqs (one-time):
#   pixi add -c bioconda bakta
#   pixi run bakta_db download --output ${HOME}/bakta_db --type full   # or --type light
# Then point BAKTA_DB at the downloaded "db" / "db-light" directory below.

set -euo pipefail

BASE_DIR="${BASE_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "${BASE_DIR}/utils/config.sh"

LOG_DIR="${BASE_DIR}/log"
mkdir -p "${LOG_DIR}"
LOG_FILE="${LOG_DIR}/09b_bakta_structural_annotation_local.$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "${LOG_FILE}") 2>&1
echo "[$(current_time)] logging to ${LOG_FILE}"

# Path to the Bakta database directory (the folder containing version.json).
# Override by exporting BAKTA_DB before running.
BAKTA_DB="${BAKTA_DB:-/Volumes/exfat_730GB/bakta_out/db}"

require_file "${PILON_CANU_PACBIO_R2_FA_LOCAL}" "Canu PacBio Pilon R2 FASTA (local copy)"
require_dir "${BAKTA_DB}" "Bakta database directory (set BAKTA_DB env var if not at default)"

rm -rf "${BAKTA_DIR:?}"
mkdir -p "${BAKTA_DIR}"

CPUS="${CPUS:-$(sysctl -n hw.ncpu 2>/dev/null || echo 4)}"

run_bakta() {
    local label="$1"
    local query_fasta="$2"
    local outdir="${BAKTA_DIR}"

    echo "[$(current_time)] running Bakta for ${label} (threads=${CPUS})"
    local step_start=$(date +%s)

    # --db                : path to Bakta DB (full or light)
    # --genus/species/strain : taxonomy metadata for output records
    # --locus-tag         : prefix for stable locus tags
    # --translation-table 11 : bacterial codon table
    # --gram ?            : Enterococcus is Gram-positive but '?' is safe (skips signal-peptide bias)
    # --compliant         : produce INSDC/ENA-compliant output
    # --keep-contig-headers : keep original FASTA headers (useful for downstream BAM/locus mapping)
    # --force             : overwrite existing output
    bakta \
        --db "${BAKTA_DB}" \
        --output "${outdir}" \
        --prefix "${BAKTA_PREFIX}" \
        --locus-tag "${BAKTA_LOCUS_TAG}" \
        --genus "${PROKKA_GENUS}" \
        --species "${PROKKA_SPECIES}" \
        --strain "${PROKKA_STRAIN}" \
        --translation-table 11 \
        --gram '?' \
        --compliant \
        --keep-contig-headers \
        --threads "${CPUS}" \
        --force \
        "${query_fasta}"

    echo "[$(current_time)] Bakta ${label} complete ($(elapsed_time $step_start))"
    echo "[$(current_time)] outputs: ${outdir}"
}

total_start=$(date +%s)

run_bakta "canu_pacbio_pilon_r2" "${PILON_CANU_PACBIO_R2_FA_LOCAL}"

echo "[$(current_time)] Bakta structural annotation complete (total: $(elapsed_time $total_start))"
