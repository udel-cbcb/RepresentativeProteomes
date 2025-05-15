# Get PP seq
rm -rf ../results_corr_consist/PPSeq
rm -rf ../results_corr_consist/PPSeq.tar.gz
rm -rf ../results_corr_consist/PPSeq.tar.gz.md5
mkdir -p ../results_corr_consist/PPSeq
perl getPP55BacArc75FungiACsNSPrev.pl /data/chenc/2017/proteomePIRScores_2017_01_PPS/results_corr_consist/55/pp-55.txt /data/chenc/2017/proteomePIRScores_2017_01_PPS/results_corr_consist/75/pp-75.txt > ../results_corr_consist/pp-55bac_arch-75fungi-NS-Prev.txt 

cp ../data/README ../results_corr_consist/PPSeq/README
echo -e "PP\tPPMember" > ../results_corr_consist/PPSeq/PPMembership.txt
cat ../results_corr_consist/pp-55bac_arch-75fungi-NS-Prev.txt | awk -F"\t" '{print $1"\t"$5}' | sort -u >> ../results_corr_consist/PPSeq/PPMembership.txt


perl getPPSeqByAC_uniprot.pl ../results_corr_consist/pp-55bac_arch-75fungi-NS-Prev.txt ../data/uniprot.fasta  ../results_corr_consist/PPSeq
cd ../results_corr_consist/
tar -zcvf PPSeq.tar.gz PPSeq
md5sum PPSeq.tar.gz > PPSeq.tar.gz.md5

