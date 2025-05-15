#UP000000369	29252	dsDNA viruses	35237	Viruses; dsDNA viruses, no RNA stage; Caudovirales; Myoviridae; Peduovirinae; P2likevirus	Escherichia coli(562)
#
if(@ARGV != 2) {
	print "Usage: perl addVirusGroupAndHostToRPG.pl upIdAndTaxIdToVirusGroupAndHost.txt rpg.txt\n";
	exit 1; 
}
open(VGH, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<VGH>) {
	chomp($line);
	@rec = split(/\t/, $line);
	$vgh{$rec[0]."\t".$rec[1]} = $rec[3]."\t".$rec[4]."\t".$rec[6];
}
close(VGH);

open(RPG, $ARGV[1]) or die "Can't open $ARGV[1]\n";
while($line=<RPG>) {
	if($line =~ /^$/) {
		print $line;
	}
	else {
		chomp($line);
		@rec = split(/\t/, $line);
		$upTaxId = $rec[0]."\t".$rec[1];
		$upTaxId =~ s/^\>//;
		$upTaxId =~ s/^\s+//;
		print $line."\t".$vgh{$upTaxId}."\n";
	}	
}
close(RPG);

