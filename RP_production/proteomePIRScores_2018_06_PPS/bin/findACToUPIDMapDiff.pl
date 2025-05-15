if(@ARGV != 2) {
	print "Usage: perl findACToUPIDMapDiff.pl old.txt new.text\n";
	exit 1; 
}

open(OLD, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<OLD>) {
	chomp($line);
	my ($ac, $upId) = (split(/\t/, $line))[0, 1];
	$acs{$ac} = 1;
	#print "1 \t".$upId."\n";
	#$allACs{$ac} = 1;
	$upIds{$upId} = 1;
	#$allUPIds{$upId} = 1;
}
close(OLD);


open(NEW, $ARGV[1]) or die "Can't open $ARGV[1]\n";
while($line=<NEW>) {
	chomp($line);
	my ($ac, $upId) = (split(/\t/, $line))[0, 1];
	#print "2 \t".$upId."\n";
	if($acs{$ac} == 1 || !$acs{$ac}) {
		$acs{$ac} += 2;
	}
	#$allACs{$ac} = 1;
	if($upIds{$upId} == 1 || !$upIds{$upId}) {	
		$upIds{$upId} += 2;
	}
	#$allUPIds{$upId} = 1;
}
close(NEW);

open(AC, ">", "AC_Diff.txt") or die "Can't open AC_Diff.txt\n";
for $ac (sort keys %acs) {
	#print AC $ac."\t";
	if($acs{$ac} == 1) {
		print AC "old\n";
	}
	elsif($acs{$ac} == 2) {
		print AC "new\n";
	}
	elsif($acs{$ac} == 3) {
		print AC "same\n";
	}
}
close(AC);

open(UP, ">", "UP_Diff.txt") or die "Can't open UP_Diff.txt\n";
for $upId (sort keys %upIds) {
	#print $upId."\n";
	#print UP $upId."\t";
	if($upIds{$upId} == 1) {
		print UP $upId."\t"."old\n";
	}
	elsif($upIds{$upId} == 2) {
		print UP $upId."\t"."new\n";
	}
	elsif($upIds{$upId} == 3) {
		print UP $upId."\t"."same\n";
	}
}
close(UP);
