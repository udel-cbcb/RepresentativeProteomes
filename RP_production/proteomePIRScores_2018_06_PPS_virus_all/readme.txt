#get taxon id to UP id mapping
grep -v "^Taxon" ../data/proteomes_complete.txt | awk -F"\t" '{print $1"\t"$3}' > ../data/taxIdToUPIdMapping.txt

cp /data/chenc/2018/proteomePIRScores_2018_06_PPS/data/1to1.dat ../data
cp /data/chenc/2018/proteomePIRScores_2018_06_PPS/data/one2one_proteome_ac.txt ../data

grep -v "^Taxon" ../data/proteomes_reference.txt  | awk -F"\t" '{print $3"\t"$1}'  > ../data/refp.tb
 
#get new_nih_taxID_parenttaxID_table 
cp /data/chenc/2018/proteomePIRScores_2018_06_PPS/data/new_nih_taxID_parenttaxID_table ../data
cp /data/chenc/2018/proteomePIRScores_2018_06_PPS/data/new_nih_taxID_scientific_name_table ../data
cp /data/chenc/2018/proteomePIRScores_2018_06_PPS/data/new_nih_taxID_common_name_table ../data
cp /data/chenc/2018/proteomePIRScores_2018_06_PPS/data/taxToTaxGroup.txt ../data
cp /data/chenc/2018/proteomePIRScores_2018_06_PPS/data/noTaxGroup.txt ../data


perl getUPIdToTaxGroup.pl > ../data/upIdAndTaxIdToTaxGroup.txt

perl getUPIdToGORefGenome.pl > ../data/upIdGORefGenome.txt 


nohup perl getScoresInc.pl /data/chenc/2018/proteomePIRScores_2018_05_PPS_virus_all/results_corr_consist/95/rpg-95.txt  > ../logs/score_inc.log  &

nohup perl getScoresIncAll.pl /data/chenc/2018/proteomePIRScores_2018_05_PPS_virus_all/results_corr_consist/95/rpg-95.txt > ../logs/score_inc_all.log & 


ln -s ../data/score_inc ../data/score
#cat ../data/score/*_score.txt | grep -v "^Accession" | awk '{print $1}' | sort -u > ../data/score/proteome_entries.txt
#for a in ../data/score/*_score.txt ; do cat $a | grep -v "^Accession" | awk '{print $1}' | sort -u >> ../data/score/proteome_entries.txt; done
nohup sh get_proteomes_entries.sh 
nohup perl getPMIDAndASScoresInc.pl > ../logs/score_AS.log  &
nohup perl getPMIDAndASScoresIncAll.pl > ../logs/score_all_AS.log &

# create taxIdToSpeciesAndGenusMap
perl getUPIdAndTaxIdToSpeciesAndGenus.pl > ../data/upIdAndTaxIdToSpeciesAndGenus.txt 
perl getUPIdAndTaxIdToTaxonomicRanks.pl > ../data/upIdAndTaxIdToTaxonomicRanks.txt
perl getUPIdAndTaxIdVirusGroup.pl > ../data/upIdAndTaxIdToVirusGroup.txt


nohup perl getHostFromUniProtDat.pl > ../data/uniprot_virus_host.txt 
awk -F"\t" '{print $2"\t"$3"\t"$4}' ../data/uniprot_virus_host.txt | sort -u > ../data/uniprot_virus_taxId_to_hosts.txt
#cat ../data/uniprot_virus_taxId_to_hosts.txt  | sort -u > ../data/virus_taxId_to_hosts.txt
cd ../data/ncbi_viruses
nohup sh runs.sh 
cd ../../bin
perl processPhageVirusHost.pl ../data/new_nih_taxID_scientific_name_table ../data/new_nih_taxID_common_name_table ../data/ncbiAndUniProtTaxIdToHostNameTaxIdMap.txt | sort -u > ../data/virusTaxIdToHostNameTaxIdMap.txt 

grep Viruses /big/chenc/uniprot_data/current/proteomes_complete.txt | awk -F"\t" '{print $1"; "$9}'  | awk -F"; " '{print $1"\t"$3}' | sort -u > ../data/taxonIdToVirusGroup.txt
awk -F"\t" '{print $2}' ../data/taxonIdToVirusGroup.txt | sort -u  > ../data/virus_taxon_group.txt

perl getUPIdAndTaxIdVirusGroupHost.pl > ../data/upIdAndTaxIdToVirusGroupAndHost.txt




#get UniNREF50.tbl
cd ../data
rm uniref50.xml.gz
ln -s /big/wangy/uniprot_data/2018_06/uniref50.xml.gz .
ls -tlr /big/wangy/uniprot_data/2018_05/uniref50.xml.gz
ls -tlr /big/wangy/uniprot_data/2018_06/uniref50.xml.gz
cd ../bin


#get UniRef50 info
nohup perl getUniRef50ByXML.pl  > ../logs/uniref50info.log 
nohup perl getUniRef50ByXMLNo1to1.pl  > ../logs/uniref50info_no1to1.log

