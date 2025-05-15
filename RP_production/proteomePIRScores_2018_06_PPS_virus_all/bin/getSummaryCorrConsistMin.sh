#!/bin/sh
#!/bin/bash
EXPECTED_ARGS=3
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
        echo "Usage: sh `basename $0` releaseInfo version resultDir"
                exit $E_BADARGS
                fi

echo "<html>"
echo "<head>"
echo "<title>Representative Protoemes</title>"
echo "</head>"
echo "<body>"
echo "<center>"
echo "<h1>Summary of Representative Proteomes</h1>"
echo "<h3>$1</h3>"
perl getBasicStatisticsCorrConsistMin.pl ../data/uniref50.dat $2
echo ""
echo "<table border=1>"
echo "	<tr>"
echo "		<th>Cutoff</th><th>#RPG</th><th>%reduction in #proteomes</th><th>%species in multiple RPGs</th><th>%RPG has multiple genus proteomes</th>" 
echo "<th>%RPG has multiple family proteomes</th>"
echo "<th>%RPG has multiple order proteomes</th>"
echo "<th>%RPG has multiple class proteomes</th>"
echo "<th>%RPG has multiple phylum proteomes</th>"
echo "<th>RP Seq Coverage (%)</th><th>RP UniRef50 Coverage (%)</th>"
echo "	</tr>"
#for i in 15 35 55 75 95 
for i in 95 75 55 35 15 
do
perl getSpeciesGenusRPGStatisticsCorrConsist.pl $3 $i 
perl countRPGMembersCorrConsist.pl $3/$i/rpg-$i.txt > $3/$i/rpgMemberCount-$i.txt
perl getRPSeq.pl $3/$i/rpg-$i.txt | sort -u > $3/$i/rp-seqs-$i.txt
perl getNonRPSeq.pl $3/$i/rpg-$i.txt | sort -u > $3/$i/non-rp-seqs-$i.txt
perl getGORefSeqNotInRP.pl $3/$i/rpg-$i.txt | sort -u > $3/$i/goNotRP-seqs-$i.txt
done
perl getUsedUniProtKBACMin.pl > $3/completeProteomeSet-seqs.txt
if [ ! -d "$3/virus" ]; then
mkdir -p $3/virus
fi
#wget -q -O $3/virus/vp.out "http://www.uniprot.org/uniprot/?query=taxonomy%3aViruses+AND+keyword%3a%22Reference+proteome+%5bKW-1185%5d%22&force=yes&format=tab&columns=id,entry%20name,reviewed,protein%20names,genes,organism,length"
#grep -v Entry $3/virus/vp.out | awk -F"\t" '{print $1}' > $3/virus/virus-seq.txt
echo "</table>"
echo "</td></tr>"
echo "</table>"
echo "</center>"
echo "</body>"
echo "<html>"
