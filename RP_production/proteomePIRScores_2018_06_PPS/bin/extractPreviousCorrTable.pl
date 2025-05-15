if(@ARGV != 2) {
	print "Usage: perl extractPreviousCorrTable.pl sameCP.txt previousCorrTable.txt\n";
	exit 1;
}
open(SAME, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<SAME>) {
	chomp($line);
	$same{$line} = 1;
}
close(SAME);

open(COR, $ARGV[1]) or die "Can't open $ARGV[1]\n";
while($line=<COR>) {
	($up_tax1, $up_tax2) = (split(/\t/, $line))[0, 1];
	if($same{$up_tax1} && $same{$up_tax2}) {
		print $line;
	}
}
close(COR);
