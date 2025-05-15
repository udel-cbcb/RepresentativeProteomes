cd bin
# update previous release number then run "createPPSeq4UUWPrevWithVirus.sh" to create PPSeq.tar.gz, README, PPSeq.tar.gz.md5, put into pir20:/www/WWW/html/rps/data/files_for_ebi/PP, then ask Les to upload to EBI
sh createPPSeq4UUWPrevWithVirus.sh

#get taxon id to UP id mapping
grep -v "^Taxon" ../data/proteomes_complete.txt | awk -F"\t" '{print $1"\t"$3}' > ../data/taxIdToUPIdMapping.txt

#get 1to1.dat from PIR16 
cd ../data
cp  /big/chenc/uniprot_data/2018_06/1to1.dat 1to1.dat.orig
awk '$4 ~ "^UP"' 1to1.dat.orig > 1to1.dat

ls -tlr 1to1.dat
ls -tlr /data/chenc/2018/proteomePIRScores_2018_05_PPS/data/1to1.dat

#get one2one_proteome_ac.txt 
awk '{print $1}' 1to1.dat | sort -u > one2one_proteome_ac.txt
cd ../bin
grep -v "^Taxon" ../data/proteomes_reference.txt  | awk -F"\t" '{print $3"\t"$1}'  > ../data/refp.tb

# Go to pir23 run getTaxToTaxGroupMapping.pl and getTaxToTaxGroupMappingWithName.pl
# modify release number in toDBI.sh before run it.
 
#get new_nih_taxID_parenttaxID_table 
cp /big/chenc/peptidematch_data/2018_06/new_nih_taxID_parenttaxID_table ../data/
cp /big/chenc/peptidematch_data/2018_06/new_nih_taxID_scientific_name_table ../data/
cp /big/chenc/peptidematch_data/2018_06/new_nih_taxID_common_name_table ../data/


cp /big/chenc/peptidematch_data/2018_06/taxToTaxGroup.txt ../data/
cp /big/chenc/peptidematch_data/2018_06/noTaxGroup.txt ../data/

perl getUPIdToTaxGroup.pl > ../data/upIdAndTaxIdToTaxGroup.txt

perl getUPIdToGORefGenome.pl > ../data/upIdGORefGenome.txt 

# create taxIdToSpeciesAndGenusMap
perl getUPIdAndTaxIdToSpeciesAndGenus.pl > ../data/upIdAndTaxIdToSpeciesAndGenus.txt 

nohup perl getScoresInc.pl  /data/chenc/2018/proteomePIRScores_2018_05_PPS/results_corr_consist/75/rpg-75.txt > ../logs/score_inc.log &

nohup perl getScoresIncAll.pl /data/chenc/2018/proteomePIRScores_2018_05_PPS/results_corr_consist/75/rpg-75.txt > ../logs/score_inc_all.log &

cd ../data
ln -s score_inc score
cd ../bin
mkdir ../data/ebi_score/all

