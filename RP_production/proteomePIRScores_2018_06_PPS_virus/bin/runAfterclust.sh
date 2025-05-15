nohup sh generatePP.sh > ../logs/pp.log 

#get summary table page
# change the uniprot release version number then run the following command
nohup sh getSummaryCorrConsistMin.sh "Release 2018_06 (UP_Viral)" 2018_06 ../results_corr_consist > ../results_corr_consist/summary.html

cat ../results_corr_consist/summary.html | sed 's|<a[^>]* href="[^"]*\">||g' | sed 's|<\/a>||g' > ../results_corr_consist/summary-ftp.html

cat ../results_corr_consist/15/pp-15.txt | grep -v "^>" | grep -v "^$" | grep -v "^ #" | awk -F"\t" '{print $1}' | sed 's/ //' | sort -u > ../results_corr_consist/15/pp-seqs-15.txt
cat ../results_corr_consist/35/pp-35.txt | grep -v "^>" | grep -v "^$" | grep -v "^ #" | awk -F"\t" '{print $1}' | sed 's/ //' | sort -u > ../results_corr_consist/35/pp-seqs-35.txt
cat ../results_corr_consist/55/pp-55.txt | grep -v "^>" | grep -v "^$" | grep -v "^ #" | awk -F"\t" '{print $1}' | sed 's/ //' | sort -u > ../results_corr_consist/55/pp-seqs-55.txt
cat ../results_corr_consist/75/pp-75.txt | grep -v "^>" | grep -v "^$" | grep -v "^ #" | awk -F"\t" '{print $1}' | sed 's/ //' | sort -u > ../results_corr_consist/75/pp-seqs-75.txt
cat ../results_corr_consist/95/pp-95.txt | grep -v "^>" | grep -v "^$" | grep -v "^ #" | awk -F"\t" '{print $1}' | sed 's/ //' | sort -u > ../results_corr_consist/95/pp-seqs-95.txt

perl addVirusGroupAndHostToRPG.pl ../data/upIdAndTaxIdToVirusGroupAndHost.txt ../results_corr_consist/95/rpg-95.txt > ../results_corr_consist/95/rpg-95-GroupAndHost.txt
 
perl addVirusGroupAndHostToRPG.pl ../data/upIdAndTaxIdToVirusGroupAndHost.txt ../results_corr_consist/75/rpg-75.txt > ../results_corr_consist/75/rpg-75-GroupAndHost.txt
 
perl addVirusGroupAndHostToRPG.pl ../data/upIdAndTaxIdToVirusGroupAndHost.txt ../results_corr_consist/55/rpg-55.txt > ../results_corr_consist/55/rpg-55-GroupAndHost.txt
 
perl addVirusGroupAndHostToRPG.pl ../data/upIdAndTaxIdToVirusGroupAndHost.txt ../results_corr_consist/35/rpg-35.txt > ../results_corr_consist/35/rpg-35-GroupAndHost.txt
 
perl addVirusGroupAndHostToRPG.pl ../data/upIdAndTaxIdToVirusGroupAndHost.txt ../results_corr_consist/15/rpg-15.txt > ../results_corr_consist/15/rpg-15-GroupAndHost.txt


#perl createRP75ViralWithBlankLine.pl ../results_corr_consist  > ../results_corr_consist/rpg-75viral.txt
perl addEBIMeanScoreToPIRRPs.pl ../data/ebi_score/all/all_tax.csv ../results_corr_consist/75/rpg-75.txt > ../results_corr_consist/rpg-75viral-ASMean.txt
perl convertRP75And55ToExcel.pl  ../results_corr_consist/rpg-75viral-ASMean.txt  > ../results_corr_consist/rpg-75viral-ASMean.xls
 

# get UniProt sequences
nohup sh getUsedCompleteProteomeSeqs_uniprot.sh 
nohup sh getRPSeqs_uniprot.sh 

grep -v "Taxon" ../data/up-taxonomy-complete_yes.tab | awk -F"\t" '{print $1"\t"$2"\t"$3}' > ../results_corr_consist/speclist.txt
grep RefP ../results_corr_consist/95/rpg-95.txt  | awk '{print $1}' | sed 's/>//' | sort -u > ../results_corr_consist/refp.tb
cp ../data/upIdAndTaxIdToTaxGroup.txt ../results_corr_consist/upIdAndTaxIdToTaxGroup.txt
#cp ../data/taxonIdToVirusGroup.txt ../results_corr_consist/
grep -v "^$" ../results_corr_consist/95/rpg-95.txt  | awk -F"\t" '{print $2"\t"$5}' | sort -u > ../results_corr_consist/taxonIdToVirusGroup.txt
cp ../data/virus_taxonomic_group.txt ../results_corr_consist/

perl getPP75VirusACsNS.pl ../results_corr_consist/75/pp-75.txt > ../results_corr_consist/pp-75viral.txt
nohup perl computeCoreAccessoryUniqueProteins.pl ../data/uniref50_ALL.dat ../results_corr_consist/pp-75viral.txt ../results_corr_consist/75/rpg-75.txt  > ../results_corr_consist/rpg-75viral_core_accessory_unqiue_proteins_stats.txt 

scp -r ../results_corr_consist arginine:/huge/chenc/2018/pirRPs/proteomePIRScores_2018_06_UP/results_corr_consist_virus

