if(@ARGV != 2) {
	print "perl getGORefSeq.pl rundown.txt rpgfile\n";
	exit;
}

open(RUNDOWN, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<RUNDOWN>) {
        chomp($line);
        ($up, $tax) = (split(/\t/, $line))[0, 1];
        $rundown{$up."-".$tax} = 1;
        $rundowntab{$line} = 1;
}
close(RUNDOWN);
#A0A181  7955    UniRef50_A0A181
#A0A183  9606    UniRef50_A0A183
#A0A1F4  7227    UniRef50_A0A1F4
open(UNIREF, "../data/uniref50.dat") or die;
while($line=<UNIREF>) {
	($ac, $upId, $taxId) = (split(/\t/, $line))[0,1, 2];
	if(!$rundown{$upId."-".$taxId}) {
		$uniref50TaxAC{$upId."-".$taxId}{$ac} = 1;
	}
}
close(UNIREF);
open(GO, "../data/upIdGORefGenome.txt") or die;
while($line =<GO>) {
	($goTaxId) = (split(/\t/, $line))[0];
	$go{$goTaxId} = 1;
}
close(GO);
open(RPG, $ARGV[1]) or die "Can't open $ARGV[1]\n";
while($line=<RPG>) {
#>351607 ACIC1   Acidothermus cellulolyticus (strain ATCC 43068 / 11B)   Bac/ActnBac     1111.16351(PPS:0,0,3,210,2157)  55(CUTOFF)

#>397945 ACIAC   Acidovorax citrulli (strain AAC00-1) (Acidovorax avenae subsp citrulli).        Bac/Beta-proteo 1111.24688(PPS:0,0,0,314,4602)  55(CUTOFF)
# 643561 ACIAP   Acidovorax avenae (strain ATCC 19860 / DSM 7227 / JCM 20985 / NCPPB 1011)       Bac/Beta-proteo 1111.09399(PPS:0,0,0,0,4718)    74.12276(X)
	if($line =~ /^\>/) {
		($upId, $taxId) = (split(/\t/, $line))[0, 1];
		$upId =~ s/^\>//;
		if(!$rundown{$upId."-".$taxId}) {
			if($go{$upId."-".$taxId} == 1) {
				$go{$upId."-".$taxId} = 2;
			}
		}		
	}	
}
close(RPG);
for my $key (keys %go) {
	if($go{$key} ==1) {
		#print $key."\n";
		$taxACRef = $uniref50TaxAC{$key};
		%taxACHash = %$taxACRef;
		for my $k (sort keys %taxACHash) {
			print $k."\n";
		}
	}
}