#compute correlation table for spot checking
#nohup perl computeProteomeCorrTableMultiThreadsHashMin.pl 20 > ../logs/corr.log 

nohup sh runComputeCorrTableParallel.sh | sh > ../logs/runComputeCorrTableParallel.log &
#nohup sh getCorrTableFromData.sh  &
#nohup sh getCorrTablesFromDataByPerl.sh &
nohup sh catCorrTablesFromDataByPerl.sh &


#compute rpg and pp
#nohup perl processCorrConsistSeedThenRepInc.pl > ../logs/rpCorrConsist.log 

nohup perl processCorrConsistSeedThenRepInc95.pl > ../logs/rpCorrConsist95.log 2>&1 &

awk -F"\t" '{print $2}' ../data/runningRP95.txt | sed 's/\;/\n/g' | grep -v "^$" | wc -l

# Check any taxIds are in separate clusters for RP75 
#grep ">" ../results_corr_consist/75/rpg-75.txt | awk '{print $2}' | sort | uniq -c | awk '$1 > 1'

perl dedupe_upid_bytaxon.pl ../data/score/proteomeScores.txt ../data/runningRP95.txt ../data/runningProteomesScoreHash95.txt ../data/failsafe.list > ../logs/de_dupe.log

mv ../data/runningRP95.txt ../data/runningRP95.txt_dupe
cp ../data/runningRP95.txt.fixed ../data/runningRP95.txt 
mv ../data/runningProteomesScoreHash95.txt ../data/runningProteomesScoreHash95.txt_dupe
cp ../data/runningProteomesScoreHash95.txt.fixed ../data/runningProteomesScoreHash95.txt

nohup perl processCorrConsistSeedThenRepIncNon95.pl > ../logs/rpCorrConsistNon95.log  2>&1 &

grep ">" ../results_corr_consist/95/rpg-95.txt | awk '{print $2}' | sort | uniq -c | awk '$1 > 1'
grep ">" ../results_corr_consist/75/rpg-75.txt | awk '{print $2}' | sort | uniq -c | awk '$1 > 1'
grep ">" ../results_corr_consist/55/rpg-55.txt | awk '{print $2}' | sort | uniq -c | awk '$1 > 1'
grep ">" ../results_corr_consist/35/rpg-35.txt | awk '{print $2}' | sort | uniq -c | awk '$1 > 1'
grep ">" ../results_corr_consist/15/rpg-15.txt | awk '{print $2}' | sort | uniq -c | awk '$1 > 1'

grep ">" ../results_corr_consist/95/rpg-95.txt | wc -l
grep ">" ../results_corr_consist/75/rpg-75.txt | wc -l
grep ">" ../results_corr_consist/55/rpg-55.txt | wc -l
grep ">" ../results_corr_consist/35/rpg-35.txt | wc -l
grep ">" ../results_corr_consist/15/rpg-15.txt | wc -l

grep -v "^$" ../results_corr_consist/95/rpg-95.txt | wc -l
grep -v "^$" ../results_corr_consist/75/rpg-75.txt | wc -l
grep -v "^$" ../results_corr_consist/55/rpg-55.txt | wc -l
grep -v "^$" ../results_corr_consist/35/rpg-35.txt | wc -l
grep -v "^$" ../results_corr_consist/15/rpg-15.txt | wc -l


nohup sh generatePP.sh > ../logs/pp.log &

#get summary table page
# change the uniprot release version number then run the following command
nohup sh getSummaryCorrConsistMin.sh "Release 2018_06 (UP_Viral_all)" 2018_06 ../results_corr_consist > ../results_corr_consist/summary.html

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
 

# get UniProt sequences
nohup sh getUsedCompleteProteomeSeqs_uniprot.sh 
nohup sh getRPSeqs_uniprot.sh 

grep -v "Taxon" ../data/up-taxonomy-complete_yes.tab | awk -F"\t" '{print $1"\t"$2"\t"$3}' > ../results_corr_consist/speclist.txt
grep RefP ../results_corr_consist/95/rpg-95.txt  | awk '{print $1}' | sed 's/>//' | sort -u > ../results_corr_consist/refp.tb
cp ../data/upIdAndTaxIdToTaxGroup.txt ../results_corr_consist/upIdAndTaxIdToTaxGroup.txt
#cp ../data/taxonIdToVirusGroup.txt ../results_corr_consist/
grep -v "^$" ../results_corr_consist/95/rpg-95.txt  | awk -F"\t" '{print $2"\t"$5}' | sort -u > ../results_corr_consist/taxonIdToVirusGroup.txt
cp ../data/virus_taxonomic_group.txt ../results_corr_consist/

# get Used proteomeCorrTable
#cp ../data/proteomesCorrTable.txt ../results_corr_consist/usedProteomesCorrTable.txt
#ssh lysine 'mkdir -p /huge/chenc/2018/pirRPs/proteomePIRScores_2018_06_UP/'
scp -r ../results_corr_consist arginine:/huge/chenc/2018/pirRPs/proteomePIRScores_2018_06_UP/results_corr_consist_virus_all


