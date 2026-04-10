# rnaseq-tnseq-enterococcus-analysis

## To Do List

### GitHub Repository Setup

- [x] Create GitHub repository (`rnaseq-tnseq-enterococcus-analysis`)
- [x] Initialize with README.md
- [x] Add `.gitignore` and License file
- [x] Set up GitHub Wiki
- [x] Register repository in Studium repository form

### UPPMAX Setup

- [x] Enroll in NAISS database (SUPR) Project
- [x] Apply for UPPMAX account & enable 2FA
- [x] Connect to UPPMAX via SSH
- [x] Set up Git credentials on UPPMAX
- [x] Clone repository to UPPMAX home directory
- [ ] Set up working directory structure

### Gihub Wiki

> **Deadline: 22 May 2026**

- [x] Which paper are you working with
- [x] Project Plan
- [ ] Goal/Hypotheses
- [ ] Section for each analysis (quality control, assembly, RNA mapping, etc.) with explanations on methods, results and a short discussion.
- [ ] Any general thoughts, discussions, speculation, etc. about the project and overall results
- [x] Daily log of each day of work

### Prepare Project Plan on Wiki

> **Deadline: 10 April 2026**

- [x] Tasks
  - [x] Read and Understand the Paper 1 (Zhang et al. 2017) **by 27 Mar 2026**
  - [x] Identify type of data (RNA-seq, Whole Genome Sequencing,
        short-reads/long-reads, etc)
  - [x] Identify biological source of data (tissue, sample etc)
  - [x] Identify how the data was generated (type of libraries, special adapters, potential issues, etc)
  - [x] Create a workflow diagram (input → analysis → output for each step and tools to use) (example in manual)
  - [x] Try to spot steps that can take a long time
  - [x] Introduce a certain degree of flexibility in project plan to account for unexpected results or errors
- [x] Draft project plan addressing:
  - [x] Aim & research questions
  - [x] Type of Sample
  - [x] Types of analyses to be performed and their order
  - [x] Software to be used at each step
  - [x] Time bottlenecks (identify longer running analyses)
  - [x] Time frame for the project
  - [x] Define time checkpoints for finishing certain analysis
  - [x] Type of Data
  - [x] Estimated storage needs
  - [x] Data organisation strategy (Project Organization)

### Organizing working Directory Structure (on UPPMAX)

- [ ] Data and code should be separated
  - [ ] Small data files such as results, figures and text can be included but not big data files
  - [ ] Keep data files with unique and informative names.
  - [ ] keep the raw data with the original names. Use symbolic links that create shortcuts to the original files but that have different names.
  - [ ] Handy to generate folders or file names that start with a number.
  - [ ] Data files especiallly big data files should be compressed. Most tools can handle compressed file and if needed we can uncompress on the file and pipe the output as input
  - [ ] Keep log files of successful

### Gather Metadata

- [ ] Store metadata in a machine readable format (spreadsheet table).
- [ ] The data to include will depend on each experiment.
- [ ] Guidelines
  - [ ] Write one sample per row and one variable per column.
  - [ ] Do not merge cells.
  - [ ] Avoid spaces, use `-` or `_` instead.
  - [ ] Use informative names.
  - [ ] Save data as `.tsv` or `csv` file format

### Getting familiar with data

- The read files are already downloaded, trimmed and in some cases subsampled and named according to their SRA accession which can also be found on the paper.
- [ ] Identify all SRA accession numbers from the paper
- [ ] Go to [NCBI SRA](http://www.ncbi.nlm.nih.gov/sra) and search for SRA accessions of the samples
- [ ] Download metadata file (`SraRunTable.txt`) via "All Runs" → "Download" → "Metadata"
- [ ] Create `sample_information.csv` with columns: `SRA_ID`, `sample_name`, `condition`, `sequencing_type`, `read_type`, `organism`
- [ ] Identify data types:
  - PacBio reads (genome assembly)
  - Illumina paired-end reads (RNA-Seq: serum vs. rich medium)
  - Illumina single-end reads (Tn-Seq)
  - Nanopore reads (if available, for extra analysis)
- [ ] Locate pre-trimmed read files on UPPMAX (provided by course)
- [ ] Create symbolic links with informative names to the data files
