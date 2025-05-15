if(@ARGV != 1) {
	print "perl getRPSeq.pl rpgfile\n";
	exit;
}

#A0A181  7955    UniRef50_A0A181
#A0A183  9606    UniRef50_A0A183
#A0A1F4  7227    UniRef50_A0A1F4
open(UNIREF, "../data/uniref50.dat") or die;
while($line=<UNIREF>) {
	($ac, $upId, $taxId) = (split(/\t/, $line))[0,1, 2];
	$uniref50TaxAC{$upId."-".$taxId}{$ac} = 1;
}
close(UNIREF);
open(RPG, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<RPG>) {
#>351607 ACIC1   Acidothermus cellulolyticus (strain ATCC 43068 / 11B)   Bac/ActnBac     1111.16351(PPS:0,0,3,210,2157)  55(CUTOFF)

#>397945 ACIAC   Acidovorax citrulli (strain AAC00-1) (Acidovorax avenae subsp citrulli).        Bac/Beta-proteo 1111.24688(PPS:0,0,0,314,4602)  55(CUTOFF)
# 643561 ACIAP   Acidovorax avenae (strain ATCC 19860 / DSM 7227 / JCM 20985 / NCPPB 1011)       Bac/Beta-proteo 1111.09399(PPS:0,0,0,0,4718)    74.12276(X)
	if($line =~ /^\>/) {
		my ($upId, $taxId) = (split(/\t/, $line))[0, 1];
		$upId =~ s/^\>//;
		$taxACRef = $uniref50TaxAC{$upId."-".$taxId};
		%taxACHash = %$taxACRef;
		for my $k (sort keys %taxACHash) {
			print $k."\n";
		}
	}	
}
close(RPG);
