if(@ARGV != 2) {
	print "Usage: perl addUniProtHost.pl uniprot_hosts.txt ncbi_virus_host.txt\n";
	exit 1;	
}
open(UNIPROT, $ARGV[0]) or die "Can't open $ARGGV[0]\n";
while($line=<UNIPROT>) {
	chomp($line);
	($taxId, $hosts) = (split(/\t/, $line))[0, 1];
	$uniprotHosts{$taxId} = $hosts;
}
close(UNIPROT); 

#Abaca bunchy top virus	438782	Abaca bunchy top virus	Musa sp.	46838
open(NCBI, $ARGV[1]) or die "Can't open $ARGV[1]\n";
while($line=<NCBI>) {
	chomp($line);
	($taxId, $host, $hostTaxonId) =(split(/\t/, $line))[1, 3, 4];
	if($uniprotHosts{$taxId}) {
		print $line."\t".$uniprotHosts{$taxId}."\n";
	}
	else {
		if($hostTaxonId) {
			print $line."\t".$host." [".$hostTaxonId."]\n";
		}
		else {
			print $line."\n";
		}
	}
}
close(NCBI);
