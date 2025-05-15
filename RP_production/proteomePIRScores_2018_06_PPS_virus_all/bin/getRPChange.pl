if(@ARGV != 2) {
	print "Usage: perl getRPChange.pl oldRPG newRPG\n";
	exit 1;	
}

open(OLD, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<OLD>) {
	if($line=~ /^>/) {
		($rp, $tax) = (split(/\t/, $line))[0, 1];
		$allTax{$tax} = 1;
		$oldRPG{$tax}{$rp} = 1;
	}
}
close(OLD);


open(NEW, $ARGV[1]) or die "Can't open $ARGV[1]\n";
while($line=<NEW>) {
	if($line=~ /^>/) {
		($rp, $tax) = (split(/\t/, $line))[0, 1];
		$allTax{$tax} = 1;
		$newRPG{$tax}{$rp} = 1;
	}
}

for $tax (keys(%allTax)) {
	if($oldRPG{$tax} && $newRPG{$tax}) {
		$oldRPGRef = $oldRPG{$tax};
		%oldRPGHash = %$oldRPGRef;
		$oldRPGList = "";
		for $rp (sort keys(%oldRPGHash)) {
			$oldRPGList .= $rp.";";	
		}
		$newRPGRef = $newRPG{$tax};
		%newRPGHash = %$newRPGRef;
		$newRPGList = "";
		for $rp (sort keys(%newRPGHash)) {
			$newRPGList .= $rp.";";	
		}
		if($oldRPGList ne $newRPGList) {
			print $tax."\t".$oldRPGList."\t".$newRPGList."\n";
		}
	}
}
