#cat uniprot_taxonId_hosts.txt |  sed 's/ ([^)]*)//g' | sed 's/\[/ \[/g'   > uniprot_hosts.txt
#wget ftp://ftp.ncbi.nlm.nih.gov/genomes/Viruses/all.gff.tar.gz -O all.gff.tar.gz
#tar -zxvf all.gff.tar.gz
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/viral/assembly_summary.txt -O assembly_summary.txt
perl getNCBIViralFTPPath.pl assembly_summary.txt  | sh
gunzip *.gz
grep nat-host *.gff  > ncbi_viruses_nat-host.txt 
perl getNCBIVirusesHostInfo.pl  ../new_nih_taxID_scientific_name_table ../new_nih_taxID_common_name_table  ncbi_viruses_nat-host.txt > ncbi_virus_host.txt 
perl addUniProtHost.pl ../uniprot_virus_taxId_to_hosts.txt  ncbi_virus_host.txt | sort -u > ncbi_uniprot_hosts.txt
perl createFinalVirusesHosts.pl ../score_inc/proteomeASScores.txt ../uniprot_virus_taxId_to_hosts.txt ncbi_uniprot_hosts.txt > ../ncbiAndUniProtTaxIdToHostNameTaxIdMap.txt


