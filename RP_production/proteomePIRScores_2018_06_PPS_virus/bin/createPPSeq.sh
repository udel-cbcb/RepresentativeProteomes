# Get PP seq
perl getPP55NS.pl ../results_corr_consist/55/pp-55.txt  > ../results_corr_consist/pp-55-NS.txt 

mkdir ../results_corr_consist/PPSeq
cp ../data/PP_readme.txt ../results_corr_consist/PPSeq/readme.txt
echo -e "PP\tPPMember" > ../results_corr_consist/PPSeq/PPMembership.txt
cat ../results_corr_consist/pp-55bac_arch-75euk-NS.txt | awk -F"\t" '{print $1"\t"$5}' | sort -u >> ../results_corr_consist/PPSeq/PPMembership.txt


perl getPPSeqByAC_uniprot.pl ../results_corr_consist/pp-55bac_arch-75euk-NS.txt ../data/uniprot.fasta  ../results_corr_consist/PPSeq 
tar -zcvf ../results_corr_consist/PPSeq.tar.gz ../results_corr_consist/PPSeq

