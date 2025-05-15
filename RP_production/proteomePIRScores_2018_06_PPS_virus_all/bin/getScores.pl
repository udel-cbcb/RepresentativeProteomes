#!/usr/bin/perl  

if(@ARGV != 1) {
        print "perl getScores.pl previousRPG75.txt\n";
        exit 1;
}
open(RP, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<RP>) {
        chomp($line);
        if($line =~ /^\>/) {
                my ($taxId) = (split(/\t/, $line))[0];
                $taxId =~ s/^\>//;
                $prevRP{$taxId} = 1;
        }
}
close(RP);

my $firstAC = "";
my $pmidScore = 0;
my $pdbScore = 0;
my $spScore = 0; 
my $ignorePMID;
my %pmids = ();
my %pdbs = ();
my %taxIdPmidHash = ();
my %taxIdPdbHash = ();
my %taxIdSpHash = ();
my %taxIdEntryHash = ();
my %taxIdEntryScoreSumHash = ();
my %taxIdHash = ();
my %refp = ();
my %cpa = ();

#get refp.tb
#get canonical_proteome_ac.txt
`rm -rf ../data/score`;

open(REFP, "../data/refp.tb") or die "Can't open ../data/refp.tb\n";
while($line=<REFP>) {
	chomp($line);
	$refp{$line} = 1;
}
close(REFP);

open(CPA, "../data/1to1.dat") or die "Can't open ../data/1to1.dat";
while($line=<CPA>) {
	chomp($line);
	#print $line."\n";
	my ($ac, $taxId) = (split(/\s+/, $line))[0, 2];
	$cpa{$ac} = 1;	
	$taxCount{$taxId} += 1;
}
close(CPA);

#Taxon   Mnemonic        Scientific Name Common Name     Synonym Other Names     Reviewed        Rank    Lineage Parent
my %proteomesHash;

print "Starting reading Swiss-Prot data\n";
getScore("../data/uniprot_sprot.dat");
print "Finish reading Swiss-Prot data\n";

print "Starting reading Swiss-Prot data\n";
getScore("../data/uniprot_trembl.dat");
print "Finish reading Swiss-Prot data\n";

