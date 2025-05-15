nohup sh generatePP.sh > ../logs/pp.log 

#get summary table page
# change the uniprot release version number then run the following command
nohup sh getSummaryCorrConsist.sh "Release 2018_06 (UP)" 2018_06 ../results_corr_consist > ../results_corr_consist/summary.html

cat ../results_corr_consist/summary.html | sed 's|<a[^>]* href="[^"]*\">||g' | sed 's|<\/a>||g' > ../results_corr_consist/summary-ftp.html

# get UniProt sequences
nohup sh getUsedCompleteProteomeSeqs_uniprot.sh 
nohup sh getRPSeqs_uniprot.sh 
grep -v "Taxon" ../data/up-taxonomy-complete_yes.tab | awk -F"\t" '{print $1"\t"$2"\t"$3}' > ../results_corr_consist/speclist.txt
grep RefP ../results_corr_consist/75/rpg-75.txt  | awk '{print $1}' | sed 's/>//' | sort -u > ../results_corr_consist/refp.tb
cp ../data/upIdAndTaxIdToTaxGroup.txt ../results_corr_consist/upIdAndTaxIdToTaxGroup.txt

# get Used proteomeCorrTable
cp ../data/proteomesCorrTable.txt ../results_corr_consist/usedProteomesCorrTable.txt

perl createEBIScoreALLFile.pl  ../data/up-taxonomy-complete_yes.tab ../data/1to1.dat ../data/ebi_score/score > ../data/ebi_score/all/all_tax.csv
perl createRP55ArchBacRP75EukWithBlankLine.pl ../results_corr_consist  > ../results_corr_consist/rpg-55bac_arch-75euk.txt
perl addEBIMeanScoreToPIRRPs.pl ../data/ebi_score/all/all_tax.csv ../results_corr_consist/rpg-55bac_arch-75euk.txt > ../results_corr_consist/rpg-55bac_arch-75euk-ASMean.txt
perl convertRP75And55ToExcel.pl  ../results_corr_consist/rpg-55bac_arch-75euk-ASMean.txt  > ../results_corr_consist/rpg-55bac_arch-75euk-ASMean.xls

grep -v "^$" ../results_corr_consist/rpg-55bac_arch-75euk.txt | wc -l

perl getRPChange.pl /data/chenc/2018/proteomePIRScores_2018_05_PPS/results_corr_consist/rpg-55bac_arch-75euk-ASMean.txt ../results_corr_consist/rpg-55bac_arch-75euk-ASMean.txt > ../logs/RPChange.log


nohup sh createPPSeq4UUW.sh


# create RP75 CP diff file
perl getCPPair.pl /data/chenc/2018/proteomePIRScores_2018_05_PPS/results_corr_consist/75/rpg-75.txt ../results_corr_consist/75/rpg-75.txt ../data/replacedTaxonId.txt  | sort > ../results_corr_consist/RP75_CP_diff.txt

perl getPP55BacArc75EukACs.pl ../results_corr_consist/55/pp-55.txt ../results_corr_consist/75/pp-75.txt > ../results_corr_consist/pp-55bac_arch-75euk.txt 
perl computeCoreAccessoryUniqueProteins.pl ../data/uniref50_ALL.dat ../results_corr_consist/pp-55bac_arch-75euk.txt ../results_corr_consist/rpg-55bac_arch-75euk.txt > ../results_corr_consist/rpg-55bac_arch-75euk-core_accessory_unqiue_proteins_stats.txt

#ssh lysine "mkdir -p /huge/chenc/2018/pirRPs/proteomePIRScores_2018_06_UP;cd ~chenc/public_html/pirRPs/;mkdir 2018_06;cd 2018_06; ln -s /huge/chenc/2018/pirRPs/proteomePIRScores_2018_06_UP/results_corr_consist 2018_06_UP; ln -s /huge/chenc/2018/pirRPs/proteomePIRScores_2018_06_UP/results_corr_consist_rundown 2018_06_UP_rundown; ln -s /huge/chenc/2018/pirRPs/proteomePIRScores_2018_06_UP/results_corr_consist_virus 2018_06_UP_virus; ln -s /huge/chenc/2018/pirRPs/proteomePIRScores_2018_06_UP/results_corr_consist_virus_all 2018_06_UP_virus_all"

nohup scp -rp ../results_corr_consist arginine:/huge/chenc/2018/pirRPs/proteomePIRScores_2018_06_UP
# Copy results to /huge
# Next work on rundown_readme.txt file

