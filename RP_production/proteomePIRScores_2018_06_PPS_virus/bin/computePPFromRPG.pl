if(@ARGV != 1) {
	print "Usage: perl computePPFromRPG.pl rpg.txt\n";
	exit 1;
}

#A0A010Q090     UP000020467     1445577 UniRef50_E3QHV6
##[chenc@glycine bin]$ vi computePP.pl
##[chenc@glycine bin]$ more ../data/uniref50_full.dat 
open(UNIREF50, "../data/uniref50_ALL.dat") or die "Can't open ../data/uniref50_ALL.dat\n";
while($line=<UNIREF50>) {
        chomp($line);
       ($ac, $upId, $taxId, $uniref50) = (split(/\t/, $line))[0, 1, 2, 3];
        $upIdTaxIdACUniRef50Info{$upId."-".$taxId}{$ac} = $uniref50;
}
close(UNIREF50);

#>UP000000242   399549  METS5   Metallosphaera sedula (strain ATCC 51363 / DSM 5348)    Arch/Crenar     29109.61866(PPS:1,0,4,9.47,2246)        95(CUTOFF)      RefP    99.90967(X-seed)
# UP000029084   43687   9CREN   Metallosphaera sedula   Arch/Crenar     19108.79900(PPS:0,0,1,8.62,2240)        99.63964(X-RP)          100.00000(X-seed)
#
my %memberPPS = ();
my %ppUniRef50 = ();
open(RPG, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<RPG>) {
	if($line =~ /^>/) {
		chomp($line);
		($rp, $rpTaxId, $code, $os, $taxGroup, $pps, $cutoff) = (split(/\t/, $line))[0, 1, 2, 3, 4, 5, 6];
		$rp =~ s/>//;
		$ppDef = ">Pan-Proteome_".$rp."\t".$rpTaxId."\t".$code."\t".$os."\t".$taxGroup."\t".$pps."\t".$cutoff."\n"; 
		$count = 1;
		%memberPPS = ();
	}
	elsif($line =~ /^ UP/) {
		$count++;	
		chomp($line);
		($member, $memberTaxId, $ppsInfo) = (split(/\t/, $line))[0, 1, 5];
		$member =~ s/\s+//;
		($pps) = (split(/\(/, $ppsInfo))[0];	
		$memberPPS{$member."-".$memberTaxId} = $pps;  
	}
	elsif($line =~ /^$/) {
		print $ppDef;	
		%ppUniRef50 = ();
		$rpUniRef50InfoRef = $upIdTaxIdACUniRef50Info{$rp."-".$rpTaxId};
		%rpUniRef50Info = %$rpUniRef50InfoRef;			
		$ppInfo = " #".$rp."\t".$rpTaxId."\t".keys(%rpUniRef50Info)."\n";
		$ppSeqInfo = "";
		for $ac (sort keys %rpUniRef50Info) {
			my $uniref50 = $rpUniRef50Info{$ac};
			$ppUniRef50{$uniref50} = $rp."-".$rpTaxId;
			$ppSeqInfo .= " ".$ac."\t".$rp."\t".$rpTaxId."\t".$uniref50."\n";	
		}
		foreach my $memberUPIdAndTaxId  (sort { $memberPPS{$b} <=> $memberPPS{$a} } keys %memberPPS) {
			($member, $memberTaxId) = (split(/-/, $memberUPIdAndTaxId))[0, 1];
			my $memberSeqRef = getPPMemberSeqInfo($rp."-".$rpTaxId, $memberUPIdAndTaxId);		
			my %memberSeqInfo = %$memberSeqRef;
			if(keys(%memberSeqInfo) > 0) {
				$ppInfo .= " #".$member."\t".$memberTaxId."\t".keys(%memberSeqInfo)."\n";
				for my $key (sort keys (%memberSeqInfo)) {
					$ppSeqInfo .= $memberSeqInfo{$key}."\n";
				}
			} 	
		}

		print $ppInfo;
		print $ppSeqInfo;
		print "\n";
	}
}
close(RPG);

sub getPPMemberSeqInfo() {
	my ($rpUPIdAndTaxId, $memberUPIdAndTaxId) = @_;
	my ($rp, $rpTaxId) = (split(/-/, $rpUPIdAndTaxId))[0, 1];
	($member, $memberTaxId) = (split(/-/, $memberUPIdAndTaxId))[0, 1];
	
	my %proteinASScore = ();
        open(PSCORE, "../data/score_inc_all/".$memberUPIdAndTaxId."_AS.txt") or die "Can't open ../data/score_inc_all/".$memberUPIdAndTaxId."_AS.txt\n";
        while($ps = <PSCORE>) {
       		if($ps !~ /^Accession/) {
                    my ($ac, $sum) = (split(/\t/, $ps))[0, 5];
                    $proteinASScore{$ac} = $sum;
         	}
        }
        close(PSCORE);		
	my %memberSeq = ();
	foreach my $ac (sort { $proteinASScore{$b} <=> $proteinASScore{$a} } keys %proteinASScore) {
		my $uniref50 = $upIdTaxIdACUniRef50Info{$memberUPIdAndTaxId}{$ac};
		if($ppUniRef50{$uniref50} ne $rpUPIdAndTaxId) {
			$ppUniRef50{$uniref50} = $rpUPIdAndTaxId;
			$memberSeq{$ac} = " ".$ac."\t".$member."\t".$memberTaxId."\t".$uniref50;
		}
	}
	return \%memberSeq;
}
