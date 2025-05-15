rm -rf ../results_corr_consist_rundown
cp -rp ../results_corr_consist ../results_corr_consist_rundown
rm ../results_corr_consist_rundown/*.gz
rm ../results_corr_consist_rundown/*5/*.gz
rm -rf ../results_corr_consist_rundown/PPSeq
rm -rf ../results_corr_consist_rundown/PPSeqCurrent
rm ../results_corr_consist_rundown/PPSeq.tar.gz.md5 
rm ../results_corr_consist_rundown/PPSeqCurrent.tar.gz.md5 

perl getRundown75RPGs.pl ../results_corr_consist/75/rpg-75.txt ../data/rundown.txt > ../results_corr_consist_rundown/75/rpg-75.txt 

perl getRundownRPGs.pl ../data/rundown.txt ../results_corr_consist/75/rpg-75.txt > ../results_corr_consist_rundown/75/rpg-75.txt 
perl getRundownRPGs.pl ../data/rundown.txt ../results_corr_consist/55/rpg-55.txt > ../results_corr_consist_rundown/55/rpg-55.txt 
perl getRundownRPGs.pl ../data/rundown.txt ../results_corr_consist/35/rpg-35.txt > ../results_corr_consist_rundown/35/rpg-35.txt 
perl getRundownRPGs.pl ../data/rundown.txt ../results_corr_consist/15/rpg-15.txt > ../results_corr_consist_rundown/15/rpg-15.txt 

perl getRundownPPs.pl  ../data/rundown.txt ../results_corr_consist/75/pp-75.txt > ../results_corr_consist_rundown/75/pp-75.txt 
perl getRundownPPs.pl  ../data/rundown.txt ../results_corr_consist/55/pp-55.txt > ../results_corr_consist_rundown/55/pp-55.txt 
perl getRundownPPs.pl  ../data/rundown.txt ../results_corr_consist/35/pp-35.txt > ../results_corr_consist_rundown/35/pp-35.txt 
perl getRundownPPs.pl  ../data/rundown.txt ../results_corr_consist/15/pp-15.txt > ../results_corr_consist_rundown/15/pp-15.txt 

#get summary table page
# change the uniprot release version number then run the following command
nohup sh getSummaryCorrConsist_rundown.sh "Release 2018_06" 2018_06 ../results_corr_consist > ../results_corr_consist_rundown/summary.html

cat ../results_corr_consist_rundown/summary.html | sed 's|<a[^>]* href="[^"]*\">||g' | sed 's|<\/a>||g' > ../results_corr_consist_rundown/summary-ftp.html

# get UniProt sequences
nohup sh getUsedCompleteProteomeSeqs_uniprot_rundown.sh 
nohup sh getRPSeqs_uniprot_rundown.sh 

grep -v "Taxon" ../data/up-taxonomy-complete_yes.tab | awk -F"\t" '{print $2"\t"$3}'  | sort -u > ../results_corr_consist_rundown/speclist.txt
grep RefP ../results_corr_consist_rundown/75/rpg-75.txt  | awk '{print $1}' | sed 's/>//' | sort -u > ../results_corr_consist_rundown/refp.tb
cp -p ../data/taxToTaxGroup.txt ../results_corr_consist_rundown/taxToTaxGroup.txt

# get Used proteomeCorrTable
perl getUsedProteomesCorrTab_rundown.pl > ../results_corr_consist_rundown/usedProteomesCorrTable.txt

# create RP55BacArchRP75Euk
perl createRP55ArchBacRP75EukWithBlankLine_rundown.pl ../results_corr_consist_rundown  > ../results_corr_consist_rundown/rpg-55bac_arch-75euk.txt
perl addEBIMeanScoreToPIRRPs_rundown.pl ../data/ebi_score/all/all_tax.csv ../results_corr_consist_rundown/rpg-55bac_arch-75euk.txt > ../results_corr_consist_rundown/rpg-55bac_arch-75euk-ASMean.txt
perl convertRP75And55ToExcel_rundown.pl  ../results_corr_consist_rundown/rpg-55bac_arch-75euk-ASMean.txt  > ../results_corr_consist_rundown/rpg-55bac_arch-75euk-ASMean.xls

# create RP75 CP diff file, "2018_05" is previous release
perl getCPPair_rundown.pl /data/chenc/2018/proteomePIRScores_2018_05_PPS/results_corr_consist_rundown/75/rpg-75.txt ../results_corr_consist_rundown/75/rpg-75.txt ../data/replacedTaxonId.txt  | sort > ../results_corr_consist_rundown/RP75_CP_diff.txt


# Copy results to  /huge/chenc/2018/pirRPs/proteomePIRScores_2018_06_UP, then notify Raja to create RG file,
nohup scp -rp ../results_corr_consist_rundown arginine:/huge/chenc/2018/pirRPs/proteomePIRScores_2018_06_UP/


# Go to lysine.dbi.udel.edu
cd /home/chenc/public_html/pirRPs
mkdir 2018_06
cd 2018_06
ln -s /huge/chenc/2018/pirRPs/proteomePIRScores_2018_06_UP/results_corr_consist 2018_06_UP
ln -s /huge/chenc/2018/pirRPs/proteomePIRScores_2018_06_UP/results_corr_consist_rundown 2018_06_UP_rundown



# If no further feedback from Darren or Raja
# send notification email to EBI 
# Borisas Bursteinas <bburstei@ebi.ac.uk>,Benoit Bely <bbely@ebi.ac.uk>, Alan <alanwilter@gmail.com>, Hongzhan Huang <huang@dbi.udel.edu>
# subject: Representative Proteomes 2015_06 from PIR
#Hi Borisas,
#
#The Representative Proteomes 2015_06 is ready. The file you will need to make Reference Proteomes is at
#
#http://annotation.dbi.udel.edu/rps/2015_05/2015_05_UP/rpg-55bac_arch-75euk-ASMean.txt
#
#Please let me know if you see any problem. 
#
#Thanks,
#
#Chuming 
