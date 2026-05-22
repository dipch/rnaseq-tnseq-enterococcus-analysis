#!/usr/bin/env Rscript
# DESeq2 differential expression: serum vs BHI (E. faecium E745, Zhang 2017).
#
# Inputs:
#   - HTSeq count matrix (gene_id x sample), produced by code/12_htseq_read_counting.sh
#   - Prokka .tsv (locus_tag -> gene symbol / product), for annotating results
#
# ------------------------------------------------------------------------------
# ASSUMPTIONS — review before trusting results
# ------------------------------------------------------------------------------
#  1. Sample-name parsing: BAM/count files are named `rna_<condition>_rep<N>`.
#     condition is taken verbatim from the second underscore field. If naming
#     changes, COND_FROM_NAME below must change too.
#  2. Reference level = "bhi" (control, rich medium). Serum is the "treatment".
#     log2FoldChange > 0 means UP in serum vs BHI.
#  3. Design = ~condition only. No batch / lane / library covariates were
#     recorded for this dataset; if any exist they would need to be added.
#  4. Significance thresholds: padj < ALPHA (0.05), |log2FC| > LFC_CUTOFF (1).
#     These match the tasklist; loosen LFC_CUTOFF to 0 if you only care about
#     statistical (not effect-size) significance.
#  5. Row IDs in the count matrix are Prokka feature IDs (from htseq `-i ID`,
#     e.g. EFM745_00001). To recover gene symbols (pyrK_2, purD, ...) we join
#     against the Prokka .tsv on `locus_tag`. If htseq was rerun with a
#     different `-i` attribute, this join will be empty.
#  6. LFC shrinkage uses apeglm (recommended for ranking / volcano plots). The
#     unshrunken results are still written to disk.
#  7. The htseq summary rows (__no_feature, __ambiguous, __too_low_aQual,
#     __not_aligned, __alignment_not_unique) are stripped before fitting.
#  8. Independent filtering is left on (DESeq2 default) with alpha = ALPHA.
#  9. No prefiltering by minimum count is applied beyond DESeq2 internals;
#     low-count rows are filtered via independent filtering at results() time.
# ------------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(DESeq2)
  library(ggplot2)
  library(pheatmap)
  library(RColorBrewer)
  library(apeglm)
})

# -------- paths (mirror utils/config.sh) --------
base_dir <- Sys.getenv("BASE_DIR", unset = "")
if (!nzchar(base_dir) || !dir.exists(base_dir)) {
  base_dir <- tryCatch(
    system("git rev-parse --show-toplevel", intern = TRUE),
    error = function(e) getwd())
}

counts_file <- file.path(base_dir, "analyses/07_read_counting/htseq/counts_matrix.tsv")
prokka_tsv  <- file.path(base_dir, "analyses/04_annotation/structural/prokka/efaecium_e745.tsv")
eggnog_tsv  <- file.path(base_dir, "analyses/04_annotation/functional/eggnog/efaecium_e745.emapper.annotations")
out_dir     <- file.path(base_dir, "analyses/08_diff_expression/deseq2")

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(file.path(out_dir, "figures"), showWarnings = FALSE)

# -------- thresholds --------
ALPHA      <- 0.05
LFC_CUTOFF <- 1
N_TOP_HEAT <- 30

# -------- load count matrix --------
stopifnot(file.exists(counts_file))
counts_raw <- read.table(counts_file, header = TRUE, sep = "\t",
                         row.names = 1, check.names = FALSE)

# Drop htseq summary rows.
summary_rows <- grep("^__", rownames(counts_raw), value = TRUE)
counts <- counts_raw[!rownames(counts_raw) %in% summary_rows, , drop = FALSE]
counts <- as.matrix(counts)
mode(counts) <- "integer"

message(sprintf("Loaded %d genes x %d samples (stripped %d summary rows)",
                nrow(counts), ncol(counts), length(summary_rows)))

# Pre-filter: drop genes with very low total counts across all samples.
# Doesn't change DE results (independent filtering would drop these anyway),
# but reduces noise in distribution plots and shrinks output files.
MIN_TOTAL_COUNT <- 10
keep <- rowSums(counts) >= MIN_TOTAL_COUNT
message(sprintf("Pre-filter: keeping %d / %d genes with rowSum >= %d",
                sum(keep), length(keep), MIN_TOTAL_COUNT))
