#!/bin/sh
for cutoff in 15 35 55 75 
do
if [ -f ../results_corr_consist_rundown/$cutoff/rp-seqs-$cutoff-uniprot.fasta.gz ]
then
rm ../results_corr_consist_rundown/$cutoff/rp-seqs-$cutoff-uniprot.fasta.gz
fi
cp ../results_corr_consist_rundown/$cutoff/rp-seqs-$cutoff.txt ../results_corr_consist_rundown/$cutoff/rp-seqs-$cutoff-plus.txt
cat ../results_corr_consist_rundown/$cutoff/goNotRP-seqs-$cutoff.txt >> ../results_corr_consist_rundown/$cutoff/rp-seqs-$cutoff-plus.txt
cat ../results_corr_consist_rundown/virus/virus-seq.txt >> ../results_corr_consist_rundown/$cutoff/rp-seqs-$cutoff-plus.txt
perl getRPSeqByAC_uniprot.pl ../results_corr_consist_rundown/$cutoff/rp-seqs-$cutoff-plus.txt > ../results_corr_consist_rundown/$cutoff/rp-seqs-$cutoff-uniprot.fasta
gzip ../results_corr_consist_rundown/$cutoff/rp-seqs-$cutoff-uniprot.fasta
done
