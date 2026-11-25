# Representative Proteomes

Production pipeline that computes **Representative Proteome Groups (RPGs)** and **Representative Proteomes (RPs)** for UniProt, and the pan proteomes derived from them. It has been run in production with the UniProtKB release cycle since 2012.

## What it computes
A Representative Proteome Group contains similar proteomes, grouped by how often their proteins share UniRef50 clusters (co-membership). The Representative Proteome of a group is the proteome that best represents the sequence space and annotation of all proteomes in the group. Groups are computed at 15%, 35%, 55%, 75% and 95% co-membership thresholds, so users can choose coarser or finer granularity. These groups help select UniProt reference proteomes that cover taxonomic diversity.

For each non-singleton group, the pipeline also builds a **pan proteome**: the sequences of the Representative Proteome plus the unique sequences found only in other members of the group, identified through UniRef50 membership. Pan proteomes are distributed on the UniProt FTP site (`knowledgebase/pan_proteomes`).

## Repository layout
The code in [`RP_production/`](./RP_production/) is the pipeline as used for UniProt release 2018_06, in three configurations:

| Directory | Proteomes |
|---|---|
| `proteomePIRScores_2018_06_PPS` | Archaea, Bacteria and Eukaryota, with pan proteomes |
| `proteomePIRScores_2018_06_PPS_virus` | Viruses, with virus groups and hosts (Chen et al., 2016) |
| `proteomePIRScores_2018_06_PPS_virus_all` | Viruses, alternative configuration of the viral run |

Each directory has `bin/` (Perl modules and scripts, shell drivers) and `data/` (input files and release documentation).

## Pipeline overview
All steps run from a configuration's `bin/` directory.

1. **Proteome co-membership table.** `computeCorrTableParallel.pl` reads UniRef50 (`../data/uniref50.dat`) and computes pairwise co-membership between proteomes, split into parallel jobs (see `run_64.sh`, `run_72.sh`, `run_80.sh` and `runComputeCorrTableParallel.sh`). Incremental versions (`*Inc*.pl`) update the table from the previous release.
2. **Clustering into RPGs.** The `processCorrConsist*.pl` scripts group proteomes at each threshold and select the Representative Proteome of each group, using proteome scores (`getScores*.pl`, `getPMIDAndASScores*.pl`).
3. **Pan proteomes and release files.** `runAfterCluster.sh` builds pan proteomes (`generatePP.sh`, `computePPFromRPG.pl`), summary statistics and sequence files, and reports changes from the previous release (`getRPChange.pl`, `getCPPair.pl`).

## Requirements
- Perl 5 on a Unix system
- A large-memory server: the inputs are full UniRef50 and UniProtKB proteome data
- Input files in `data/`, from the matching UniProt release, including `uniref50.dat` and `up-taxonomy-complete_yes.tab`; the viral configurations also use NCBI viral genome data (`data/ncbi_viruses/`)

Some scripts contain absolute paths from the production servers (for example `/data/...` or the previous release's directory). Edit these to match your environment before running.

## Status
This repository archives the production code. It is not packaged as a general-purpose tool.

## Publications
Chen C, Natale DA, Finn RD, Huang H, Zhang J, Wu CH, Mazumder R. [Representative proteomes: a stable, scalable and unbiased proteome set for sequence analysis and functional annotation](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0018910). *PLoS One*. 2011;6(4):e18910. PMID: 21556138; PMCID: PMC3083393.

Chen C, Huang H, Mazumder R, Natale DA, McGarvey PB, Zhang J, Polson SW, Wang Y, Wu CH; UniProt Consortium. Computational clustering for viral reference proteomes. *Bioinformatics*. 2016;32(13):2041-2043.

## License
To be assigned (MIT intended), copyright University of Delaware.
