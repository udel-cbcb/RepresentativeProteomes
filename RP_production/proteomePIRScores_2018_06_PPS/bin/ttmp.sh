cd bin
#get taxon id to UP id mapping
grep -v "^Taxon" ../data/proteomes_complete.txt | awk -F"\t" '{print $1"\t"$3}' > ../data/taxIdToUPIdMapping.txt
#get 1to1.dat from PIR16 
cd ../data
scp -p pir16.georgetown.edu:/home/chenc/1to1/1to1.dat 1to1.dat.orig
awk '$4 ~ "^UP"' 1to1.dat.orig > 1to1.dat
#get one2one_proteome_ac.txt 
awk '{print $1}' 1to1.dat | sort -u > one2one_proteome_ac.txt
cd ../bin
grep -v "^Taxon" ../data/proteomes_reference.txt  | awk -F"\t" '{print $3"\t"$1}'  > ../data/refp.tb
 
#get new_nih_taxID_parenttaxID_table 
scp -p pir16.georgetown.edu:/projects/PIR-NREF/taxonomy/new_nih_taxID_parenttaxID_table ../data/
scp -p pir16.georgetown.edu:/projects/PIR-NREF/taxonomy/new_nih_taxID_scientific_name_table ../data/
