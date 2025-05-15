if(@ARGV != 2) {
	print "Usage: perl getReferenceProteomeChange.pl oldProteome_reference.txt newProteome_reference.txt\n";
	exit 1;	
}

open(OLD, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<OLD>) {
	if($line !~ /^Taxon/) {
		($up, $tax) = (split(/\t/, $line))[2, 0];
		$allRefPs{$up."\t".$tax} = 1;
		#$oldRPG{$up."\t".$tax} = 1;
	}
}
close(OLD);

open(NEW, $ARGV[1]) or die "Can't open $ARGV[1]\n";
while($line=<NEW>) {
	if($line !~ /^Taxon/) {
		($up, $tax) = (split(/\t/, $line))[2, 0];
		$allRefPs{$up."\t".$tax} += 2;
		#$newRPG{$up."\t".$tax} = 1;
	}
}

for $refp (keys(%allRefPs)) {
	print $refp."\t".$allRefPs{$refp}."\n";
}

