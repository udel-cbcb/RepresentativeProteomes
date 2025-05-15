$virusGroup = "../data/virus_taxonomic_group.txt";
#Viruses; Deltavirus	39759
#Viruses; dsDNA viruses, no RNA stage	35237
#$virusGroup = "../data/virus_group.txt";
my %vgName = ();
open(VG, $virusGroup) or die "Can't open $virusGroup\n";
while($line=<VG>) {
	chomp($line);
	($virusLineage, $taxId) = (split(/\t/, $line))[0, 1];
	#$vg{$taxId} = $virusGroupName;
	$vgName{$virusLineage} = $virusLineage."\t".$taxId; 
}
close(VG);
$virusCP = "../data/up-taxonomy-complete_yes.tab";
open(VCP, $virusCP) or die "Can't open $virusCP\n";
while($line=<VCP>) {
	chomp($line);
	if($line !~ /^UPID/) {
		($upId, $taxId, $virus, $lineage) = (split(/\t/, $line))[0, 1, 3, 9];
		#print $lineage."\n";
		($group) = (split(/\; /, $lineage))[1];
		#print "|".$group."|\n";
		if($vgName{$group}) {
			print $upId."\t".$taxId."\t".$virus."\t".$vgName{$group}."\t".$lineage."\n";		
		}
		else {
			print $upId."\t".$taxId."\t".$virus."\t".$vgName{"Other viruses"}."\t".$lineage."\n";		
		}
	}	
}
close(VCP);
