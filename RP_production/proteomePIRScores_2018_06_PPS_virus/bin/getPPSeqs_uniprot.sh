#!/bin/sh
for cutoff in 15 35 55 75 95 
#for cutoff in 5 
do
if [ -f ../results_corr_consist/$cutoff/pp-seqs-$cutoff-uniprot.fasta.gz ]
then
rm ../results_corr_consist/$cutoff/pp-seqs-$cutoff-uniprot.fasta.gz
fi
perl getRPSeqByAC_uniprot.pl ../results_corr_consist/$cutoff/pp-seqs-$cutoff.txt > ../results_corr_consist/$cutoff/pp-seqs-$cutoff-uniprot.fasta
gzip ../results_corr_consist/$cutoff/pp-seqs-$cutoff-uniprot.fasta
done