counts <- counts[keep, , drop = FALSE]

# -------- build coldata from sample names --------
# Assumption (1): names look like rna_<condition>_rep<N>
COND_FROM_NAME <- function(s) sub("^rna_([^_]+)_.*$", "\\1", s)
coldata <- data.frame(
  sample    = colnames(counts),
  condition = factor(COND_FROM_NAME(colnames(counts))),
  row.names = colnames(counts)
)
# Assumption (2): BHI is reference.
coldata$condition <- relevel(coldata$condition, ref = "bhi")
print(coldata)
stopifnot(nlevels(coldata$condition) == 2)

# -------- DESeq2 --------
dds <- DESeqDataSetFromMatrix(countData = counts,
                              colData   = coldata,
                              design    = ~ condition)
dds <- DESeq(dds)

res_name <- grep("condition_.*_vs_bhi$", resultsNames(dds), value = TRUE)
stopifnot(length(res_name) == 1)
message("Contrast: ", res_name)

res         <- results(dds, name = res_name, alpha = ALPHA)
res_shrunk  <- lfcShrink(dds, coef = res_name, type = "apeglm")

summary(res)

# -------- annotate with Prokka gene symbols --------
res_df <- as.data.frame(res_shrunk)
res_df$gene_id <- rownames(res_df)
# Keep unshrunken stats too (Wald stat, raw LFC) for transparency.
res_df$log2FoldChange_raw <- as.data.frame(res)[rownames(res_df), "log2FoldChange"]
res_df$stat_raw           <- as.data.frame(res)[rownames(res_df), "stat"]

if (file.exists(prokka_tsv)) {
  prokka <- read.table(prokka_tsv, header = TRUE, sep = "\t",
                       quote = "", comment.char = "", fill = TRUE,
                       stringsAsFactors = FALSE)
  keep_cols <- intersect(c("locus_tag", "gene", "product", "EC_number", "COG"),
                         colnames(prokka))
  prokka <- prokka[, keep_cols, drop = FALSE]
  res_df <- merge(res_df, prokka,
                  by.x = "gene_id", by.y = "locus_tag",
                  all.x = TRUE, sort = FALSE)
} else {
  message("Prokka TSV not found at ", prokka_tsv, " — skipping gene-symbol annotation")
}

# eggNOG functional annotation: COG categories, KEGG pathway IDs, GO terms,
# PFAMs, and eggNOG's Preferred_name (often more complete than Prokka's `gene`).
# The #query column matches Prokka locus_tags directly (verified).
if (file.exists(eggnog_tsv)) {
  egg_raw     <- readLines(eggnog_tsv)
  header_line <- grep("^#query", egg_raw, value = TRUE)[1]
  n_skip      <- sum(grepl("^##", egg_raw))
  egg <- read.table(eggnog_tsv, sep = "\t", header = FALSE,
                    comment.char = "", quote = "", fill = TRUE,
                    stringsAsFactors = FALSE, skip = n_skip)
  colnames(egg) <- unlist(strsplit(sub("^#", "", header_line), "\t"))
  egg <- egg[egg$query != "query", , drop = FALSE]
  egg[egg == "-"] <- NA
  keep_egg <- intersect(c("query", "Preferred_name", "COG_category",
                          "Description", "KEGG_ko", "KEGG_Pathway",
                          "KEGG_Module", "GOs", "PFAMs"),
                        colnames(egg))
  egg <- egg[, keep_egg, drop = FALSE]
  res_df <- merge(res_df, egg,
                  by.x = "gene_id", by.y = "query",
                  all.x = TRUE, sort = FALSE)
  message(sprintf("eggNOG: %d / %d DE-input genes have functional annotation",
                  sum(!is.na(res_df$COG_category)), nrow(res_df)))
} else {
  message("eggNOG annotations not found at ", eggnog_tsv,
          " — skipping functional annotation")
}

# Direction column for downstream filtering / wiki tables.
res_df$direction <- with(res_df,
  ifelse(is.na(padj) | padj >= ALPHA |
         abs(log2FoldChange) <= LFC_CUTOFF, "ns",
  ifelse(log2FoldChange > 0, "up_in_serum", "down_in_bhi_relative")))
# Note: "down_in_bhi_relative" = down in serum vs BHI = higher in BHI.

