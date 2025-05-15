if(@ARGV != 2) {
	print "Usage: perl getSameCorrValues.pl proteome_changes.txt proteomeCorrTable.txt\n";
	exit 1;	
}

open(PC, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<PC>) {
	chomp($line);
	($id, $status) = (split(/\t/, $line))[0, 1];
	if($status =~ /same/) {
		$sameProteomes{$id} = 1;
	}	
}
close(PC);

open(PCORR, $ARGV[1]) or die "Can't open $ARGV[1]\n";
while($line=<PCORR>) {
	($id1, $id2) = (split(/\t/, $line))[0, 1];
	if($sameProteomes{$id1} && $sameProteomes{$id2}) {
		print $line;
	}
}
close(PCORR);
