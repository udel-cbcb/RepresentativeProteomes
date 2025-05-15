#!/bin/sh
if [ -f ../results_corr_consist/completeProteomeSet-seqs-uniprot.fasta.gz ]
then
rm ../results_corr_consist/completeProteomeSet-seqs-uniprot.fasta.gz
fi
perl getRPSeqByAC_uniprot.pl ../results_corr_consist/completeProteomeSet-seqs.txt > ../results_corr_consist/completeProteomeSet-seqs-uniprot.fasta
gzip ../results_corr_consist/completeProteomeSet-seqs-uniprot.fasta