# Reorder columns and sort by padj.
front <- c("gene_id", "gene", "Preferred_name", "product", "Description",
           "direction",
           "baseMean", "log2FoldChange", "lfcSE",
           "pvalue", "padj", "log2FoldChange_raw", "stat_raw",
           "COG_category", "KEGG_Pathway", "KEGG_ko")
front <- intersect(front, colnames(res_df))
res_df <- res_df[, c(front, setdiff(colnames(res_df), front))]
res_df <- res_df[order(res_df$padj, na.last = TRUE), ]

write.table(res_df,
            file = file.path(out_dir, "deseq2_results_serum_vs_bhi.tsv"),
            sep = "\t", quote = FALSE, row.names = FALSE, na = "")

sig <- subset(res_df,
              !is.na(padj) & padj < ALPHA & abs(log2FoldChange) > LFC_CUTOFF)
write.table(sig,
            file = file.path(out_dir,
                             sprintf("deseq2_significant_padj%.2f_lfc%g.tsv",
                                     ALPHA, LFC_CUTOFF)),
            sep = "\t", quote = FALSE, row.names = FALSE, na = "")
message(sprintf("Significant DEGs (padj<%.2f, |LFC|>%g): %d (up=%d, down=%d)",
                ALPHA, LFC_CUTOFF, nrow(sig),
                sum(sig$log2FoldChange > 0), sum(sig$log2FoldChange < 0)))

# Save normalized counts for downstream / wiki figures.
write.table(counts(dds, normalized = TRUE),
            file = file.path(out_dir, "normalized_counts.tsv"),
            sep = "\t", quote = FALSE, col.names = NA)

# -------- figures --------
fig <- function(name) file.path(out_dir, "figures", name)

# MA plot (shrunken). Data-driven y-limits so strong DEGs aren't clipped —
# bacterial RNA-seq between very different growth media can show |LFC| ~ 8-10.
lfc_finite <- res_shrunk$log2FoldChange[is.finite(res_shrunk$log2FoldChange)]
ma_ylim <- c(-1, 1) * ceiling(max(2, max(abs(lfc_finite), na.rm = TRUE)))
png(fig("ma_plot.png"), width = 1400, height = 1000, res = 200)
plotMA(res_shrunk, ylim = ma_ylim, alpha = ALPHA,
       main = sprintf("MA plot (apeglm-shrunken): serum vs BHI  [ylim = %s]",
                      paste(ma_ylim, collapse = ", ")))
dev.off()

# Volcano plot.
volc_df <- res_df
# Cap -log10(padj) at the largest finite value to keep the y-axis usable when
# DESeq2 returns padj == 0 (machine-precision underflow for very strong DEGs).
volc_df$neglog10p <- -log10(volc_df$padj)
finite_y <- volc_df$neglog10p[is.finite(volc_df$neglog10p)]
y_cap <- if (length(finite_y)) max(finite_y) + 1 else 50
volc_df$neglog10p_capped <- pmin(volc_df$neglog10p, y_cap)
volc_df$is_capped <- is.finite(volc_df$neglog10p) == FALSE &
                     !is.na(volc_df$neglog10p)
volc_df$status <- with(volc_df,
  ifelse(is.na(padj),                                "NA",
  ifelse(padj < ALPHA &  log2FoldChange >  LFC_CUTOFF, "up",
  ifelse(padj < ALPHA &  log2FoldChange < -LFC_CUTOFF, "down", "ns"))))

# Label the strongest hits: large effect AND significant. Cap to ~25 labels
# so the plot stays legible.
LABEL_LFC <- 3
label_df <- subset(volc_df,
                   !is.na(padj) & padj < ALPHA &
                   abs(log2FoldChange) >= LABEL_LFC)
if (nrow(label_df) > 25) {
  label_df <- label_df[order(label_df$padj), ][1:25, ]
}
if ("gene" %in% colnames(label_df)) {
  label_df$label <- ifelse(is.na(label_df$gene) | label_df$gene == "",
                           label_df$gene_id, label_df$gene)
} else {
  label_df$label <- label_df$gene_id
}

