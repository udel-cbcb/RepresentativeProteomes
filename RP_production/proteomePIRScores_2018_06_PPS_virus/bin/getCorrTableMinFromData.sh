nohup cat ../data/corr_data/min_corr_parallel_*.txt | perl -ne 'print unless $seen{$_}++' > ../data/corrTableMin.txt  &
#nohup cat ../data/corr_data/min_corr_parallel_*.txt | uniq -u > ../data/corrTableMin.txt  &
