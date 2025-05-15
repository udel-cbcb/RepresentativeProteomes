open(RPG, "../results_corr_consist/75/rpg-75.txt") or die;
while($line=<RPG>) {
        if($line !~ /^$/) {
                ($upId, $taxId) = (split(/\t/, $line))[0, 1];
                $upId =~ s/>//;
                $upId =~ s/ //;
                $usedProteomes{$upId."-".$taxId} = 1;
        }
}
close(RPG);

#A0A181  7955    UniRef50_A0A181
#A0A183  9606    UniRef50_A0A183

open(UNIREF50, "../data/uniref50.dat") or die "Can't open ../data/uniref50.dat\n";
while($line =<UNIREF50>) {
	($ac, $upId, $taxId) = (split(/\t/, $line))[0, 1, 2];
	if($usedProteomes{$upId."-".$taxId}) {
		print $ac."\n";
	}
}
close(UNIREF50); 