sub getScore {
my ($dataFile) =@_;
#open(DATA, "<", "../data/uniprot.dat");
open(DATA, "<", $dataFile);
while($line=<DATA>)
{
	chomp($line);
        if ($line=~ /^ID/) {
		if($line =~ /Unreviewed\;/) {
			$spScore = 0;
		}
		else {
			$spScore = 1;	
		}
		$idAll = (split /\s+/, $line)[1];
		$mnemonic = (split /\_/, $idAll)[1];	
        }      
        elsif ($line=~ /^AC   /) {
        	$ac=(split /\s+/,$line)[1]; $ac=~s/\;//; 
               	if($firstAC eq "") {
                       	$firstAC = $ac;
			if($cpa{$firstAC}) {
				#print $firstAC."\n"; 
				$isCompleteProteome = 1;
			}
                }
        }
	#NCBI_TaxID=115547;
	elsif ($line =~ /^OX   /) {
		$line =~ s/^OX\s+NCBI_TaxID\=//;
		$taxId = (split(/\;/, $line))[0];
	}
	elsif ($line =~ /^OS   /) {
		$scientificName .= " ".substr($line, 5); 
	}
	elsif ($line =~ /^OC   /) {
		$lineage .= " ".substr($line, 5);
	}
	elsif ($line =~ /^RP   /) {
		if($line =~ /\[LARGE SCALE/ || $line =~ /COMPLETE GENOME/) {
			$ignorePMID = 1;
		}
	}
	elsif ($line =~ /^RX   /) {
		if($ignorePMID eq 0) {
			if($line =~ /PubMed\=/) {
				$line =~ s/^RX\s+\wPubMed\=//;
				$pmid = (split(/\;/, $line))[0];
				if($pmid) {
					$pmids{$pmid} = 1;
				}
			}
		}
		else {
			$ignorePMID = 0;
		}
	}
	elsif($line =~ /^DR   PDB\;/) {
		$pdbScore = 1;
		$line =~ s/^DR\s+PDB\;//;
		$pdbId = (split(/\;/, $line))[0];
		$pdbs{$pdbId} = 1;
	}
	#elsif ($line =~ /^KW   /) {
	#	if($line =~ /Complete proteome/) {
	#		$isCompleteProteome = 1;
	#	}
	#}
	#elsif ($line =~ /^KW   /) {
	#	if($line =~ /Reference proteome/) {
	#		$refp{$taxId} = 1;
	#	}
	#}
        elsif ($line =~ /^\/\/$/) {
		if($isCompleteProteome) {
			$scientificName =~ s/\.//;		
			$scientificName =~ s/^\s+//;		
			$lineage =~ s/\.//;		
			$lineage =~ s/^\s+//;		
			if($lineage !~ /^Viruses\;/) {
				#Taxon   Mnemonic        Scientific Name Common Name     Synonym Other Names     Reviewed        Rank    Lineage Parent
				$taxInfo = $taxId."\t".$mnemonic."\t".$scientificName."\t"."\t"."\t"."\t"."\t"."\t".$lineage."\t\n";	
				if($taxCount{$taxId} > 100) {
					$taxIdHash{$taxId} = $taxInfo;
					$pmidScore = keys %pmids;
					$pdbScore =  keys %pdbs;
					$score = $pmidScore + $pdbScore + $spScore;
					#print $firstAC."\n";
					$entryInfo =  $firstAC."\t".$pmidScore."\t".$pdbScore."\t".$spScore."\t".$score."\n";
					$taxIdEntryHash{$taxId}{$firstAC} = $entryInfo;
					$taxIdEntryScoreSumHash{$taxId}{$firstAC} = $score;
		
					if($spScore eq 1) {
						$taxIdSpHash{$taxId}{$firstAC} = 1;
					}
					if($pdbScore > 0) {
						for my $pdbId (keys %pdbs) {
							$taxIdPdbHash{$taxId}{$pdbId} = 1;
						}
					}
					if($pmidScore > 0) {
						foreach my $pmid (keys %pmids) {
							$taxIdPmidHash{$taxId}{$pmid} = 1;
						}	
					}
				}
			}
		}
                $firstAC="";
		$pmidScore = 0;
		$pdbScore = 0;
		$spScore = 0;
		%pmids = (); 
		%pdbs = (); 
		$ignorePMID = 0;
		$isCompleteProteome = 0;
		$mnemonic = "";
		$scientificName = "";
		$lineage = "";
        }
	
}
close(DATA);
}


print "Start finding min and max\n";
$minSeqPmidScore = 1000000000;
$maxSeqPmidScore = -1;
$minSeqPdbScore = 1000000000;
$maxSeqPdbScore = -1;
foreach my $taxId (sort keys %taxIdHash) {
	my $entryHashRef = $taxIdEntryHash{$taxId};
	my %entryHash = %$entryHashRef;
	foreach my $ac (sort keys %entryHash) {
		@rec = split(/\t/, $entryHash{$ac});
		#print SCORE $entryHash{$ac};
		if($rec[1] < $minSeqPmidScore) {
			$minSeqPmidScore = $rec[1];
		}
		if($rec[1] > $maxSeqPmidScore) {
			$maxSeqPmidScore = $rec[1];
		}
		if($rec[2] < $minSeqPdbScore) {
			$minSeqPdbScore = $rec[2];
		}
		if($rec[2] > $maxSeqPdbScore) {
			$maxSeqPdbScore = $rec[2];
		}
		
		#push(@seqPmidScores, $rec[1]);
		#push(@seqPdbScores, $rec[2]);
		#push(@seqSpScores, $rec[3]);
	}
}
print "Finish finding min and max\n";

#@seqPmidScores = sort @seqPmidScores;
#@seqPdbScores = sort @seqPdbScores;
#@seqSpScores = sort @seqSpScores;

#$minSeqPmidScore = $seqPmidScores[0];
#$maxSeqPmidScore = $seqPmidScores[-1];
$rangeSeqPmidScore = $maxSeqPmidScore - $minSeqPmidScore;
print $maxSeqPmidScore." - ".$minSeqPmidScore." = ".$rangeSeqPmidScore."\n";;

#$minSeqPdbScore = $seqPdbScores[0];
#$maxSeqPdbScore = $seqPdbScores[-1];
$rangeSeqPdbScore = $maxSeqPdbScore - $minSeqPdbScore;
print $maxSeqPdbScore." - ".$minSeqPdbScore." = ".$rangeSeqPdbScore."\n";;


if( ! -d "../data/score") {
	system("mkdir -p ../data/score");
}
open(COMPLETE, ">", "../data/taxonomy-complete_yes.tab");
print COMPLETE "Taxon"."\t"."Mnemonic"."\t"."Scientific Name"."\t"."Common Name"."\t"."Synonym"."\t"."Other Names"."\t"."Reviewed"."\t"."Rank"."\t"."Lineage"."\t"."Parent\n";
foreach my $taxId (sort keys %taxIdHash) {
	print COMPLETE $taxIdHash{$taxId};	
	my $entryHashRef = $taxIdEntryHash{$taxId};
	my %entryHash = %$entryHashRef;
	open(SCORE, ">", "../data/score/".$taxId."_score.txt");
	#print SCORE "Accession"."\t"."#PMID"."\t"."#PDB"."\t"."SwissProt"."\t"."Sum\n";
	print SCORE "Accession"."\t"."#PMID"."\t"."#PDB"."\t"."SwissProt"."\t"."Sum\n";
	foreach my $ac (sort keys %entryHash) {
		@rec = split(/\t/, $entryHash{$ac});
		my $weightedSeqPmidScore = 100*(1+(($rec[1] - $minSeqPmidScore)/$rangeSeqPmidScore));
		my $weightedSeqPdbScore = 10*(1+(($rec[1] - $minSeqPdbScore)/$rangeSeqPdbScore));
		$scoreSum = $weightedSeqPmidScore + $weightedSeqPdbScore + $rec[3];
		
		print SCORE $ac."\t".$rec[1]."\t".$rec[2]."\t".$rec[3]."\t".$scoreSum."\n";	
		#print SCORE $entryHash{$ac};
	}
	close(SCORE);										
}
close(COMPLETE);


if( ! -d "../data/score") {
	system("mkdir -p ../data/score");
}
$minPPmidScore = 100000000000;
$maxPPmidScore = -1;
$minPPdbScore = 100000000000;
$maxPPdbScore = -1;
$minPSpScore = 10000000000;
$maxPSpScore = -1;
$minEntryTotal = 1000000000000;
$maxEntryTotal = -1;

for my $taxId (sort keys(%taxIdHash)) {
	my $ppmidScore = keys %{ $taxIdPmidHash{$taxId}};
	my $ppdbScore = keys %{ $taxIdPdbHash{$taxId}};
	my $pspScore = keys %{ $taxIdSpHash{$taxId}};
	my $entryTotal = keys %{ $taxIdEntryHash{$taxId}};
	if($ppmidScore < $minPPmidScore) {
		$minPPmidScore = $ppmidScore;
	} 
	if($ppmidScore > $maxPPmidScore) {
		$maxPPmidScore = $ppmidScore;
	} 
	if($ppdbScore < $minPPdbScore) {
		$minPPdbScore = $ppdbScore;
	} 
	if($ppdbScore > $maxPPdbScore) {
		$maxPPdbScore = $ppdbScore;
	} 
	if($pspScore < $minPSpScore) {
		$minPSpScore = $pspScore;
	} 
	if($pspScore > $maxPSpScore) {
		$maxPSpScore = $pspScore;
	} 
	if($entryTotal < $minEntryTotal) {
		$minEntryTotal = $entryTotal;
	} 
	if($entryTotal > $maxEntryTotal) {
		$maxEntryTotal = $entryTotal;
	} 
	#push(@ppmidScores, $ppmidScore);
	#push(@ppdbScores, $ppdbScore);
	#push(@pspScores, $pspScore);
	#push(@entryTotals, $entryTotal);
}
#@ppmidScores = sort @ppmidScores;
#@ppdbScores = sort @ppdbScores;
#@pspScores = sort @pspScores;
#@entryTotals = sort @entryTotals;

#$minPPmidScore = $ppmidScores[0];
#$maxPPmidScore = $ppmidScores[-1];
$rangePPmidScore = $maxPPmidScore - $minPPmidScore;
print "PMID: $rangePPmidScore = $maxPPmidScore - $minPPmidScore\n";

#$minPPdbScore = $ppdbScores[0];
#$maxPPdbScore = $ppdbScores[-1];
$rangePPdbScore = $maxPPdbScore - $minPPdbScore;
print "PDB: $rangePPdbScore = $maxPPdbScore - $minPPdbScore\n";

#$minPSpScore = $pspScores[0];
#$maxPSpScore = $pspScores[-1];
$rangePSpScore = $maxPSpScore - $minPSpScore; 
print "SP: $rangePSpScore = $maxPSpScore - $minPSpScore\n"; 

#$minEntryTotal = $entryTotals[0];
#$maxEntryTotal = $entryTotals[-1];
$rangeEntryTotal = $maxEntryTotal - $minEntryTotal;
print "Entry: $rangeEntryTotal = $maxEntryTotal - $minEntryTotal\n";

 
open(PSCORE, ">", "../data/score/proteomeScores.txt");
#print PSCORE "Taxon"."\t"."#PMID"."\t"."#PDB"."\t"."#SwissProt"."\t"."ScoreSum"."\t"."TotalEntries"."\t"."ScoreSum/TotalEntries"."\n";		
print PSCORE "Taxon"."\t"."#PMID"."\t"."#PDB"."\t"."#SwissProt"."\t"."ScoreSum"."\t"."TotalEntries"."\t"."ScoreSum/TotalEntries"."\t"."ReferenceProteome"."\t"."PreviousRP\n";		
foreach my $taxId (sort keys(%taxIdHash)) {
	my $pPmidScore = keys %{ $taxIdPmidHash{$taxId}};
	my $pPdbScore = keys %{ $taxIdPdbHash{$taxId}};
	my $pSpScore = keys %{ $taxIdSpHash{$taxId}};
	my $entryTotal = keys %{ $taxIdEntryHash{$taxId}};
	my $weightedPPmidScore = 1000*(1+(($pPmidScore - $minPPmidScore)/$rangePPmidScore));
	print  "$taxId\t$weightedPPmidScore = 1000*(1+(($pPmidScore - $minPPmidScore)/$rangePPmidScore))\n";
	my $weightedPPdbScore = 100*(1+(($pPdbScore - $minPPdbScore)/$rangePPdbScore));
	print "$taxId\t$weightedPPdbScore = 100*(1+(($pPdbScore - $minPPdbScore)/$rangePPdbScore))\n";
	my $weightedPSpScore = 10*(1+(($pSpScore - $minPSpScore)/$rangePSpScore));
	print "$taxId\t$weightedPSpScore = 10*(1+(($pSpScore - $minPSpScore)/$rangePSpScore))\n";
	my $weightedEntryTotal = 1+(($entryTotal - $minEntryTotal)/$rangeEntryTotal);
	print "$taxId\t$weightedEntryTotal = 1+(($entryTotal - $minEntryTotal)/$rangeEntryTotal)\n";

	if($refp{$taxId}) {
		#$scoreSum += 10000;	
		$refpScore = 1;	
	}
	else {
		$refpScore = 0;
	}
	if($prevRP{$taxId}) {
		$RPScore = 1;
	}
	else {
		$RPScore = 0;
	}
	my $weightedRefpScore = 10000 *(1+(($refpScore - 0)/1));
	print "$taxId\t$weightedRefpScore = 10000 *(1+(($refpScore - 0)/1))\n";
	my $weightedRPScore = 8000*(1+(($RPScore - 0)/1));
	print "$taxId\t$weightedRPScore = 8000*(1+(($RPScore - 0)/1))\n";
	
	my $scoreSum = $weightedRefpScore + $weightedRPScore + $weightedPPmidScore + $weightedPPdbScore + $weightedPSpScore + $weightedEntryTotal;
	my $average = $scoreSum/$entryTotal;
	print PSCORE $taxId."\t".$pPmidScore."\t".$pPdbScore."\t".$pSpScore."\t".$scoreSum."\t".$entryTotal."\t".$average."\t";	
	if($refp{$taxId}) {
		print PSCORE "RefP\t";
	}
	else {
		print PSCORE "\t";
	}
	if($prevRP{$taxId}) {
		print PSCORE "PrevRP\n";
	}
	else {
		print PSCORE "\n";
	}
	print $taxId."\t".$pPmidScore." (PMID)\t".$pPdbScore." (PDB)\t".$pSpScore." (SP)\t".$scoreSum." (SUM)\t".$entryTotal." (Entry)\t".$average." (AVG)\t".$refp{$taxId}."\t".$prevRP{$taxId}."\n";	
	print "$taxId: $scoreSum = $weightedRefpScore (RefP)\t$weightedRPScore (PrevRP)\t$weightedPPmidScore (PMID)\t$weightedPPdbScore (PDB)\t$weightedPSpScore (SP)\t$weightedEntryTotal (Entry)\n";
}
close(PSCORE);

#open(REFP, ">../data/refp.tb") or die "Can't open ../data/refp.tb\n";
#for my $key (sort {$a <=> $b} keys %refp) {
#	print REFP $key."\n";
#}
#close(REFP);

