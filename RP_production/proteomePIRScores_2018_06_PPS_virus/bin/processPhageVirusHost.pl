#ncbiAndUniProtTaxIdToHostNameTaxIdMap.txt
#../data/new_nih_taxID_scientific_name_table
if(@ARGV != 3) {
	print "Usage: perl processPhageVirusHost.pl ../data/new_nih_taxID_scientific_name_table ../data/new_nih_taxID_common_name_table ../data/ncbiAndUniProtTaxIdToHostNameTaxIdMap.txt\n";
	exit 1;
}
open(SCINAME, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<SCINAME>) {
	chomp($line);
	$line =~ s/ /\t/;
	($taxId, $sciName) = (split(/\t/, $line))[0, 1];
	$taxIdToSciName{$taxId} = $sciName;
	$sciNameToTaxId{$sciName} = $taxId;
}
close(SCINAME);

open(CNAME, $ARGV[1]) or die "Can't open $ARGV[1]\n";
while($line=<CNAME>) {
	chomp($line);
	($taxId, $cName) = (split(/\|/, $line))[0, 2];
	$taxIdToCName{$taxId} = $cName;
	$cNameToTaxId{$cName} = $taxId;
}
close(CNAME);

#1000373	Rosellinia necatrix [77044]
#1001263	cotton [3635]
#
open(MAP, $ARGV[2]) or die "Can't open $ARGV[2]\n";
while($line=<MAP>) {
	chomp($line);
	$host = "";
	$hostId = "";
	($tax, $hosts) = (split(/\t/, $line))[0, 1];
	if($hosts) {
		print $line."\n";	
	}
	else {
		$virus = $taxIdToSciName{$tax};
		if(!$virus) {
			$virus = $taxIdToCName{$tax};
		}
		if($virus =~ / phage/i) {
			($host) = (split(/ phage/, $virus));
		}
		$hostId = $sciNameToTaxId{$host};
		if(!$hostId) {
			$hostId = $cNameToTaxId{$host};
		}
		if($host && $hostId) {
			print $tax."\t".$host." [".$hostId."]\n";
		}
		else {
			print $tax."\t\n";
		}
	}
}
close(MAP);
