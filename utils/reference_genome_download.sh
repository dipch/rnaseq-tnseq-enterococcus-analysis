#!/usr/bin/env bash
# Requires: datasets (ncbi-datasets-cli)

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${BASE_DIR}/utils/config.sh"

ZIP_FILE="${NCBI_DATASET_REFSEQ_DIR}/ncbi_dataset.zip"

echo "[$(current_time)] removing previous downloads in ${NCBI_DATASET_REFSEQ_DIR}"
rm -rf "${NCBI_DATASET_REFSEQ_DIR:?}"
mkdir -p "${NCBI_DATASET_REFSEQ_DIR}"

echo "[$(current_time)] downloading reference genomes from NCBI"
total_start=$(date +%s)

datasets download genome accession \
    "${EFAECIUM_CLINICAL_E745}" \
    "${EFAECIUM_COMMUNITY_E980}" \
    "${EFAECIUM_COMMUNITY_COM12}" \
    "${EFACIUM_CLINICAL_1141733}" \
    "${EFACIUM_CLINICAL_TX0133A}" \
    "${EFAECALIS_CLINICAL_V583}" \
    "${EFAECALIS_COMMUNITY_62}" \
    --include gff3,rna,cds,protein,genome,seq-report \
    --filename "${ZIP_FILE}"

echo "[$(current_time)] download complete ($(elapsed_time $total_start))"

echo "[$(current_time)] extracting ${ZIP_FILE}"
unzip -o "${ZIP_FILE}" -d "${NCBI_DATASET_REFSEQ_DIR}"

echo "[$(current_time)] verifying extracted accessions:"
ls "${NCBI_DATASET_REFSEQ_DIR}/ncbi_dataset/data/"

echo "[$(current_time)] all done (total: $(elapsed_time $total_start))"
