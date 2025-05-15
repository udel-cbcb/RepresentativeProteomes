#nohup grep "^UP" ../logs/corr_parallel_*.txt | awk -F":" '{print $2}'  | sort -u > ../data/corrTable.txt &
#nohup grep "^Min" ../logs/corr_parallel_*.txt | awk -F":" '{print $2}'  | awk -F"\t" '{print $2"\t"$3"\t"$4}' | sort -u > ../data/corrTableMin.txt  &

#nohup cat ../data/corr_parallel_*.txt | sort -u > ../data/corrTable.txt &
#nohup cat ../data/min_corr_parallel_*.txt | sort -u > ../data/corrTableMin.txt  &

nohup cat ../data/corr_data/corr_parallel_*.txt | perl -ne 'print unless $seen{$_}++' > ../data/proteomesCorrTable.txt &
nohup cat ../data/corr_data/min_corr_parallel_*.txt | perl -ne 'print unless $seen{$_}++' > ../data/proteomesCorrTableMin.txt  &
