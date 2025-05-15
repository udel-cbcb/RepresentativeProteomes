#!/usr/bin/perl  

if(@ARGV != 1) {
        print "perl getScoresIncAll.pl prevRP75.txt\n";
        exit 1;
}

open(RP, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<RP>) {
        chomp($line);
        if($line =~ /^\>/) {
                my ($upId, $taxId) = (split(/\t/, $line))[0,1];
                $upId =~ s/^\>//;
                $prevRP{$upId."\t".$taxId} = 1;
        }
}
close(RP);
print "finish reading prevRP\n";

my $firstAC = "";
my $pmidScore = 0;
my $pdbScore = 0;
my $spScore = 0; 
my $ignorePMID;
my %pmids = ();
my %pdbs = ();
my %upIdAndtaxIdPmidHash = ();
my %upIdAndtaxIdPdbHash = ();
my %upIdAndtaxIdSpHash = ();
my %upIdAndtaxIdEntryHash = ();
my %upIdAndtaxIdEntryScoreSumHash = ();
my %upIdAndtaxIdHash = ();
my %refp = ();
my %cpa = ();

`rm -rf ../data/score_inc_all`;

open(REFP, "../data/refp.tb") or die "Can't open ../data/refp.tb\n";
while($line=<REFP>) {
	chomp($line);
	$refp{$line} = 1;
}
close(REFP);

#Taxon	Mnemonic	UPID	Scientific name	Common name	Synonym	Other Names	Rank	Lineage	Parent	Component Name
#48		UP000035579
open(CP, "../data/proteomes_complete.txt") or die "Can't open ../data/proteomes_complete.txt\n";
while($line=<CP>) {
	($tax, $up) = (split(/\t/, $line))[0, 2];
	$upToTax{$up} = $tax;
}

close(CP);

open(CPA, "../data/mapping_accs2upid.txt") or die "Can't open ../data/mapping_accs2upid.txt";
while($line=<CPA>) {
        chomp($line);
        my ($ac, $upId) = (split(/\t/, $line))[0, 1];
	if($upId =~ /^UP/ && $upToTax{$upId}) {
        	$cpa{$ac} = 1;
        	$upCount{$upId."\t".$upToTax{$upId}} += 1;
        	if(!$acToUPs{$ac}) {
                	$acToUPs{$ac} .= $upId;
        	}
        	else {
                	$acToUPs{$ac} .= ";".$upId;
        	}
	}
}
close(CPA);
print "Finish reading 1to1 file\n";
#Taxon   Mnemonic        Scientific Name Common Name     Synonym Other Names     Reviewed        Rank    Lineage Parent
my %proteomesHash = ();
my %upIdAndTaxIdHash = ();

print "Starting reading Swiss-Prot data\n";
getScore("../data/uniprot_sprot.dat");
print "Finish reading Swiss-Prot data\n";

print "Starting reading TrEMBL data\n";
getScore("../data/uniprot_trembl.dat");
print "Finish reading TrEMBL data\n";

