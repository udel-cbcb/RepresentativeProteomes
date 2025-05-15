#>UP000000204	1221877	CHLPS	Chlamydia psittaci 01DC12	Bac/Chlamyd	19113.62947(PPS:0,0,0,13.89,954)	95(CUTOFF)		100.00000(X-seed)
# UP000014548	1112252	CHLPS	Chlamydia psittaci 01DC11	Bac/Chlamyd	19110.15717(PPS:0,0,0,10.12,1384)	97.05573(X-RP)		97.05573(X-seed)
#  UP000015899	1112256	CHLPS	Chlamydia psittaci 02DC18	Bac/Chlamyd	19111.39460(PPS:0,0,0,11.47,1181)	97.58149(X-RP)		97.58149(X-seed)
#
if(@ARGV != 1) {
	print "Usage: perl checkOutstandingRP.pl rpg.txt\n";
	exit 1;
}

open(RPG, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<RPG>) {
	if($line =~ /^>/) {
		($rp, $pps, $rpType)  = (split(/\t/, $line))[0, 5, 7];
		$rp =~ s/^>//;
		#print $rp."\t".$pps."|\t".$rpType."|\n";
		($rpScore) = (split(/\(/, $pps))[0];
	}
	elsif($line =~ / UP/) {
		($m, $pps, $mType)  = (split(/\t/, $line))[0, 5, 7];
		$m =~ s/\s+//g;
		($mScore) = (split(/\(/, $pps))[0];
		#print $m."\t".$pps."|\t".$mType."|\n";
		if($mScore > $rpScore) {
			print "Score larger than RP: [$ARGV[0]] $rp(rp) $m(member)\n";
		}
		if(!$rpType && $mType eq "RefP") {
			print "RP is not RefP: [$ARGV[0]] $rp(rp) $m(member)\n";
		}
	}
}
close(RPG);
