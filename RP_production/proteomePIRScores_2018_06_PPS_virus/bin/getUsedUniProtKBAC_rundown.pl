#Taxon   #PMID   #PDB    #SwissProt      ScoreSum        TotalEntries    ScoreSum/TotalEntries   ReferenceProteome
#1002809 0       0       0       1111.0750976329 3770    0.294714880008727

#open(CP, "../data/score/proteomeScores.txt") or die "Can't open ../data/score/proteomeScores.txt\n";
#while($line=<CP>) {
#	if($line !~ /^Taxon/) {
#		($taxId) = (split(/\t/, $line))[0];
		#$usedProteome{$taxId} = 1;
#	}
#}
#close(CP);

open(RUNDOWN, "../data/rundown.txt") or die "Can't open ../data/rundown.txt\n";
while($line=<RUNDOWN>) {
        chomp($line);
        ($up, $tax) = (split(/\t/, $line))[0, 1];
        $rundown{$up."-".$tax} = 1;
        $rundowntab{$line} = 1;
}
close(RUNDOWN);

open(RPG, "../results_corr_consist/75/rpg-75.txt") or die "Can't open ../results_corr_consist/75/rpg-75.txt";
while($line=<RPG>) {
        if($line !~ /^$/) {
                ($upId, $taxId) = (split(/\t/, $line))[0, 1];
                $upId =~ s/>//;
                $upId =~ s/ //;
		if(!$rundown{$upId."-".$taxId}) {
                	$usedProteomes{$upId."-".$taxId} = 1;
		}
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
