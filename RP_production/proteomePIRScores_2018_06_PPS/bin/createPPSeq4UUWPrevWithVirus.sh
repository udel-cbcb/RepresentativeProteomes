# Get PP seq
rm -rf ../results_corr_consist/PPSeq
rm -rf ../results_corr_consist/PPSeq.tar.gz
rm -rf ../results_corr_consist/PPSeq.tar.gz.md5
mkdir -p ../results_corr_consist/PPSeq
perl getPP55BacArc75Fungi75ViralACsNSPrev.pl /data/chenc/2018/proteomePIRScores_2018_05_PPS/results_corr_consist/55/pp-55.txt /data/chenc/2018/proteomePIRScores_2018_05_PPS/results_corr_consist/75/pp-75.txt /data/chenc/2018/proteomePIRScores_2018_05_PPS_virus/results_corr_consist/75/pp-75.txt > ../results_corr_consist/pp-55bac_arch-75fungi-75viral-NS-Prev.txt 

cat /data/chenc/2018/proteomePIRScores_2018_05_PPS/results_corr_consist/75/rpg-75.txt /data/chenc/2018/proteomePIRScores_2018_05_PPS_virus/results_corr_consist/75/rpg-75.txt > tmp_rpg.txt
perl getPPStats.pl tmp_rpg.txt ../results_corr_consist/pp-55bac_arch-75fungi-75viral-NS-Prev.txt > ../results_corr_consist/pp-55bac_arch-75fungi-75viral-NS-Prev-stats.txt


cp ../data/README ../results_corr_consist/PPSeq/README
echo -e "PP\tPPMember" > ../results_corr_consist/PPSeq/PPMembership.txt
cat ../results_corr_consist/pp-55bac_arch-75fungi-75viral-NS-Prev.txt | awk -F"\t" '{print $1"\t"$5}' | sort -u >> ../results_corr_consist/PPSeq/PPMembership.txt


perl getPPSeqByAC_uniprot.pl ../results_corr_consist/pp-55bac_arch-75fungi-75viral-NS-Prev.txt ../data/uniprot.fasta  ../results_corr_consist/PPSeq
cd ../results_corr_consist/
tar -zcvf PPSeq.tar.gz PPSeq
md5sum PPSeq.tar.gz > PPSeq.tar.gz.md5