nohup perl createEBIScoreALLFile.pl  ../data/up-taxonomy-complete_yes.tab ../data/1to1.dat ../data/ebi_score/score > ../data/ebi_score/all/all_tax.csv
cat ../data/score/*_score.txt | grep -v "^Accession" | awk '{print $1}' | sort -u > ../data/score/proteome_entries.txt
nohup perl getPMIDAndASScoresInc.pl > ../logs/score_AS.log & 
nohup perl getPMIDAndASScoresIncAll.pl > ../logs/score_all_AS.log  &


cd ../data
rm uniref50.xml.gz
ln -s /big/wangy/uniprot_data/2018_06/uniref50.xml.gz .
ls -tlr /big/wangy/uniprot_data/2018_06/uniref50.xml.gz
cd ../bin

ls -ltr /big/wangy/uniprot_data/2018_06/uniref50.xml.gz
ls -tlr /big/wangy/uniprot_data/2018_05/uniref50.xml.gz

#get UniRef50 info
nohup perl getUniRef50ByXML.pl  > ../logs/uniref50info.log 
nohup perl getUniRef50ByXMLNo1to1.pl  > ../logs/uniref50info_no1to1.log 

#incremental
nohup perl checkProteomeChanges.pl /data/chenc/2018/proteomePIRScores_2018_05_PPS/data/score ../../proteomePIRScores_2018_06_PPS/data/score > ../data/proteome_changes.txt
nohup perl getSameCorrValues.pl ../data/proteome_changes.txt  /data/chenc/2018/proteomePIRScores_2018_05_PPS/data/proteomesCorrTable.txt > ../data/sameProteomesCorrTable.txt
nohup perl getSameCorrValues.pl ../data/proteome_changes.txt  /data/chenc/2018/proteomePIRScores_2018_05_PPS/data/proteomesCorrTableMin.txt > ../data/sameProteomesCorrTableMin.txt

#incremental multithread
#nohup perl computeProteomeCorrTableMultiThreadsHashMin.pl 20 > ../logs/corr.log

#incremental parallel
#nohup sh runComputeCorrTableParallelInc.sh | sh > ../logs/runComputeCorrTableParallelInc.log &
#go to biomix /home/chenc/rps_wd/2018_06, do run rpcorrinc_srun.sh


cd ../data/corr_data_inc/
nohup cat corr_parallel_*.txt | sort -u > /data/chenc/2018/proteomePIRScores_2018_06_PPS/data/incProteomesCorrTable.txt &
nohup cat min_corr_parallel_*.txt | sort -u > /data/chenc/2018/proteomePIRScores_2018_06_PPS/data/incProteomesCorrTableMin.txt &
cd ../
wc -l sameProteomesCorrTable.txt incProteomesCorrTable.txt
wc -l sameProteomesCorrTableMin.txt incProteomesCorrTableMin.txt
#nohup cat sameProteomesCorrTableMin.txt incProteomesCorrTableMin.txt | sort -u > proteomesCorrTableMin.txt &
#nohup cat sameProteomesCorrTable.txt incProteomesCorrTable.txt | sort -u > proteomesCorrTable.txt &
nohup cat sameProteomesCorrTableMin.txt incProteomesCorrTableMin.txt  > proteomesCorrTableMin.txt &
nohup cat sameProteomesCorrTable.txt incProteomesCorrTable.txt > proteomesCorrTable.txt &
wc -l proteomesCorrTableMin.txt
wc -l proteomesCorrTable.txt
cd ../bin

#incremental



#scp biohen1:/cbcb/chenc/rp_multi_server_corr_table/out/proteomes*.txt ../data/

#sh run_80.sh
#nohup sh runComputeCorrTableParallel.sh | sh > ../logs/runComputeCorrTableParallel.log &
#sh getCorrTableFromData.sh



#compute rpg and pp
nohup perl processCorrConsistSeedThenRepInc95.pl > ../logs/rpCorrConsist95.log 

awk -F"\t" '{print $2}' ../data/runningRP95.txt | sed 's/\;/\n/g' | grep -v "^$" | wc -l

# Check any taxIds are in separate clusters for RP75 
#grep ">" ../results_corr_consist/75/rpg-75.txt | awk '{print $2}' | sort | uniq -c | awk '$1 > 1'

#perl dedupe_upid_bytaxon.pl ../data/score/proteomeScores.txt ../data/runningRP95.txt ../data/runningProteomesScoreHash95.txt > ../logs/de_dupe.log
perl dedupe_upid_bytaxon.pl ../data/score/proteomeScores.txt ../data/runningRP95.txt ../data/runningProteomesScoreHash95.txt ../data/failsafe.list > ../logs/dedupe.log

mv ../data/runningRP95.txt ../data/runningRP95.txt_dupe
cp ../data/runningRP95.txt.fixed ../data/runningRP95.txt 
mv ../data/runningProteomesScoreHash95.txt ../data/runningProteomesScoreHash95.txt_dupe
cp ../data/runningProteomesScoreHash95.txt.fixed ../data/runningProteomesScoreHash95.txt

nohup perl processCorrConsistSeedThenRepIncNon95.pl > ../logs/rpCorrConsistNon95.log 

grep ">" ../results_corr_consist/75/rpg-75.txt | awk '{print $2}' | sort | uniq -c | awk '$1 > 1'
grep ">" ../results_corr_consist/55/rpg-55.txt | awk '{print $2}' | sort | uniq -c | awk '$1 > 1'
grep ">" ../results_corr_consist/35/rpg-35.txt | awk '{print $2}' | sort | uniq -c | awk '$1 > 1'
grep ">" ../results_corr_consist/15/rpg-15.txt | awk '{print $2}' | sort | uniq -c | awk '$1 > 1'

grep ">" ../results_corr_consist/75/rpg-75.txt | wc -l 
grep ">" ../results_corr_consist/55/rpg-55.txt | wc -l
grep ">" ../results_corr_consist/35/rpg-35.txt | wc -l 
grep ">" ../results_corr_consist/15/rpg-15.txt | wc -l

grep -v "^$" ../results_corr_consist/75/rpg-75.txt | wc -l 
grep -v "^$" ../results_corr_consist/55/rpg-55.txt | wc -l
grep -v "^$" ../results_corr_consist/35/rpg-35.txt | wc -l 
grep -v "^$" ../results_corr_consist/15/rpg-15.txt | wc -l

nohup sh generatePP.sh > ../logs/pp.log &

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

# Copy results to /huge
#mkdir -p /huge/chenc/2018/pirRPs/proteomePIRScores_2018_06_UP
ssh lysine "mkdir -p /huge/chenc/2018/pirRPs/proteomePIRScores_2018_06_UP;cd ~chenc/public_html/pirRPs/;mkdir 2018_06;cd 2018_06; ln -s /huge/chenc/2018/pirRPs/proteomePIRScores_2018_06_UP/results_corr_consist 2018_06_UP; ln -s /huge/chenc/2018/pirRPs/proteomePIRScores_2018_06_UP/results_corr_consist_rundown 2018_06_UP_rundown; ln -s /huge/chenc/2018/pirRPs/proteomePIRScores_2018_06_UP/results_corr_consist_virus 2018_06_UP_virus; ln -s /huge/chenc/2018/pirRPs/proteomePIRScores_2018_06_UP/results_corr_consist_virus_all 2018_06_UP_virus_all"
nohup scp -rp ../results_corr_consist arginine:/huge/chenc/2018/pirRPs/proteomePIRScores_2018_06_UP

# Next work on rundown_readme.txt file

