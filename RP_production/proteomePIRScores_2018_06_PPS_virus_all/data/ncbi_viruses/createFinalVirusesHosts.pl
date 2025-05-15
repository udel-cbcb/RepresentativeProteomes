if(@ARGV != 3) {
	print "Usage: perl createFinalVirusesHosts.pl proteomeScore.txt uniprot_hosts.txt ncbi_uniprot_hosts.txt\n";
	exit 1;
}

open(SCORE, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<SCORE>) {
	if($line !~ /^UPId/) {
		($upTax) = (split(/\t/, $line))[1];
		$upTaxIds{$upTax} = 1;
	}	
}
close(SCORE);

#1002921	Sus scrofa (Pig)	9823
#1005059	Triticum aestivum (Wheat);Dactylis glomerata (Orchard grass) (Cock's-foot grass)	4565;4509
open(UNIPROT, $ARGV[1]) or die "Can't open $ARGV[1]\n";
while($line=<UNIPROT>) {
	chomp($line);
	($tax, $hosts, $hostsTaxons) = (split(/\t/, $line))[0, 1, 2];
	$tax =~ s/\s+//;	
	@hostsTaxonsRec = split(/\;/, $hostsTaxons);
	@hostsRec = split(/\;/, $hosts);
	$hostStr = ""; 
	for($i= 0; $i < @hostsTaxonsRec; $i++) {
		$hostStr .= $hostsRec[$i]. " [".$hostsTaxonsRec[$i]."]; ";	
	}
	$hostStr =~ s/\; $//;	
	$taxToHosts{$tax} = $hostStr;
}
close(UNIPROT);

#Abaca bunchy top virus	438782	Abaca bunchy top virus	Musa sp.	46838	Musa sp. [46838]
#
open(NCBI, $ARGV[2]) or die "Can't open $ARGV[2]\n";
while($line=<NCBI>) {
	chomp($line);
	($taxId, $hosts) =(split(/\t/, $line))[1, 5];
	$taxId =~ s/\s+//;	
	if($taxToHosts{$taxId} eq "") {
		$taxToHosts{$taxId} = $hosts;	
	}
	else {
		#if($taxToHosts{$taxId} !~ $hosts) {
		#	$taxToHosts{$taxId} .= "; ".$hosts;	
		#}
	}
}
close(NCBI);

for $tax (sort keys %taxToHosts) {
	$upTaxIds{$tax} += 1;
	print $tax."\t".$taxToHosts{$tax}."\n";
}


for $t (keys %upTaxIds) {
	if($upTaxIds{$t} ==1 ) {
		print $t."\t"."\n";
	}
}
