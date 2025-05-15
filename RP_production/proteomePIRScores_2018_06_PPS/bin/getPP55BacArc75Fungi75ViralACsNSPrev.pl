if(@ARGV != 3) {
	print "Usage: perl getPP55BacArc75EukACsNS.pl pp55file pp75file pp75viralfile\n";
	exit 1;
}

open(CP, "../data/proteomes_complete.txt") or die "Can't open ../data/proteomes_complete.txt\n";
while($line=<CP>) {
	if($line !~ /^Taxon/) {
		($tax, $up) = (split(/\t/, $line))[0, 2];
		$cps{$up."-".$tax} = 1;
	}
}
close(CP);

open(MAP, "../data/mapping_accs2upid.txt") or die "Can't open ../data/mapping_accs2upid.txt\n";
while($line=<MAP>) {
#A0A009DWA6     UP000021300     Unassembled WGS sequence
##A0A009DWB1     UP000020680     Unassembled WGS sequence
##A0A009DWB5     UP000021300     Unassembled WGS sequence
	($ac, $up) = (split(/\t/, $line))[0, 1];
     	$upToACs{$up}{$ac} = 1;
}
 close(MAP);

#>Pan-Proteome_UP000000212	1234679	CARML	Carnobacterium maltaromaticum LMA28	Bac/Firmicute	37111.04667(PPS:1,1,1,0,0,3252)	55(CUTOFF)	RefP
# #UP000000212	1234679	3252
#  K8E169	UP000000212	1234679	UniRef50_K8E169

$info = "";
$count = 0;
open(PP55, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<PP55>) {
	chomp($line);
	if($line =~ /^>/) {
		($ppId, $taxId, $taxGroup, $cutoff) = (split(/\t/, $line))[0, 1, 4, 6];
		if($taxGroup =~ /^Bac/ || $taxGroup =~ /^Arch/ || $taxGroup =~ /^Other Archaea/ || $taxGroup =~ /^Other Bacteria/)
		 {
                        $ppId =~ s/^>Pan-Proteome_//;
                        if(!$cps{$ppId."-".$taxId}) {
                                $ppId = "";
                        }
                }
                else {
                        $ppId = "";
                }

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
		($ac, $up) = (split(/\t/, $line))[0,1];
		if($upToACs{$up}{$ac}) {
			$info .= $ppId."\t".$cutoff."\t".$taxGroup."\t".$line."\n";	
		}
	}	
}
close(PP55);

open(PP75, $ARGV[1]) or die "Can't open $ARGV[1]\n";
while($line=<PP75>) {
	chomp($line);
	if($line =~ /^>/) {
		($ppId, $taxId, $taxGroup, $cutoff) = (split(/\t/, $line))[0,1, 4, 6];
		if($taxGroup =~ /^Euk\/Fungi-Metazoa/) 
		 {
                        $ppId =~ s/^>Pan-Proteome_//;
                        if(!$cps{$ppId."-".$taxId}) {
                                $ppId = "";
                        }
                }
                else {
                        $ppId = "";
                }
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
		($ac, $up) = (split(/\t/, $line))[0,1];
		if($upToACs{$up}{$ac}) {
			$info .= $ppId."\t".$cutoff."\t".$taxGroup."\t".$line."\n";	
		}
	}	
}
close(PP75);	

open(PP75Viral, $ARGV[2]) or die "Can't open $ARGV[2]\n";
while($line=<PP75Viral>) {
        chomp($line);
        if($line =~ /^>/) {
                ($ppId, $taxId, $taxGroup, $cutoff) = (split(/\t/, $line))[0,1, 4, 6];
                $ppId =~ s/^>Pan-Proteome_//;
                if(!$cps{$ppId."-".$taxId}) {
                	$ppId = "";
                }
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
                ($ac, $up) = (split(/\t/, $line))[0,1];
                if($upToACs{$up}{$ac}) {
                        $info .= $ppId."\t".$cutoff."\tVirus/".$taxGroup."\t".$line."\n";
                }
        }
}
close(PP75Viral);