sub getScore {
my ($dataFile) =@_;
#open(DATA, "<", "../data/uniprot.dat");
open(DATA, "<", $dataFile) or die "Can't open $dataFile\n";
while($line=<DATA>)
{
	#print $line;
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
        elsif ($line =~ /^\/\/$/) {
		if($isCompleteProteome) {
			$scientificName =~ s/\.//;		
			$scientificName =~ s/^\s+//;		
			$lineage =~ s/\.//;		
			$lineage =~ s/^\s+//;		
			if($lineage !~ /^Viruses\;/) {
				#Taxon   Mnemonic        Scientific Name Common Name     Synonym Other Names     Reviewed        Rank    Lineage Parent
				#$taxInfo = $taxId."\t".$mnemonic."\t".$scientificName."\t"."\t"."\t"."\t"."\t"."\t".$lineage."\t\n";	
				$taxInfo = $mnemonic."\t".$scientificName."\t"."\t"."\t"."\t"."\t"."\t".$lineage."\t\n";	
				@upIds = split(/\;/, $acToUPs{$firstAC});
				foreach(@upIds) {	
					my $upId = $_;
					if($upCount{$upId."\t".$taxId} > 100) {
						$upIdAndTaxIdHash{$upId."\t".$taxId} = $taxInfo;
						$pmidScore = keys %pmids;
						$pdbScore =  keys %pdbs;
						$score = $pmidScore + $pdbScore + $spScore;
						$entryInfo =  $firstAC."\t".$pmidScore."\t".$pdbScore."\t".$spScore."\t".$score."\n";
						$upIdAndTaxIdEntryHash{$upId."\t".$taxId}{$firstAC} = $entryInfo;
						$upIdAndTaxIdEntryScoreSumHash{$upId."\t".$taxId}{$firstAC} = $score;
		
						if($spScore eq 1) {
							$upIdAndTaxIdSpHash{$upId."\t".$taxId}{$firstAC} = 1;
						}
						if($pdbScore > 0) {
							for my $pdbId (keys %pdbs) {
								$upIdAndTaxIdPdbHash{$upId."\t".$taxId}{$pdbId} = 1;
							}
						}
						if($pmidScore > 0) {
							foreach my $pmid (keys %pmids) {
								$upIdAndTaxIdPmidHash{$upId."\t".$taxId}{$pmid} = 1;
							}	
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
$minSeqSPScore = 1000000000;
$maxSeqSPScore = -1;
foreach my $upIdAndTaxId (sort keys %upIdAndTaxIdHash) {
	my $entryHashRef = $upIdAndTaxIdEntryHash{$upIdAndTaxId};
	my %entryHash = %$entryHashRef;
	foreach my $ac (sort keys %entryHash) {
		@rec = split(/\t/, $entryHash{$ac});
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
		if($rec[3] < $minSeqSPScore) {
			$minSeqSPScore = $rec[3];
		}
		if($rec[3] > $maxSeqSPScore) {
			$maxSeqSPScore = $rec[3];
		}
	}
}
print "Finish finding min and max\n";

$rangeSeqPmidScore = $maxSeqPmidScore - $minSeqPmidScore;
print $maxSeqPmidScore." - ".$minSeqPmidScore." = ".$rangeSeqPmidScore."\n";;

$rangeSeqPdbScore = $maxSeqPdbScore - $minSeqPdbScore;
print $maxSeqPdbScore." - ".$minSeqPdbScore." = ".$rangeSeqPdbScore."\n";;

$rangeSeqSPScore = $maxSeqSPScore - $minSeqSPScore;
print $maxSeqSPScore." - ".$minSeqSPScore." = ".$rangeSeqSPScore."\n";;


if( ! -d "../data/score_inc_all") {
	system("mkdir -p ../data/score_inc_all");
}
open(COMPLETE, ">", "../data/up-taxonomy-complete_yes_all.tab");
print COMPLETE "UPID"."\t"."Taxon"."\t"."Mnemonic"."\t"."Scientific Name"."\t"."Common Name"."\t"."Synonym"."\t"."Other Names"."\t"."Reviewed"."\t"."Rank"."\t"."Lineage"."\t"."Parent\n";
print "upIdAndTaxIdHash: ".(keys(%upIdAndTaxIdHash))."\n";

foreach my $upIdAndTaxId (sort keys %upIdAndTaxIdHash) {
	print COMPLETE $upIdAndTaxId."\t".$upIdAndTaxIdHash{$upIdAndTaxId};	
	my $entryHashRef = $upIdAndTaxIdEntryHash{$upIdAndTaxId};
	my %entryHash = %$entryHashRef;
	$scoreFile = $upIdAndTaxId;
	$scoreFile =~ s/\t/-/;
	open(SCORE, ">", "../data/score_inc_all/".$scoreFile."_score.txt");
	print SCORE "Accession"."\t"."#PMID"."\t"."#PDB"."\t"."SwissProt"."\t"."Sum\n";
	foreach my $ac (sort keys %entryHash) {
		@rec = split(/\t/, $entryHash{$ac});
		my $weightedSeqPmidScore = 100*(1+(($rec[1] - $minSeqPmidScore)/$rangeSeqPmidScore));
		my $weightedSeqPdbScore = 10*(1+(($rec[2] - $minSeqPdbScore)/$rangeSeqPdbScore));
		my $weightedSeqSPScore = 1*(1+(($rec[3] - $minSeqSPScore)/$rangeSeqSPScore));
		#$scoreSum = $weightedSeqPmidScore + $weightedSeqPdbScore + $rec[3];
		$scoreSum = $weightedSeqPmidScore + $weightedSeqPdbScore + $weightedSeqSPScore;
		
		print SCORE $ac."\t".$rec[1]."\t".$rec[2]."\t".$rec[3]."\t".$scoreSum."\n";	
	}
	close(SCORE);										
}
close(COMPLETE);


if( ! -d "../data/score_inc_all") {
	system("mkdir -p ../data/score_inc_all");
}
$minPPmidScore = 100000000000;
$maxPPmidScore = -1;
$minPPdbScore = 100000000000;
$maxPPdbScore = -1;
$minPSpScore = 10000000000;
$maxPSpScore = -1;
$minEntryTotal = 1000000000000;
$maxEntryTotal = -1;

for my $upIdAndTaxId (sort keys(%upIdAndTaxIdHash)) {
	my $ppmidScore = keys %{ $upIdAndTaxIdPmidHash{$upIdAndTaxId}};
	my $ppdbScore = keys %{ $upIdAndTaxIdPdbHash{$upIdAndTaxId}};
	my $pspScore = keys %{ $upIdAndTaxIdSpHash{$upIdAndTaxId}};
	my $entryTotal = keys %{ $upIdAndTaxIdEntryHash{$upIdAndTaxId}};
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
}
$rangePPmidScore = $maxPPmidScore - $minPPmidScore;
print "PMID: $rangePPmidScore = $maxPPmidScore - $minPPmidScore\n";

$rangePPdbScore = $maxPPdbScore - $minPPdbScore;
print "PDB: $rangePPdbScore = $maxPPdbScore - $minPPdbScore\n";

$rangePSpScore = $maxPSpScore - $minPSpScore; 
print "SP: $rangePSpScore = $maxPSpScore - $minPSpScore\n"; 

$rangeEntryTotal = $maxEntryTotal - $minEntryTotal;
print "Entry: $rangeEntryTotal = $maxEntryTotal - $minEntryTotal\n";

 
open(PSCORE, ">", "../data/score_inc_all/proteomeScores.txt");
#print PSCORE "Taxon"."\t"."#PMID"."\t"."#PDB"."\t"."#SwissProt"."\t"."ScoreSum"."\t"."TotalEntries"."\t"."ScoreSum/TotalEntries"."\n";		
print PSCORE "UPID"."\t"."Taxon"."\t"."#PMID"."\t"."#PDB"."\t"."#SwissProt"."\t"."ScoreSum"."\t"."TotalEntries"."\t"."ScoreSum/TotalEntries"."\t"."ReferenceProteome"."\t"."PreviousRP\n";		
foreach my $upIdAndTaxId (sort keys(%upIdAndTaxIdHash)) {
	my $pPmidScore = keys %{ $upIdAndTaxIdPmidHash{$upIdAndTaxId}};
	my $pPdbScore = keys %{ $upIdAndTaxIdPdbHash{$upIdAndTaxId}};
	my $pSpScore = keys %{ $upIdAndTaxIdSpHash{$upIdAndTaxId}};
	my $entryTotal = keys %{ $upIdAndTaxIdEntryHash{$upIdAndTaxId}};
	my $weightedPPmidScore = 1000*(1+(($pPmidScore - $minPPmidScore)/$rangePPmidScore));
	print  "$upIdAndTaxId\t$weightedPPmidScore = 1000*(1+(($pPmidScore - $minPPmidScore)/$rangePPmidScore))\n";
	my $weightedPPdbScore = 100*(1+(($pPdbScore - $minPPdbScore)/$rangePPdbScore));
	print "$upIdAndTaxId\t$weightedPPdbScore = 100*(1+(($pPdbScore - $minPPdbScore)/$rangePPdbScore))\n";
	my $weightedPSpScore = 10*(1+(($pSpScore - $minPSpScore)/$rangePSpScore));
	print "$upIdAndTaxId\t$weightedPSpScore = 10*(1+(($pSpScore - $minPSpScore)/$rangePSpScore))\n";
	my $weightedEntryTotal = 1+(($entryTotal - $minEntryTotal)/$rangeEntryTotal);
	print "$upIdAndTaxId\t$weightedEntryTotal = 1+(($entryTotal - $minEntryTotal)/$rangeEntryTotal)\n";

	if($refp{$upIdAndTaxId}) {
		$refpScore = 1;	
	}
	else {
		$refpScore = 0;
	}
	if($prevRP{$upIdAndTaxId}) {
		$RPScore = 1;
	}
	else {
		$RPScore = 0;
	}
	my $weightedRefpScore = 10000 *(1+(($refpScore - 0)/1));
	print "$upIdAndTaxId\t$weightedRefpScore = 10000 *(1+(($refpScore - 0)/1))\n";
	my $weightedRPScore = 8000*(1+(($RPScore - 0)/1));
	print "$upIdAndTaxId\t$weightedRPScore = 8000*(1+(($RPScore - 0)/1))\n";
	
	my $scoreSum = $weightedRefpScore + $weightedRPScore + $weightedPPmidScore + $weightedPPdbScore + $weightedPSpScore + $weightedEntryTotal;
	my $average = $scoreSum/$entryTotal;
	print PSCORE $upIdAndTaxId."\t".$pPmidScore."\t".$pPdbScore."\t".$pSpScore."\t".$scoreSum."\t".$entryTotal."\t".$average."\t";	
	if($refp{$upIdAndTaxId}) {
		print PSCORE "RefP\t";
	}
	else {
		print PSCORE "\t";
	}
	if($prevRP{$upIdAndTaxId}) {
		print PSCORE "PrevRP\n";
	}
	else {
		print PSCORE "\n";
	}
	print $upIdAndTaxId."\t".$pPmidScore." (PMID)\t".$pPdbScore." (PDB)\t".$pSpScore." (SP)\t".$scoreSum." (SUM)\t".$entryTotal." (Entry)\t".$average." (AVG)\t".$refp{$upIdAndTaxId}."\t".$prevRP{$upIdAndTaxId}."\n";	
	print "$upIdAndTaxId: $scoreSum = $weightedRefpScore (RefP)\t$weightedRPScore (PrevRP)\t$weightedPPmidScore (PMID)\t$weightedPPdbScore (PDB)\t$weightedPSpScore (SP)\t$weightedEntryTotal (Entry)\n";
}
close(PSCORE);
