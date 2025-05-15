
#A0A010Q090	UP000020467	1445577	UniRef50_E3QHV6
#[chenc@glycine bin]$ vi computePP.pl
#[chenc@glycine bin]$ more ../data/uniref50_full.dat 
open(UNIREF50, "../data/uniref50_full.dat") or die "Can't open ../data/uniref50_full.dat\n";
while($line=<UNIREF50>) {
	chomp($line);
	($ac, $upId, $taxId, $uniref50) = (split(/\t/, $line))[0, 1, 2, 3];
	$upIdTaxIdACUniRef50Info{$upId."-".$taxId}{$ac} = $uniref50;
}
close(UNIREF50);

#>UP000000242	399549	METS5	Metallosphaera sedula (strain ATCC 51363 / DSM 5348)	Arch/Crenar	29109.61866(PPS:1,0,4,9.47,2246)	95(CUTOFF)	RefP	99.90967(X-seed)
# UP000029084	43687	9CREN	Metallosphaera sedula	Arch/Crenar	19108.79900(PPS:0,0,1,8.62,2240)	99.63964(X-RP)		100.00000(X-seed)
@cutoffs = (95, 75, 55, 35, 15);
foreach(@cutoffs) {
	$Xin = $_;
	$ppInfo = "";
	$ppMemberInfo = "";
	$ppSeqsInfo = "";	
	%uniref50 = ();
	%memberCorrHash = ();
	%meanCorrHash = getMeanCorr($Xin);
	open(RPG, "../results_corr_consist/$Xin/rpg-$Xin.txt") or die "Can't open ../results_corr_consist/$Xin/rpg-$Xin.txt\n";	
	open(PP, ">", "../results_corr_consist/$Xin/pp-$Xin.txt") or die "Can't open ../results_corr_consist/$Xin/pp-$Xin.txt\n";	
	while($line=<RPG>) {
		($upId, $taxId, $osCode, $name, $taxGroup, $pps, $cutoff, $refp) = (split(/\t/, $line))[0, 1, 2, 3, 4, 5, 6, 7];
		if($upId =~ /^>/) {
			$rpId = $upId;
			$rpId =~ s/^>//;
			$ppId = $upId;
			$ppId =~ s/^>/>Pan-Proteome_/;	
			$ppInfo = $ppId."\t".$taxId."\t".$osCode."\t".$name."\t".$taxGroup."\t".$cutoff."\t".$refp."\n";
			$ppMemberInfo = " #".$rpId."\t".$taxId."\t";
			$acToUniRef50Ref = $upIdTaxIdACUniRef50Info{$rpId."-".$taxId};
			%acToUniRef50 = %$acToUniRef50Ref;
			$ppMemberInfo .= keys(%acToUniRef50)."\n";
			for $ac (sort keys %acToUniRef50) {
				$ppSeqsInfo .= " ".$ac."\t".$rpId."\t".$taxId."\t".$acToUniRef50{$ac}."\n";
				$uniref50{$acToUniRef50{$ac}} = 1;
			}	
		}
		elsif($upId =~ /^ /) {
			$upId =~ s/^ //;
			$memberCorrHash{$upId."-".$taxId} = $meanCorrHash{$upId."-".$taxId};
		}
		elsif($line=~ /^$/) {
			foreach my $upIdAndTaxId  (reverse sort { $hash{$a} <=> $hash{$b} } keys %memberCorrHash)  { 
				$tmp = $upIdAndTaxId;
				$tmp =~ s/-/\t/;
				$ppMemberInfo .= " #".$tmp."\t";
				$acToUniRef50Ref = $upIdTaxIdACUniRef50Info{$upIdAndTaxId};
				%acToUniRef50 = %$acToUniRef50Ref;
				$count = 0;
                                # to do sort protein by score, then loop
                                %proteinASScore = ();
                                open(PSCORE, "../data/score_inc_all/".$upIdAndTaxId."_AS.txt") or die "Can't open ../data/score_inc_all/".$upIdAndTaxId."_AS.txt\n";
				while($ps = <PSCORE>) {
					if($ps !~ /^Accession/) {
						my ($ac, $sum) = (split(/\t/, $ps))[0, 5];
						$proteinASScore{$ac} = $sum;
					}	
				}	
				close(PSCORE);
				#print $upIdAndTaxId."\t".keys(%proteinASScore)."\n";
				@sortedProteinASScore = sort { $proteinASScore{$b} <=> $proteinASScore{$a} } keys %proteinASScore;
				foreach my $ac (@sortedProteinASScore) {
					if(!$uniref50{$acToUniRef50{$ac}}) {
						$count++;
						$ppSeqsInfo .= " ".$ac."\t".$tmp."\t".$acToUniRef50{$ac}."\n";
						$uniref50{$acToUniRef50{$ac}} = 1;
					}
				}	
				$ppMemberInfo .= $count."\n";
			}				
			print PP $ppInfo;
			print PP $ppMemberInfo;
			print PP $ppSeqsInfo;
			print PP "\n";
			$ppInfo = "";
			$ppMemberInfo = "";
			$ppSeqsInfo = "";	
			%uniref50 = ();
			%memberCorrHash = ();
		}	
					
	}
	close(PP);
	close(RPG);
}

sub getMeanCorr {
        my ($Xin) = @_;
        %upIdAndTaxIdSumCorrHash=();
        %meanCorrTaxIdHash=();
        %sumCorrCountHash = 0;
        if($Xin == 95) {
                open(CORRTAB, "<", "../data/proteomesCorrTableMin.txt") or die "Can't open ../data/proteomesCorrTableMin.txt\n";
        }
        else {
                open(CORRTAB, "<", "../data/proteomesCorrTable.txt") or die "Can't open ../data/proteomesCorrTable.txt\n";
        }
        while($line=<CORRTAB>) {
                chomp($line);
                my ($upIdAndTaxId1, $upIdAndTaxId2, $corrScore) = (split(/\t/, $line))[0, 1, 2];
                #if($upIdAndTaxIdScoresHash{$upIdAndTaxId1} && $upIdAndTaxIdScoresHash{$upIdAndTaxId2}) {
                        if($corrScore >= $Xin && $upIdAndTaxId1 ne $upIdAndTaxId2) {
				#print $Xin."|".$line."\n";
                                $upIdAndTaxIdSumCorrHash{$upIdAndTaxId1} += $corrScore;
                                $sumCorrCountHash{$upIdAndTaxId1} += 1;
                        }
                #}
        }
        close(CORRTAB);
        for my $key (keys %upIdAndTaxIdSumCorrHash) {
                $scoreKey = sprintf("%d", $upIdAndTaxIdSumCorrHash{$key}/$sumCorrCountHash{$key}*100000000);
                $scoreKey += 20000000000000;
                $scoreKey .=".".$key;
                $meanCorrTaxIdHash{$key} = $scoreKey;
        }
        print "$Xin mean corr hash size: ".keys(%meanCorrTaxIdHash)."\n";
        return %meanCorrTaxIdHash;
}

