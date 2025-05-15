for i in 15 35 55 75 95
do
echo $i
grep -v "^$" ../results_corr_consist/$i/rpg-$i.txt | wc -l
perl computePPFromRPG.pl ../results_corr_consist/$i/rpg-$i.txt > ../results_corr_consist/$i/pp-$i.txt
perl checkPP.pl ../results_corr_consist/$i/pp-$i.txt
done
