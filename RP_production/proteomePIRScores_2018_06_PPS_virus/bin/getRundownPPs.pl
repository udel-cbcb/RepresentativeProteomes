#>Pan-Proteome_UP000000214	1171373	PROA4	Propionibacterium acidipropionici (strain ATCC 4875 / DSM 20272 / JCM 6432 / NBRC 12425 / NCIMB 8070)	Bac/ActnBac	19111.04918(PPS:0
#,0,0,3291)	75(CUTOFF)	
# #UP000000214	1171373	3291
#  K7RJ21	UP000000214	1171373	UniRef50_Q6ABL5
#
if(@ARGV != 2) {
	print "Usage: perl getRundownPPs.pl rundown.txt pp.txt > rundown_pp.txt\n";
	exit 1;
}

open(RUNDOWN, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<RUNDOWN>) {
        chomp($line);
        ($up, $tax) = (split(/\t/, $line))[0, 1];
        $rundown{$up."-".$tax} = 1;
        $rundowntab{$line} = 1;
}
close(RUNDOWN);

open(PP, $ARGV[1]) or die "Can't open $ARGV[1]\n";
while($line=<PP>) {
	if($line =~ /^\>/) {
		($up, $tax) = (split(/\t/, $line))[0, 1];
		$up =~ s/^\>Pan-Proteome_//;
		if(!$rundown{$up."-".$tax}) {
			chomp($line);
			@rec = split(/\t/, $line);
			print ">".$rec[1];;
			for($i=2; $i < @rec; $i++) {
				print "\t".$rec[$i];
			}
			print "\n";
		}	
	}
	elsif($line =~ /^ #/) {
		($up, $tax) = (split(/\t/, $line))[0, 1];
		$up =~ s/^ \#//;
		if(!$rundown{$up."-".$tax}) {
			chomp($line);
			@rec = split(/\t/, $line);
			print " #".$rec[1];
			for($i=2; $i < @rec; $i++) {
				print "\t".$rec[$i];
			}
			print "\n";
		}	
	}
	elsif($line !~ /^$/) {
		($up, $tax) = (split(/\t/, $line))[1, 2];
		if(!$rundown{$up."-".$tax}) {
			chomp($line);
			@rec = split(/\t/, $line);
			print " ".$rec[0]."\t".$rec[2]."\t".$rec[3]."\n";
		}	
			
	}
	else {
		print $line;
	}		
}
close(PP);
