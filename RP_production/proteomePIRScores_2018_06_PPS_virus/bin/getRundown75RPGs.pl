if(@ARGV != 2) {
	print "Usage: perl getRundownRPGs.pl rpg.txt rundowned.txt\n";
	exit 1;
}
open(RPG, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<RPG>) {
	if($line =~ /^$/) {
		print $line;
	}
	elsif($line =~ /^\>/) {
		@rec = split(/\t/, $line);
		$rp = $rec[1];
		print ">".$rec[1];
		for($i=2; $i < @rec; $i++) {
			print "\t".$rec[$i]; 
		}
		$rpMember{$rp."-".$rp} = 1;
	}
	else {
		@rec = split(/\t/, $line);
		$up = $rec[0];
		$up =~ s/\s+//g;
		$member = $rec[1];
		if(!$rpMember{$rp."-".$member})  {
			print " ".$member;
			for($i=2; $i < @rec; $i++) {
				print "\t".$rec[$i];
			}
			$rpMember{$rp."-".$member} = 1;
		}
		else {
			#print $line;
			$rundowned{$up."\t".$member} = 1;
		}
	}		
}
close(RPG);

open(RUNDOWNED, ">", $ARGV[1]) or die "Can't open $ARGV[1]\n";
for $key (sort keys %rundowned) {
	print RUNDOWNED $key."\n";	
}
close(RUNDOWNED);
