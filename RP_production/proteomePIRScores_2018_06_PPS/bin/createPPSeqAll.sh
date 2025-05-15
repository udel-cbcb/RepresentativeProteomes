# Get PP seq
perl getPP55BacArc75EukACs.pl ../results_corr_consist/55/pp-55.txt ../results_corr_consist/75/pp-75.txt > ../results_corr_consist/pp-55bac_arch-75euk.txt 

mkdir ../results_corr_consist/PPSeq
cp ../data/PP_readme.txt ../results_corr_consist/PPSeq/readme.txt
#modify release date in ../results_corr_consist/PPSeq/readme.txt
echo -e "PP\tPPMember" > ../results_corr_consist/PPSeq/PPMembership.txt
cat ../results_corr_consist/pp-55bac_arch-75euk.txt | awk -F"\t" '{print $1"\t"$5}' | sort -u >> ../results_corr_consist/PPSeq/PPMembership.txt


perl getPPSeqByAC_uniprot.pl ../results_corr_consist/pp-55bac_arch-75euk.txt ../data/uniprot.fasta  ../results_corr_consist/PPSeq 
tar -zcvf ../results_corr_consist/PPSeq.tar.gz ../results_corr_consist/PPSeq

