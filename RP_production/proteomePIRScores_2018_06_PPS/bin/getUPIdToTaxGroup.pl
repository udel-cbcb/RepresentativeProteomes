open(TAXTOTAXGROUP, "../data/taxToTaxGroup.txt") or die "Can't open ../data/taxToTaxGroup.txt\n";
while($line=<TAXTOTAXGROUP>) {
	chomp($line);
	($taxId) = (split(/\t/, $line))[0];
	$taxToTaxGroup{$taxId} = $line;
}
close(TAXTOTAXGROUP);

open(TAXTOUP, "../data/taxIdToUPIdMapping.txt") or die "Can't open ../data/taxIdToUPIdMapping.txt\n";
while($line=<TAXTOUP>) {
	chomp($line);
	($taxId, $upId) = (split(/\t/, $line))[0, 1];
	print $upId."-".$taxToTaxGroup{$taxId}."\n";
}
close(TAXTOUP);
