open(GORef, "../data/goRefGenome.txt") or die "Can't open ../data/goRefGenome.txt\n";
while($line=<GORef>) {
	chomp($line);
	($taxId) = (split(/\t/, $line))[0];
	$taxToGORef{$taxId} = $line;
}
close(GORef);

open(TAXTOUP, "../data/taxIdToUPIdMapping.txt") or die "Can't open ../data/taxIdToUPIdMapping.txt\n";
while($line=<TAXTOUP>) {
	chomp($line);
	($taxId, $upId) = (split(/\t/, $line))[0, 1];
	if($taxToGORef{$taxId}) {
		print $upId."-".$taxToGORef{$taxId}."\n";
	}
}
close(TAXTOUP);
