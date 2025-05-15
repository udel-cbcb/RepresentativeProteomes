if(@ARGV != 2) {
	print "Usage: perl getRundownRPGs.pl rundowned.txt rpg.txt\n";
	exit 1;
}

open(RD, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<RD>) {
	chomp($line);
	$rd{$line} = 1;
}
close(RD);

open(RPG, $ARGV[1]) or die "Can't open $ARGV[1]\n";
while($line=<RPG>) {
	if($line =~ /^$/) {
		print $line;
	}
	elsif($line =~ /^\>/) {
		@rec = split(/\t/, $line);
		$upId = $rec[0];
		$upId =~ s/\>//;
		$taxId = $rec[1];
		if($rd{$upId."\t".$taxId}) {
			print "RP rd ".$line;
		}	
		print ">".$rec[1];
		for($i=2; $i < @rec; $i++) {
			print "\t".$rec[$i]; 
		}
	}
	else {
		@rec = split(/\t/, $line);
		$up = $rec[0];
		$up =~ s/\s+//g;
		$member = $rec[1];
		if(!$rd{$up."\t".$member})  {
			print " ".$member;
			for($i=2; $i < @rec; $i++) {
				print "\t".$rec[$i];
			}
		}
	}		
}
close(RPG);

