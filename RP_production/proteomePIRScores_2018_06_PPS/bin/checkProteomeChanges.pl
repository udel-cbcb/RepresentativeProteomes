if(@ARGV != 2) {
	print "Usage: perl checkProteomeChanges.pl oldScoreDir newScoreDir\n";
	exit 1;
}

$oldScoreDir = $ARGV[0];
$newScoreDir = $ARGV[1];

#UPID	Taxon	#PMID	#PDB	#SwissProt	ScoreSum	TotalEntries	ScoreSum/TotalEntries	ReferenceProteome	PreviousRP
#UP000000204	1221877	0	0	0	19111.0086366816	954	20.0325038120352		

open(OLDP, $oldScoreDir."/proteomeScores.txt") or die "Can't open ".$oldScoreDir."/proteomeScores.txt\n";
while($line=<OLDP>) {
	if($line !~ /^UPID/) {
		my ($upId, $taxId) = (split(/\t/, $line))[0, 1];
		$oldUPs{$upId."-".$taxId} = 1;
		$ups{$upId."-".$taxId} += 1;
	}
}
close(OLDP);

open(NEWP, $newScoreDir."/proteomeScores.txt") or die "Can't open ".$newScoreDir."/proteomeScores.txt\n";
while($line=<NEWP>) {
	if($line !~ /^UPID/) {
		my ($upId, $taxId) = (split(/\t/, $line))[0, 1];
		$oldUPs{$upId."-".$taxId} = 1;
		$ups{$upId."-".$taxId} += 2;
	}
}
close(NEWP);

for $upId (sort keys %ups) {
	#print $upId."\t".$ups{$upId}."\n";	
	if($ups{$upId} == 1) {
		$finalUPs{$upId} = "deleted";
	}
	if($ups{$upId} == 2) {
		$finalUPs{$upId} = "new";
	}
	if($ups{$upId} == 3) {
		$finalUPs{$upId} = checkProteins($upId, $oldScoreDir, $newScoreDir);  
	}	
}

for $upId (sort keys %finalUPs) {
	print $upId."\t".$finalUPs{$upId}."\n";
}
#UP000092227-1834097_score.txt
sub checkProteins() {
	my %ACs = ();
	my %oldACs = ();
	my %newACs = ();
	my ($upId, $oldScoreDir, $newScoreDir) = @_; 
	open(OLDPP, $oldScoreDir."/".$upId."_score.txt") or die "Can't open ".$oldScoreDir."/".$upId."_score.txt\n";
	while($line=<OLDPP>) {
		if($line !~ /^Accession/) {
			my ($ac) = (split(/\t/, $line))[0];
			$oldACs{$ac} = 1;
			$ACs{$ac} +=1;
		}
	}
	close(OLDPP);		
	open(NEWPP, $newScoreDir."/".$upId."_score.txt") or die "Can't open ".$newScoreDir."/".$upId."_score.txt\n";
	while($line=<NEWPP>) {
		if($line !~ /^Accession/) {
			my ($ac) = (split(/\t/, $line))[0];
			$newACs{$ac} = 1;
			$ACs{$ac} +=2;
		}
	}
	close(NEWPP);
	$sameCount = 0;
	$newCount = 0;
	$oldCount = 0;	
	for $ac (sort keys %ACs) {
		if($ACs{$ac} == 3) {
			$sameCount += 1;
		}
		if($ACs{$ac} == 1) {
			$oldCount += 1;
		}
		if($ACs{$ac} == 2) {
			$newCount += 1;
		}
	}
	$pCount = keys (%newACs);
	#print $upId."\t".$sameCount."|".$pCount."\n";
	if(($sameCount+0.0)/$pCount > 0.95) {
		return "same";
	}
	else {
		return "changed";
	}			
} 

