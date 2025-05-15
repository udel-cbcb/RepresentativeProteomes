if(@ARGV != 2) {
	print "Usage: perl getNeededCorrData.pl proteomesScore.txt proteomesCorrTable.txt\n";
	exit 1;
}

open(SCORE, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<SCORE>) {
	if($line !~ /UPID/) {
		($upId) = (split(/\t/, $line))[0];
		$usedUPs{$upId} = 1;
	}
}
close(SCORE);

open(CORR, $ARGV[1]) or die "Can't open $ARGV[1]\n";
while($line=<CORR>) {
	($up1, $up2) = (split(/\t/, $line))[0, 1];
	if($usedUPs{$up1} && $usedUPs{$up1}) {
		print $line;
	}
}
close(CORR);

