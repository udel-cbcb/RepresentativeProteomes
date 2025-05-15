open(VG, "../data/upIdAndTaxIdToVirusGroup.txt") or die "Can't open more ../data/upIdAndTaxIdToVirusGroup.txt\n";
while($line=<VG>) {
	($up, $vg) = (split(/\t/, $line))[0, 3];
	$upToVG{$up} = $vg;
}
close(VG);
#>UP000000216	1235689	9CAUD	Pseudomonas phage AF		11101.56736(PPS:1,0,0,1.92,65)	95(CUTOFF)	RefP	100.00000(X-seed)

while($line=<>) {
	if($line !~ /^$/) {
		chomp($line);
		@rec = split(/\t/, $line);
		$up = $rec[0];
		$up =~ s/\s+//;
		$up =~ s/>//;
		
		#$rec[4] = $upToVG{$up};
		print $rec[0]."\t";
		print $rec[1]."\t";
		print $rec[2]."\t";
		print $rec[3]."\t";
		print $upToVG{$up}."\t";
		print $rec[5]."\t";
		print $rec[6]."\t";
		print $rec[7]."\t";
		print $rec[8]."\n";
	}
	else {
		print $line;
	}	
}
