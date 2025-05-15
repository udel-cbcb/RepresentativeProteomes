
$virusHost = "../data/virusTaxIdToHostNameTaxIdMap.txt"; 
open(VH, $virusHost) or die "Can't open $virusHost\n";
while($line=<VH>) {
	chomp($line);
	($virusTaxId, $host) = (split(/\t/, $line))[0, 1];
	if($virusTaxId) {
		if($vh{$virusTaxId}) {
			if($vh{$virusTaxId} !~ /$host/) {
				$vh{$virusTaxId} .= "; ".$host;
			}
		}
		else {
			$vh{$virusTaxId} = $host;
		}
	}	
}
close(VH);
#$virusHost = "../data/virus_host.txt";

#open(VH, $virusHost) or die "Can't open $virusHost\n";
#while($line=<VH>) {
#	chomp($line);
#	($taxId, $hostName, $hostTaxId) = (split(/\t/, $line))[0, 1, 2];
#	if($taxId) {
#		@host = split(/\;/, $hostName);
#		@hostId = split(/\;/, $hostTaxId);
#		$vh{$taxId} = $host[0]."(".$hostId[0].")"; 
#		for($i = 1; $i < @host; $i++) {
#			#print "I am here $line\n";
#			$vh{$taxId} .= "; ".$host[$i]."(".$hostId[$i].")"; 
#		}
#	}
#}
#close(VH);

$upIdAndTaxIdToVirusGroup = "../data/upIdAndTaxIdToVirusGroup.txt";

open(VP, $upIdAndTaxIdToVirusGroup) or die "Can't open  $upIdAndTaxIdToVirusGroup\n";
while($line=<VP>) {
	chomp($line);
	($taxId) = (split(/\t/, $line))[1];
	print $line."\t".$vh{$taxId}."\n";	
}
close(VP);
