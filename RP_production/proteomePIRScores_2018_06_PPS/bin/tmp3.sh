#compute rpg and pp
nohup perl processCorrConsistSeedThenRepInc95.pl > ../logs/rpCorrConsist95.log 
# Check any taxIds are in separate clusters for RP75 
#grep ">" ../results_corr_consist/75/rpg-75.txt | awk '{print $2}' | sort | uniq -c | awk '$1 > 1' > check.tmp.log
#NUM=`wc -l check.tmp.log|awk '{print $1}'`
date > curr.date.tmp
pwd >> curr.date.tmp
cat check.tmp.log >> curr.date.tmp
mail -s "$NUM problematic UPID in RP chenc" chenc@dbi.udel.edu < curr.date.tmp
#perl dedupe_95upid_bytaxon.pl ../results_corr_consist/75/rpg-75.txt ../data/score/proteomeScores.txt ../data/runningRP95.txt ../data/runningProteomesScoreHash95.txt > ../logs/de_dupe.log
perl dedupe_upid_bytaxon.pl ../data/score/proteomeScores.txt ../data/runningRP95.txt ../data/runningProteomesScoreHash95.txt
mv ../data/runningRP95.txt ../data/runningRP95.txt_dupe
cp ../data/runningRP95.txt.fixed ../data/runningRP95.txt 
mv ../data/runningProteomesScoreHash95.txt ../data/runningProteomesScoreHash95.txt_dupe
cp ../data/runningProteomesScoreHash95.txt.fixed ../data/runningProteomesScoreHash95.txt
#grep Removed ../logs/de_dupe.log | awk '{print $2}' | sed 's/\;//' | sort -u | awk -F"-" '{print $2"\t"$1}' | sort -u > ../data/dedup_removed_UP.txt
nohup perl processCorrConsistSeedThenRepIncNon95.pl > ../logs/rpCorrConsistNon95.log 