has_repel <- requireNamespace("ggrepel", quietly = TRUE)
p_volc <- ggplot(volc_df,
                 aes(log2FoldChange, neglog10p_capped, colour = status)) +
  geom_point(alpha = 0.6, size = 1.3) +
  scale_colour_manual(values = c(up = "#c0392b", down = "#2980b9",
                                 ns = "grey70", `NA` = "grey90")) +
  geom_vline(xintercept = c(-LFC_CUTOFF, LFC_CUTOFF),
             linetype = "dashed", colour = "grey40") +
  geom_hline(yintercept = -log10(ALPHA),
             linetype = "dashed", colour = "grey40") +
  labs(x = "log2 fold change (serum / BHI, shrunken)",
       y = sprintf("-log10(adjusted p-value)%s",
                   if (any(volc_df$is_capped, na.rm = TRUE))
                     sprintf(" [capped at %g]", y_cap) else ""),
       title = "Volcano: serum vs BHI",
       colour = "Status") +
  theme_bw(base_size = 12)

if (has_repel && nrow(label_df) > 0) {
  p_volc <- p_volc +
    ggrepel::geom_text_repel(data = label_df,
                             aes(label = label),
                             size = 3, max.overlaps = 30,
                             colour = "black",
                             min.segment.length = 0)
}
ggsave(fig("volcano.png"), p_volc, width = 7.5, height = 5.5, dpi = 200)

# PCA on vst.
vsd <- vst(dds, blind = FALSE)
p_pca <- plotPCA(vsd, intgroup = "condition") +
  geom_text(aes(label = name), vjust = -0.8, size = 3) +
  theme_bw(base_size = 12) +
  labs(title = "PCA (vst-transformed counts)")
ggsave(fig("pca.png"), p_pca, width = 6.5, height = 5, dpi = 200)

# Sample-distance heatmap.
samp_dist <- dist(t(assay(vsd)))
samp_dist_mat <- as.matrix(samp_dist)
colours <- colorRampPalette(rev(brewer.pal(9, "Blues")))(255)
pheatmap(samp_dist_mat,
         clustering_distance_rows = samp_dist,
         clustering_distance_cols = samp_dist,
         col      = colours,
         filename = fig("sample_distance_heatmap.png"),
         width = 6, height = 5)

# Top-N DEG heatmap (vst, mean-centred).
sig_sorted <- sig[order(sig$padj), ]
top_ids <- head(sig_sorted$gene_id, N_TOP_HEAT)
if (length(top_ids) >= 2) {
  mat <- assay(vsd)[top_ids, , drop = FALSE]
  mat <- mat - rowMeans(mat)
  labels <- ifelse(is.na(sig_sorted$gene[match(top_ids, sig_sorted$gene_id)]) |
                     sig_sorted$gene[match(top_ids, sig_sorted$gene_id)] == "",
                   top_ids,
                   paste0(sig_sorted$gene[match(top_ids, sig_sorted$gene_id)],
                          " (", top_ids, ")"))
  rownames(mat) <- labels
  anno_col <- as.data.frame(colData(dds)[, "condition", drop = FALSE])
  pheatmap(mat,
           annotation_col = anno_col,
           cluster_cols = TRUE,
           filename = fig("top_degs_heatmap.png"),
           width = 8, height = max(6, 0.25 * nrow(mat) + 2))
} else {
  message("Fewer than 2 significant DEGs — skipping top-DEG heatmap.")
}

# Highlight paper genes if found.
# Two tiers, both from Zhang 2017:
#   - "validated": the five genes confirmed by Tn-seq + (for two) zebrafish
#     infection (Abstract + Results sections).
#   - "rnaseq_cluster": the broader gene set highlighted as serum-upregulated
#     in the RNA-seq results (Fig. 3): purine/pyrimidine cluster + PTS
#     subunits + putative regulator.
paper_gene_sets <- list(
  validated = c("pyrK_2", "pyrF", "purD", "purH", "manY_2"),
  rnaseq_cluster = c(
    # purine biosynthesis cluster
    "purD", "purH", "purL", "purQ", "purC", "purA", "guaB",
    # pyrimidine biosynthesis
    "pyrF", "pyrK_2",
    # PTS / carbohydrate uptake
    "manY_2", "ptsL", "manZ_3",
    # putative regulator
    "algB"
  )
)

