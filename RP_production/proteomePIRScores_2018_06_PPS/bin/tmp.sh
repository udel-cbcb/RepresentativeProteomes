
perl getUPIdToTaxGroup.pl > ../data/upIdAndTaxIdToTaxGroup.txt
perl getUPIdToGORefGenome.pl > ../data/upIdGORefGenome.txt 
# create taxIdToSpeciesAndGenusMap
perl getUPIdAndTaxIdToSpeciesAndGenus.pl > ../data/upIdAndTaxIdToSpeciesAndGenus.txt 
#2015_05 is the previous release, this need to be changed each time.
nohup perl getScoresInc.pl  /data/chenc/2015/proteomePIRScores_2015_05_PPS/results_corr_consist/75/rpg-75.txt > ../logs/score_inc.log 
ln -s ../data/score_inc ../data/score
mkdir ../data/ebi_score/all
perl createEBIScoreALLFile.pl  ../data/up-taxonomy-complete_yes.tab ../data/1to1.dat ../data/ebi_score/score > ../data/ebi_score/all/all_tax.csv
cat ../data/score/*_score.txt | grep -v "^Accession" | awk '{print $1}' | sort -u > ../data/score/proteome_entries.txt
perl getPMIDAndASScoresInc.pl > ../logs/score_AS.log 
cd ../data
ln -s /big/wangy/uniprot_data/2015_05/uniref50.xml.gz .
ls -tlr /big/wangy/uniprot_data/2015_05/uniref50.xml.gz
cd ../bin
#get UniRef50 info
nohup perl getUniRef50ByXML.pl  > ../logs/uniref50info.log 
#compute correlation table for spot checking
nohup perl computeProteomeCorrTableMultiThreadsHashMin.pl 20 > ../logs/corr.log 
#compute rpg and pp
nohup perl processCorrConsistSeedThenRepInc95.pl > ../logs/rpCorrConsist95.log 
nohup perl processCorrConsistSeedThenRepIncNon95.pl > ../logs/rpCorrConsistNon95.log 
