if(@ARGV != 1) {
	print "Usage: perl getPP55VirusACsNS.pl pp55file\n";
	exit 1;
}

#>Pan-Proteome_UP000000216	1235689	9CAUD	Pseudomonas phage AF	dsDNA viruses, no RNA stage	27101.19812(PPS:0,1,0,1.77,65)	55(CUTOFF)	
# #UP000000216	1235689	65
#  K4NWH1	UP000000216	1235689	UniRef50_K4NWH1
$info = "";
$count = 0;
open(PP55, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<PP55>) {
	chomp($line);
	if($line =~ /^>/) {
		($ppId, $taxGroup, $cutoff) = (split(/\t/, $line))[0, 4, 6];
		$ppId =~ s/^>Pan-Proteome_//;
	}
	elsif($line =~ /^$/) {
		$ppId = "";
		if($count > 1) {
			print $info;
		}
		$info = "";
		$count = 0;
	}
	elsif($line =~ /^ #/ && $ppId) {
		$count++;
	}
	elsif($line !~ /^ #/ && $ppId) {
		$line =~ s/^\s+//;		
		$line =~ s/\s+$//;	
		$info .= $ppId."\t".$cutoff."\t".$taxGroup."\t".$line."\n";	
	}	
}
close(PP55);
