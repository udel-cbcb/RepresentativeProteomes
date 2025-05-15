# Get PP seq
rm -rf ../results_corr_consist/PPSeqCurrent
rm -rf ../results_corr_consist/PPSeqCurrent.tar.gz
rm -rf ../results_corr_consist/PPSeqCurrent.tar.gz.md5
mkdir -p ../results_corr_consist/PPSeqCurrent

perl getPP55BacArc75FungiACsNS.pl ../results_corr_consist/55/pp-55.txt ../results_corr_consist/75/pp-75.txt > ../results_corr_consist/pp-55bac_arch-75fungi-NS.txt 
cp ../data/PP_README_PIR ../results_corr_consist/PPSeqCurrent/README
echo -e "PP\tPPMember" > ../results_corr_consist/PPSeqCurrent/PPMembership.txt
cat ../results_corr_consist/pp-55bac_arch-75fungi-NS.txt | awk -F"\t" '{print $1"\t"$5}' | sort -u >> ../results_corr_consist/PPSeqCurrent/PPMembership.txt

perl getPPStats.pl ../results_corr_consist/75/rpg-75.txt ../results_corr_consist/pp-55bac_arch-75fungi-NS.txt > ../results_corr_consist/pp-55bac_arch-75fungi-NS-stats.txt

perl getPPSeqByAC_uniprot.pl ../results_corr_consist/pp-55bac_arch-75fungi-NS.txt ../data/uniprot.fasta  ../results_corr_consist/PPSeqCurrent
cd ../results_corr_consist/
tar -zcvf PPSeqCurrent.tar.gz PPSeqCurrent
md5sum PPSeqCurrent.tar.gz > PPSeqCurrent.tar.gz.md5
cd ..
