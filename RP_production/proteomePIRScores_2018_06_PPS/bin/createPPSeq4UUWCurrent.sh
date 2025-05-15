# Get PP seq
perl getPP55BacArc75FungiACsNS.pl ../results_corr_consist/55/pp-55.txt ../results_corr_consist/75/pp-75.txt > ../results_corr_consist/pp-55bac_arch-75fungi-NS.txt 

mkdir ../results_corr_consist/PPSeq
cp ../data/PP_README_PIR ../results_corr_consist/PPSeq/README
echo -e "PP\tPPMember" > ../results_corr_consist/PPSeq/PPMembership.txt
cat ../results_corr_consist/pp-55bac_arch-75fungi-NS.txt | awk -F"\t" '{print $1"\t"$5}' | sort -u >> ../results_corr_consist/PPSeq/PPMembership.txt


perl getPPSeqByAC_uniprot.pl ../results_corr_consist/pp-55bac_arch-75fungi-NS.txt ../data/uniprot.fasta  ../results_corr_consist/PPSeq
tar -zcvf ../results_corr_consist/PPSeq.tar.gz ../results_corr_consist/PPSeq

