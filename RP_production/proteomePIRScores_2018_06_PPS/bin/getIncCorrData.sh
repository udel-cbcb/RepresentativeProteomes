cd ../data/corr_data_inc/
nohup cat corr_parallel_*.txt | sort -u > /data/chenc/2018/proteomePIRScores_2018_06_PPS/data/incProteomesCorrTable.txt 
nohup cat min_corr_parallel_*.txt | sort -u > /data/chenc/2018/proteomePIRScores_2018_06_PPS/data/incProteomesCorrTableMin.txt 
cd ../
wc -l sameProteomesCorrTable.txt incProteomesCorrTable.txt
wc -l sameProteomesCorrTableMin.txt incProteomesCorrTableMin.txt
nohup cat sameProteomesCorrTableMin.txt incProteomesCorrTableMin.txt | sort -u > proteomesCorrTableMin.txt 
nohup cat sameProteomesCorrTable.txt incProteomesCorrTable.txt | sort -u > proteomesCorrTable.txt 
wc -l proteomesCorrTableMin.txt
wc -l proteomesCorrTable.txt
cd ../bin
