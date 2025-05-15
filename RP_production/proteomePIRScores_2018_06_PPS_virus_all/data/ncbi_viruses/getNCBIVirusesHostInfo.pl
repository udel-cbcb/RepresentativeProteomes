#grep nat-host */*  > ncbi_viruses_nat-host.txt
if(@ARGV != 3) {
	print "Usage: perl getNCBIVirusesHostInfo.pl  ../new_nih_taxID_scientific_name_table ../new_nih_taxID_common_name_table ncbi_viruses_nat-host.txt\n";
	exit 1;
}
open(SCINAME, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<SCINAME>) {
	chomp($line);
	@rec = split(/\s+/, $line);
	$taxonId = $rec[0];
	$sciName = "";
	for($i=1; $i < @rec; $i++) {
		$sciName.= $rec[$i]." ";
	}
	$sciName =~ s/^\s+|\s+$//g;
	$taxonIdToSciName{$taxonId} = $sciName;
	$sciNameToTaxonId{$sciName} = $taxonId;
}
close(SCINAME);

open(CNAME, $ARGV[1]) or die "Can't open $ARGV[1]\n";
while($line=<CNAME>) {
	chomp($line);
	@rec = split(/\|/, $line);
	$taxonId = $rec[0];
	$cname = $rec[2];
	#print $taxonId."|".$cname."|\n";
	$taxonIdToCName{$taxonId} = $cname;
	$cnameToTaxonId{$cname} = $taxonId;
}
close(CNAME);
#Abaca_bunchy_top_virus_uid28697/NC_010314.gff:NC_010314.1	RefSeq	region	1	1090	.	+	.	ID=id0;Dbxref=taxon:438782;Is_circular=true;acronym=ABTV;country=Malaysia;gbkey=Src;genome=genomic;isolate=Q767;mol_
#type=genomic DNA;nat-host=Musa sp.;segment=DNA-N
#
open(NAT, $ARGV[2]) or die "Can't open $ARGV[2]\n";
while($line=<NAT>) {
	chomp($line);
	($virus, $attributes) = (split(/\t/, $line))[0, 8];
	($virusName) = (split(/_uid/, $virus))[0];
	$virusName =~ s/_/ /g;
	@rec = split(/\;/, $attributes);
	#Dbxref=ATCC:15692-B1,taxon:151599
	#Dbxref=ATCC:VR-665,taxon:10401
	#Dbxref=taxon:130310,ATCC:VR-1086
	foreach(@rec) {
		if($_ =~ /^Dbxref=/) {
			$taxonId = $_;
			$taxonId =~ s/^Dbxref=//;
			@parts = split(/\,/, $taxonId);
			for($i=0; $i< @parts; $i++) {
				if($parts[$i] =~ /taxon:/) {
					$virusTaxonId = $parts[$i];
					$virusTaxonId =~ s/taxon://;
					#print $line." | ".$virusTaxonId."????\n";
				}
			}	
		}
		if($_ =~ /^nat-host=/) {
			$natHost = $_;
			$natHost =~ s/^nat-host=//;
			#$natHost =~ s/ \([^)]*\)//g;
			
			if($sciNameToTaxonId{$natHost}) {	
				$natHostTaxonId = $sciNameToTaxonId{$natHost};	
			}
			elsif($cnameToTaxonId{$natHost}) {	
				$natHostTaxonId = $cnameToTaxonId{$natHost};	
			}
			#| sed 's/ ([^)]*)//g' | sed 's/\[/ \[/g
				
		}
	}
	print $virusName."\t".$virusTaxonId."\t".$taxonIdToSciName{$virusTaxonId}."\t".$natHost."\t".$natHostTaxonId."\n";
	$natHostTaxonId = "";
}
close(NAT);

