# Get PP seq
perl getPP55BacArc75EukACsNS.pl ../results_corr_consist/55/pp-55.txt ../results_corr_consist/75/pp-75.txt > ../results_corr_consist/pp-55bac_arch-75euk-NS.txt 

mkdir ../results_corr_consist/PPSeq_NS
cp ../data/PP_readme.txt ../results_corr_consist/PPSeq_NS/readme.txt
echo -e "PP\tPPMember" > ../results_corr_consist/PPSeq_NS/PPMembership.txt
cat ../results_corr_consist/pp-55bac_arch-75euk-NS.txt | awk -F"\t" '{print $1"\t"$5}' | sort -u >> ../results_corr_consist/PPSeq_NS/PPMembership.txt


perl getPPSeqByAC_uniprot.pl ../results_corr_consist/pp-55bac_arch-75euk-NS.txt ../data/uniprot.fasta  ../results_corr_consist/PPSeq_NS 
tar -zcvf ../results_corr_consist/PPSeq_NS.tar.gz ../results_corr_consist/PPSeq_NS

