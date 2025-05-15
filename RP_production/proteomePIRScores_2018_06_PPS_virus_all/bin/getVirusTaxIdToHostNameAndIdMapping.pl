#818	Bacteroides thetaiotaomicron;Bacteroides thetaiotaomicron VPI-5482	818;226186
open(IN, "../data/virus_taxId_to_hosts.txt") or die "Can't open ../data/virus_taxId_to_hosts.txt\n";
while($line=<IN>) {
	chomp($line);
	($virusTaxId, $hostNames, $hostTaxIds) = (split(/\t/, $line))[0, 1, 2];
	@hostNameArr = split(/\;/, $hostNames);
	@hostTaxIdArr = split(/\;/, $hostTaxIds);
	for($i = 0; $i < @hostNameArr; $i++) {
		print $virusTaxId."\t".$hostNameArr[$i]."[".$hostTaxIdArr[$i]."]\n";
	}
}
close(IN);
