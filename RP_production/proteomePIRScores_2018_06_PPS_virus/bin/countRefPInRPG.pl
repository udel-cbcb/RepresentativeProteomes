$RefPCount == 0;
while($line=<>) {
	if($line =~ /^>/) {
		($rp, $refp) = (split(/\t/, $line))[0, 7];
		print $rp."\t".$refp."\n";
		$rpgRefPCount{$rp} = 0;
		$rpg = $rp;
		if($refp) {
			$RefPCount++;
			$rpgRefPCount{$rp} += 1;
		}
	}
	elsif($line =~ /^ UP/) {
		($refp) = (split(/\t/, $line))[7];
		if($refp) {
			print $rp."\t".$refp."\n";
			$RefPCount++;
			$rpgRefPCount{$rp} += 1;
		}
	}
	elsif($line =~ /^$/) {
		print $rp."\t".$rpgRefPCount{$rp}."\n";
	}
}

$RPG1 = 0;
$RPGGT1 = 0;
$RPGNoRefP = 0;
for my $rp (sort keys %rpgRefPCount) {
	if($rpgRefPCount{$rp} == 1) {
		$RPG1++;
	}
	elsif($rpgRefPCount{$rp} > 1) {
		$RPGGT1++;
	}
	else {
		$RPGNoRefP++;
	}	
}

print keys(%rpgRefPCount)."\t".$RefPCount."\t".$RPG1."\t".$RPGGT1."\t".$RPGNoRefP."\n";

