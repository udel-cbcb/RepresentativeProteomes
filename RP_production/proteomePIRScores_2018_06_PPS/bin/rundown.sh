rm -rf ../results_corr_consist_rundown
cp -r ../results_corr_consist ../results_corr_consist_rundown
rm ../results_corr_consist_rundown/*.gz
rm ../results_corr_consist_rundown/*5/*.gz
rm -rf ../results_corr_consist_rundown/PPSeq
rm -rf ../results_corr_consist_rundown/PPSeqCurrent
rm ../results_corr_consist_rundown/PPSeq.tar.gz.md5 
rm ../results_corr_consist_rundown/PPSeqCurrent.tar.gz.md5 

perl getRundown75RPGs.pl ../results_corr_consist/75/rpg-75.txt ../data/rundown.txt > ../results_corr_consist_rundown/75/rpg-75.txt 

perl getRundownRPGs.pl ../data/rundown.txt ../results_corr_consist/75/rpg-75.txt > ../results_corr_consist_rundown/75/rpg-75.txt 
perl getRundownRPGs.pl ../data/rundown.txt ../results_corr_consist/55/rpg-55.txt > ../results_corr_consist_rundown/55/rpg-55.txt 
perl getRundownRPGs.pl ../data/rundown.txt ../results_corr_consist/35/rpg-35.txt > ../results_corr_consist_rundown/35/rpg-35.txt 
perl getRundownRPGs.pl ../data/rundown.txt ../results_corr_consist/15/rpg-15.txt > ../results_corr_consist_rundown/15/rpg-15.txt 

perl getRundownPPs.pl  ../data/rundown.txt ../results_corr_consist/75/pp-75.txt > ../results_corr_consist_rundown/75/pp-75.txt 
perl getRundownPPs.pl  ../data/rundown.txt ../results_corr_consist/55/pp-55.txt > ../results_corr_consist_rundown/55/pp-55.txt 
perl getRundownPPs.pl  ../data/rundown.txt ../results_corr_consist/35/pp-35.txt > ../results_corr_consist_rundown/35/pp-35.txt 
perl getRundownPPs.pl  ../data/rundown.txt ../results_corr_consist/15/pp-15.txt > ../results_corr_consist_rundown/15/pp-15.txt 

#get summary table page
# change the uniprot release version number then run the following command
nohup sh getSummaryCorrConsist_rundown.sh "Release 2018_05" 2018_05 ../results_corr_consist > ../results_corr_consist_rundown/summary.html

cat ../results_corr_consist_rundown/summary.html | sed 's|<a[^>]* href="[^"]*\">||g' | sed 's|<\/a>||g' > ../results_corr_consist_rundown/summary-ftp.html

# get UniProt sequences
nohup sh getUsedCompleteProteomeSeqs_uniprot_rundown.sh 
nohup sh getRPSeqs_uniprot_rundown.sh 

grep -v "Taxon" ../data/up-taxonomy-complete_yes.tab | awk -F"\t" '{print $2"\t"$3}'  | sort -u > ../results_corr_consist_rundown/speclist.txt
grep RefP ../results_corr_consist_rundown/75/rpg-75.txt  | awk '{print $1}' | sed 's/>//' | sort -u > ../results_corr_consist_rundown/refp.tb
cp ../data/taxToTaxGroup.txt ../results_corr_consist_rundown/taxToTaxGroup.txt

# get Used proteomeCorrTable
perl getUsedProteomesCorrTab_rundown.pl > ../results_corr_consist_rundown/usedProteomesCorrTable.txt

# create RP55BacArchRP75Euk
perl createRP55ArchBacRP75EukWithBlankLine_rundown.pl ../results_corr_consist_rundown  > ../results_corr_consist_rundown/rpg-55bac_arch-75euk.txt
perl addEBIMeanScoreToPIRRPs_rundown.pl ../data/ebi_score/all/all_tax.csv ../results_corr_consist_rundown/rpg-55bac_arch-75euk.txt > ../results_corr_consist_rundown/rpg-55bac_arch-75euk-ASMean.txt
perl convertRP75And55ToExcel_rundown.pl  ../results_corr_consist_rundown/rpg-55bac_arch-75euk-ASMean.txt  > ../results_corr_consist_rundown/rpg-55bac_arch-75euk-ASMean.xls

# create RP75 CP diff file, "2018_01" is previous release
perl getCPPair_rundown.pl /data/chenc/2018/proteomePIRScores_2018_06_PPS/results_corr_consist_rundown/75/rpg-75.txt ../results_corr_consist_rundown/75/rpg-75.txt ../data/replacedTaxonId.txt  | sort > ../results_corr_consist_rundown/RP75_CP_diff.txt