# Match against BOTH Prokka `gene` and eggNOG `Preferred_name`: Prokka's BLAST
# heuristic occasionally mis-names paralogs (e.g. manY_2 was called sorA_1
# because sorbose/mannose PTS EIIC components are homologous; eggNOG's
# COG-based call corrected this to manY). Strip any `_N` paralog suffix
# before comparing, so "manY" matches "manY_2" and vice versa.
has_pref <- "Preferred_name" %in% colnames(res_df)
strip_suffix <- function(x) sub("_[0-9]+$", "", x)
gene_keys <- if ("gene" %in% colnames(res_df)) strip_suffix(res_df$gene) else NA
pref_keys <- if (has_pref) strip_suffix(res_df$Preferred_name) else NA

if ("gene" %in% colnames(res_df) || has_pref) {
  for (set_name in names(paper_gene_sets)) {
    wanted_stripped <- strip_suffix(paper_gene_sets[[set_name]])
    match_idx <- which((!is.na(gene_keys) & gene_keys %in% wanted_stripped) |
                       (!is.na(pref_keys) & pref_keys %in% wanted_stripped))
    cols <- intersect(c("gene_id", "gene", "Preferred_name", "product",
                        "direction", "log2FoldChange", "padj"),
                      colnames(res_df))
    hits <- res_df[match_idx, cols, drop = FALSE]
    out_path <- file.path(out_dir,
                          sprintf("paper_highlight_%s.tsv", set_name))
    if (nrow(hits) > 0) {
      hits <- hits[order(-abs(hits$log2FoldChange)), ]
      write.table(hits, file = out_path,
                  sep = "\t", quote = FALSE, row.names = FALSE, na = "")
      n_wanted <- length(unique(wanted_stripped))
      n_found  <- length(unique(c(gene_keys[match_idx],
                                  pref_keys[match_idx])) %in% wanted_stripped)
      message(sprintf("Paper-highlight (%s): %d hits, %d unique paper symbols",
                      set_name, nrow(hits),
                      sum(wanted_stripped %in%
                          unique(c(gene_keys, pref_keys)))))
      print(hits)
    } else {
      message(sprintf("Paper-highlight (%s): 0 matches", set_name))
    }
  }
}

# COG-F drill-down: all DE genes assigned to "Nucleotide transport &
# metabolism" by eggNOG. Direct answer to the paper's biology question.
# COG codes are sometimes multi-letter (e.g. "GE"); a gene counts as F if "F"
# appears anywhere in its COG_category string.
if ("COG_category" %in% colnames(res_df)) {
  cog_f_sig <- subset(res_df,
                      !is.na(COG_category) & grepl("F", COG_category) &
                      !is.na(padj) & padj < ALPHA &
                      abs(log2FoldChange) > LFC_CUTOFF)
  if (nrow(cog_f_sig) > 0) {
    cog_f_cols <- intersect(c("gene_id", "gene", "Preferred_name", "product",
                              "Description", "direction",
                              "log2FoldChange", "padj", "COG_category",
                              "KEGG_Pathway"),
                            colnames(cog_f_sig))
    cog_f_sig <- cog_f_sig[order(-cog_f_sig$log2FoldChange), cog_f_cols]
    write.table(cog_f_sig,
                file = file.path(out_dir, "cog_F_nucleotide_metabolism_DE.tsv"),
                sep = "\t", quote = FALSE, row.names = FALSE, na = "")
    message(sprintf("COG-F (nucleotide metabolism) DE genes: %d", nrow(cog_f_sig)))
  } else {
    message("No DE genes assigned to COG category F.")
  }
}

# QC: distribution of log2 normalized counts across samples.
norm_counts <- counts(dds, normalized = TRUE)
log_norm    <- log2(norm_counts + 1)
png(fig("norm_counts_distribution.png"),
    width = 1600, height = 1000, res = 200)
par(mar = c(5, 5, 4, 2))
boxplot(log_norm, las = 2,
        ylab = "log2(normalized counts + 1)",
        main = "Distribution of normalized counts per sample",
        col = ifelse(grepl("serum", colnames(log_norm)), "#e67e22", "#16a085"))
dev.off()

png(fig("norm_counts_histogram.png"),
    width = 1400, height = 1000, res = 200)
hist(as.vector(log_norm), breaks = 100, col = "grey60", border = "white",
     xlab = "log2(normalized counts + 1)",
     main = "Pooled distribution of normalized counts")
dev.off()

# Save session info for reproducibility.
writeLines(capture.output(sessionInfo()),
           file.path(out_dir, "sessionInfo.txt"))

message("Done. Outputs in: ", out_dir)
