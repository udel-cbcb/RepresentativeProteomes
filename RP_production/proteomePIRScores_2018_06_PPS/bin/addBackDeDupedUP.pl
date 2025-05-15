#!/usr/bin/perl


use Proteome;
use Protein;
use UniRef50;

if($ARGV[0] eq "") {
	$Yin = 0.5;
}
else {
	$Yin = $ARGV[0];
}

local $start = time;
$date = `date`;
print "Start at ".$date;

#UPID   TaxId   RefP    PrevRP  #UniqPMID       ASMean  #Entry  NormPMID        NormASMean      NormEntryCount  Sum
##UP000008520    420890  RefP    PrevRP  0       11.0638209266008        1921    1000    110.50278872622 1.01915875457487        19111.5219474808
#
%upIdAndTaxIdScoresHash;
%upIdAndTaxIdScoreStrHash;
%upIdAndTaxIdEntryTotalHash;
%upIdAndTaxIdScore95Hash;
print "Getting proteome score ...\n";
open(PSCORE, "<", "../data/score/proteomeASScores.txt") or die "Can't open ../data/score/proteomeASScores.txt\n";
while($line = <PSCORE>) {
        chomp($line);
	if($line !~ /^UPID/) {
        	@rec = split(/\t/, $line);
        	$upIdAndTaxId = $rec[0]."-".$rec[1];
        	$entryTotal = $rec[6];
        	$pScore = $rec[10];
		$upIdAndTaxIdEntryTotalHash{$upIdAndTaxId} = $entryTotal;
		$upIdAndTaxIdScoresHash{$upIdAndTaxId} = $pScore;
		$refp{$upIdAndTaxId} = $rec[2];
		if($rec[3] eq "PrevRP") {
			$prevRP = 1;	
			$upIdAndTaxIdScoresHash95{$upIdAndTaxId} = $pScore - 8000;
		}
		else {
			$prevRP = 0;
			$upIdAndTaxIdScoresHash95{$upIdAndTaxId} = $pScore;
		}
		if($rec[2] eq "RefP") {
                        $pps{$upIdAndTaxId} ="PPS:1,".$prevRP.",".$rec[4].",".sprintf("%.2f", $rec[5]).",".$rec[6];
                        $pps95{$upIdAndTaxId} ="PPS:1,0,".$rec[4].",".sprintf("%.2f", $rec[5]).",".$rec[6];
                }
                else {
                        $pps{$upIdAndTaxId} ="PPS:0,".$prevRP.",".$rec[4].",".sprintf("%.2f", $rec[5]).",".$rec[6];
                        $pps95{$upIdAndTaxId} ="PPS:0,0,".$rec[4].",".sprintf("%.2f", $rec[5]).",".$rec[6];
                }
	}
}
close(PSCORE);
print "Total upIdAndTaxIdScoresHash: ".keys(%upIdAndTaxIdScoresHash)."\n";
print "Getting proteome score ...done\n";

my $upIdToTaxIdHash = ();
 %proteomesHash;
print "Getting proteome info ...\n";
open(TAX, "<". "../data/up-taxonomy-complete_yes.tab") or die "Can't open ../data/up-taxonomy-complete_yes.tab\n";
while($line=<TAX>) {
        chomp($line);
        if($line !~ /^UPID/) {
                my @rec = split(/\t/, $line);
                my $upIdAndTaxId = $rec[0]."-".$rec[1];
		$upIdToTaxIdHash{$rec[0]} = $rec[1];	
                my $mnemonic = $rec[2];
                my $scientificName = $rec[3];
                my $lineage = $rec[9];
                my %uniRef50s=();
                my $proteome;
                if($lineage !~/^Viruses/) {
			if($upIdAndTaxIdScoresHash{$upIdAndTaxId} ne "") {
                        	$proteome  = Proteome->new($rec[0]."-".$rec[1], $rec[0], $rec[1], $mnemonic, $scientificName, $lineage, \%uniRef50s);
                        	$proteomesHash{$upIdAndTaxId} = $proteome;
			}
                }
        }
}
close(TAX);
print "Total ProteomesHash: ".keys(%proteomesHash)."\n";
print "Getting proteome info ...done\n";

##Accession      #UniqPMID       #ASTotal        NormPMID        NormASTotal     Sum
##A0A0A1FMR9     0       0.2     100     10      110

my %proteinsHash = ();
print "Getting entry score ...\n";
foreach my $upIdAndTaxId (sort keys %upIdAndTaxIdScoresHash)  {
	open(SCORE, "<", "../data/score/$upIdAndTaxId"."_AS.txt") or die "Can't open ../data/score/$upIdAndTaxId"."_AS.txt\n";
	while($line = <SCORE>) {
       		chomp($line);
		if($line !~ /^Accession/) {
        		my @rec = split(/\t/, $line);
        		$ac = $rec[0];
        		$score = $rec[5];
			$protein = Protein->new($ac);
        		$protein->setScore($score);
        		$proteinsHash{$upIdAndTaxId}{$ac} = $protein;
		}
	}
	close(SCORE);
}
print "Getting entry score ...done\n";

my %proteomeUniRefEntryHash;
open(UNIREF, "<", "../data/uniref50.dat") or die "Can't open ../data/uniref50.dat\n";
print "Reading uniRef50 ...\n";
while($line =<UNIREF>) {
	chomp($line);
	@rec = split(/\t/, $line);
	$ac = $rec[0];
	$upIdAndTaxId = $rec[1]."-".$rec[2];
	$uniRefAc = $rec[3];
	if($proteinsHash{$upIdAndTaxId}{$ac}) {
		$proteomeUniRefEntryHash{$upIdAndTaxId}{$uniRefAc}{$ac} = $proteinsHash{$upIdAndTaxId}{$ac};		
		$entryProteomeHash{$ac}{$upIdAndTaxId} = $uniRefAc;		
		$count++;
		if($count % 1000000 eq 0) {
			$date = `date`;
			print $date;
			print "UniRef50 read ".$count." .. done\n";
		}	
	}	
}
close(UNIREF);
print "Reading uniRef50 ... done\n";

my %proteomesScoreHash=(); 
processProteomes();


sub processProteomes {
	foreach my $upIdAndTaxId (keys %proteomeUniRefEntryHash) {
		my $proteome = $proteomesHash{$upIdAndTaxId};
		print "Proteome: ".$proteome->getUPIdAndTaxId()."\n";
        	print "Mnemonic: ".$proteome->getMnemonic()."\n";
        	print "ScientificName: ".$proteome->getScientificName()."\n";
        	print "Lineage: ".$proteome->getLineage()."\n";
		my $memberCount = 0;
		my %members = ();
		my %uniRef50s;
		foreach my $uniRefAc ( keys %{ $proteomeUniRefEntryHash{$upIdAndTaxId}}) {
			$uniRef50s{$uniRefAc} = "1";
			my $proteinsRef = $proteomeUniRefEntryHash{$upIdAndTaxId}{$uniRefAc};	
			my %proteins = %$proteinsRef;
			my $entrySize = keys %proteins;
			foreach my $entryAc (keys %proteins) {
				my $protein = $proteinsHash{$upIdAndTaxId}{$entryAc};
				if($members{$entryAc} eq "") {
					$members{$entryAc} = $protein;
					$memberCount++;
				}
			}
		}
		$proteome->setUniRef50s(\%uniRef50s);
		$proteome->setMembers(\%members);
		$proteome->setMemberCount($memberCount);
		$score = $upIdAndTaxIdScoresHash{$upIdAndTaxId};
		$proteome->setEntryTotal($upIdAndTaxIdEntryTotalHash{$upIdAndTaxId});
		$proteome->setScore($score);
		$scoreKey = sprintf("%d", $score*100000000);
		$scoreKey += 10000000000000;
		$scoreKey .=".".$proteome->getUPIdAndTaxId();
		if($scoreKey) {
			$proteomesScoreHash{$scoreKey} = $proteome->getUPIdAndTaxId();	
		}
		my $uniRefSize = keys %{ $proteomeUniRefEntryHash{$upIdAndTaxId}};
		print "Score: ".$proteome->getScore()."\n";
		print "my TotalEntries: ".keys(%members)."\n";
		print "TotalEntries: ".$proteome->getEntryTotal()."\n";
		print "MemberCount: ".$proteome->getMemberCount()."\n";
		print "UniRef Size: ".$uniRefSize."\n";
		print "\n\n";			
	}
}

print "Score Hash size: ".(keys %proteomesScoreHash)."\n";
foreach my $key (reverse (sort keys(%proteomesScoreHash))) {
	#print $key." <-> ".$proteomesScoreHash{$key}."\n";
}
my %upIdAndTaxIdSumCorrHash = ();
my %sumCorrTaxIdHash=();
my %upIdAndTaxIdPairsCorrHash = ();
open(CORRTAB, "<", "../data/proteomesCorrTable.txt") or die "Can't open ../data/proteomesCorrTable.txt";
while($line=<CORRTAB>) {
	chomp($line);
	my ($upIdAndTaxId1, $upIdAndTaxId2, $corrScore) = (split(/\t/, $line))[0, 1, 2];
	if($upIdAndTaxIdScoresHash{$upIdAndTaxId1} && $upIdAndTaxIdScoresHash{$upIdAndTaxId2}) {
		$upIdAndTaxIdPairsCorrHash{$upIdAndTaxId1}{$upIdAndTaxId2} = $corrScore;			
		$upIdAndTaxIdPairsCorrHash{$upIdAndTaxId2}{$upIdAndTaxId1} = $corrScore;			
		$upIdAndTaxIdSumCorrHash{$upIdAndTaxId1} += $corrScore;
	}
}
close(CORRTAB);
for my $key (keys %upIdAndTaxIdSumCorrHash) {
	$scoreKey = sprintf("%d", $upIdAndTaxIdSumCorrHash{$key}*100000000);
        $scoreKey += 10000000000000;
        $scoreKey .=".".$key;
        $sumCorrTaxIdHash{$scoreKey} = $key;
}

my %upIdAndTaxIdSumCorrHash95 = ();
my %sumCorrTaxIdHash95=();
my %upIdAndTaxIdPairsCorrHash95 = ();
open(CORRTAB, "<", "../data/proteomesCorrTableMin.txt") or die "Can't open ../data/proteomesCorrTableMin.txt";
while($line=<CORRTAB>) {
	chomp($line);
	my ($upIdAndTaxId1, $upIdAndTaxId2, $corrScore) = (split(/\t/, $line))[0, 1, 2];
	if($upIdAndTaxIdScoresHash95{$upIdAndTaxId1} && $upIdAndTaxIdScoresHash95{$upIdAndTaxId2}) {
		$upIdAndTaxIdPairsCorrHash95{$upIdAndTaxId1}{$upIdAndTaxId2} = $corrScore;			
		#$upIdAndTaxIdPairsCorrHash95{$upIdAndTaxId2}{$upIdAndTaxId1} = $corrScore;			
		$upIdAndTaxIdSumCorrHash95{$upIdAndTaxId1} += $corrScore;
	}
}
close(CORRTAB);
for my $key (keys %upIdAndTaxIdSumCorrHash95) {
	$scoreKey = sprintf("%d", $upIdAndTaxIdSumCorrHash95{$key}*100000000);
        $scoreKey += 10000000000000;
        $scoreKey .=".".$key;
        $sumCorrTaxIdHash95{$scoreKey} = $key;
}


open(SG, "<", "../data/upIdAndTaxIdToSpeciesAndGenus.txt") or die "Can't open ../data/upIdAndTaxIdToSpeciesAndGenus.txt\n";
while($line=<SG>) {
        chomp($line);
        my @rec = split(/\:/, $line);
        $upIdAndTaxIdToSpecies{$rec[0]} = $rec[3];
        $upIdAndTaxIdToGenus{$rec[0]} = $rec[4];
        $upIdAndTaxIdToClass{$rec[0]} = $rec[5];
        $upIdAndTaxIdToPhylum{$rec[0]} = $rec[6];
}
close(SG);

open(IN, "../data/proteomes_complete.txt") or die "Can't open ../data/proteomes_complete.txt\n";
while($line=<IN>) {
	chomp($line);
	if($line !~ /^Taxon/) {
		($taxId, $upId, $scientificName) = (split(/\t/, $line))[0, 2, 3];
		$upIdAndTaxIdToScientificName{$upId."-".$taxId}  = $scientificName;
	}
}
close(IN);

open(TAXGROUP, "<", "../data/upIdAndTaxIdToTaxGroup.txt") or die "Can't open ../data/upIdAndTaxIdToTaxGroup.txt\n";
while($line=<TAXGROUP>) {
        chomp($line);
        my @rec= split(/\t/, $line);
        my  $upIdAndTaxId = $rec[0];
        my $taxGroupName = "";
        if($rec[1] eq "Archaea/..") {
                $taxGroupName = "Other Archaea";
        }
        elsif($rec[1] eq "Bac/..") {
                $taxGroupName = "Other Bacteria";
        }
        elsif($rec[1] eq "Euk/..") {
                $taxGroupName = "Other Eukaryota";
        }
        else {
                $taxGroupName = $rec[1];
        }
        $upIdAndTaxIdToTaxGroupName{$upIdAndTaxId} = $taxGroupName;
}
close(TAXGROUP);

open(DEDUP, "../data/dedupe_info.txt") or die "Can't open ../data/dedupe_info.txt\n";
while($line=<DEDUP>) {
        chomp($line);
        ($count, $taxId, $keepUPId, $removeUPIds) = (split(/\t/, $line))[0,1,2,3];
        $taxKeep{$taxId} = $keepUPId;
        $taxRemove{$taxId} = $removeUPIds;
}
close(DEDUP);
# >243159 ACIF2   Acidithiobacillus ferrooxidans (strain ATCC 23270 / DSM 14882 / NCIB 8455) (Ferrobacillus ferrooxidans (strain ATCC 23270))     1111.25953(AS)  15(CUTOFF)
# 380394 ACIF5   Acidithiobacillus ferrooxidans (strain ATCC 53993) (Leptospirillum ferrooxidans (ATCC 53993))   1111.15979(AS)  83.25548(X)



my @loop = (75, 55, 35, 15);

foreach(@loop) {
        $cutoff = $_;
        $originalRPGFile = "../results_corr_consist/$cutoff/rpg-$cutoff.txt.orig";
        $rpgTmpFile = "../results_corr_consist/$cutoff/rpg-$cutoff.txt.tmp";
        $rpgFile = "../results_corr_consist/$cutoff/rpg-$cutoff.txt";
        $rpgFileFixed = "../results_corr_consist/$cutoff/rpg-$cutoff.txt.fixed";
        $cmd = "cp $rpgFile $originalRPGFile";
        print $cmd."\n";
	`$cmd`;
        $cmd = "cp $rpgFile $rpgTmpFile";
        print $cmd."\n";
	`$cmd`;
	
	open(TMP, ">", $rpgTmpFile) or die "Can't open $rpgTmpFile\n";
	open(RPG, $originalRPGFile) or die "Can't open $originalRPGFile\n";
	while($line=<RPG>) {
        	if($line =~ /^>/) {
                	print TMP $line;
        	}
        	elsif($line =~ /^$/) {
                	print TMP "\n";
        	}
        	else {
                	($upId, $taxId) = (split(/\t/, $line))[0, 1];
                	$upId =~ s/^\s+//;
                	if($taxKeep{$taxId}) {
                        	if($taxKeep{$taxId} ne $upId) {
                               		$taxRemove{$taxId}.= ";".$upId;
                        	}
                        	else {
                                	print TMP $line;
                        	}
                	}
                	else {
                        	print TMP $line;
                	}
        	}
	}
	close(TMP);

	open(TAXREMOVE, ">", "../data/taxRemove.txt") or die "Can't open ../data/taxRemove.txt\n";
	for $k (keys %taxRemove) {
        	print TAXREMOVE $k."\t".$taxRemove{$k}."\n";
	}
	close(TAXREMOVE);

	my %rpgMembers = ();
	open(TMP, $rpgTmpFile) or die "Can't open $rpgTmpFile";
	#open(RPG, ">", $rpgFileFixed) or die "Can't open $rpgFileFixed";
	open(RPG, ">", $rpgFile) or die "Can't open $rpgFile";
	#print "Writing $rpgFileFixed\n";
	print "Writing $rpgFile\n";
	while($line=<TMP>) {
		#print $line;
        	if($line =~ /^>/) {
                	%rpgMembers = ();
                	my ($upId, $taxId, $osCode, $seedX) = (split(/\t/, $line))[0, 1, 2, 8];
                	$upId =~ s/^>//;
			$rp = $upId."-".$taxId;
                	chomp($seedX);
                	$seedX =~ s/\(X-seed\)//;
                	if($seedX == 100.0000) {
                        	$seed = $upId."-".$taxId;
                	}
                	print RPG $line;
                	if($taxRemove{$taxId}) {
                        	$removed = $taxRemove{$taxId};
                        	$removed =~ s/\;$//;
                        	my @rec = split(/\;/, $removed);
                        	foreach(@rec) {
                                	#$rpgMembers{$_."-".$taxId} = " ".$_."\t".$taxId."\n";
                        		$rpgMembers{$_."-".$upIdToTaxIdHash{$_}} = " ".$_."\t".$upIdToTaxIdHash{$_}."\n";
                        	}
                	}
        	}
        	elsif($line =~ /^$/) {
                	for $k (sort keys %rpgMembers) {
				if($val =~ /X-seed/) {
                                	print RPG $rpgMembers{$k};
                        	}	
				else {
					print RPG getProteomeInfo($k, $seed, $rp);						
				}
                        	#print RPG $rpgMembers{$k};
                	}
                	print RPG "\n";
        	}
        	else {
                	my ($upId, $taxId, $osCode, $seedX) = (split(/\t/, $line))[0, 1, 2, 8];
                	$upId =~ s/^\s+//;
			chomp($seedX);
                	$seedX =~ s/\(X-seed\)//;
                	if($seedX  == 100.00000) {
                        	$seed = $upId."-".$taxId;
                	}

                	if($taxKeep{$taxId}) {
				
                        	$rpgMembers{$upId."-".$upIdToTaxIdHash{$upId}} = " ".$upId."\t".$upIdToTaxIdHash{$upId}."\n";
                        	$removed = $taxRemove{$taxId};
                        	$removed =~ s/\;$//;
                        	my @rec = split(/\;/, $removed);
                        	foreach(@rec) {
                        		$rpgMembers{$_."-".$upIdToTaxIdHash{$_}} = " ".$_."\t".$upIdToTaxIdHash{$_}."\n";
                                	#$rpgMembers{$_."-".$taxId} = " ".$_."\t".$taxId."\n";
                        	}
                	}
                	else {
                        	$rpgMembers{$upId."-".$upIdToTaxIdHash{$upId}} = $line;
                	}
        	}
	}
	close(TMP);
	close(RPG);
	#print "Writing $rpgFileFixed done\n";
	print "Writing $rpgFile done\n";
}

sub getProteomeInfo {
	my ($key2, $seed, $rp) = @_;	
	print "|$key2|$seed|$rp|\n";
	my $proteome2 = $proteomesHash{$key2};
        my $genusId2 = $upIdAndTaxIdToGenus{$proteome2->getUPIdAndTaxId()};
        my $genusName2 = $upIdAndTaxIdToScientificName{$genusId2};

        $master = $seed;
        $upId = $proteome2->getUPId();
        $taxonomyId = $proteome2->getTaxId();
        my $dataStr = "";
        $dataStr =  " ".$upId."\t".$taxonomyId."\t".$proteome2->getMnemonic()."\t".$proteome2->getScientificName()."\t".$upIdAndTaxIdToTaxGroupName{$key2}."\t".sprintf("%.5f", $proteome2->getScore())."(".$pps{$proteome2->getUPIdAndTaxId()}.")\t".sprintf("%.5f", $upIdAndTaxIdPairsCorrHash{$rp}{$key2})."(X-RP)"."\t".$refp{$proteome2->getUPIdAndTaxId()}."\t".sprintf("%.5f", $upIdAndTaxIdPairsCorrHash{$master}{$key2})."(X-seed)"."\n";
	return $dataStr;
}

sub getMeanCorr {
        my ($Xin, %carryOverMeanCorrTaxIdHash) = @_;
        %upIdAndTaxIdSumCorrHash=();
        %meanCorrTaxIdHash=();
        %sumCorrCountHash = 0;
        for my $key (keys %carryOverMeanCorrTaxIdHash) {
                $usableTaxIdHash{$carryOverMeanCorrTaxIdHash{$key}} = 1;
        }
	if($Xin == 95) {
        	open(CORRTAB, "<", "../data/proteomesCorrTableMin.txt") or die "Can't open ../data/proteomesCorrTableMin.txt\n";
	}
	else {
        	open(CORRTAB, "<", "../data/proteomesCorrTable.txt") or die "Can't open ../data/proteomesCorrTable.txt\n";
	}
        while($line=<CORRTAB>) {
                chomp($line);
                my ($upIdAndTaxId1, $upIdAndTaxId2, $corrScore) = (split(/\t/, $line))[0, 1, 2];
                if($upIdAndTaxIdScoresHash{$upIdAndTaxId1} && $upIdAndTaxIdScoresHash{$upIdAndTaxId2} && $usableTaxIdHash{$upIdAndTaxId1}) {
                        if($corrScore >= $Xin && $upIdAndTaxId1 ne $upIdAndTaxId2) {
                        #if($corrScore >= $Xin) {
                                print "$Xin CorrScore: $corrScore ($upIdAndTaxId1, $upIdAndTaxId2)\n";
                                $upIdAndTaxIdSumCorrHash{$upIdAndTaxId1} += $corrScore;
                                $sumCorrCountHash{$upIdAndTaxId1} += 1;
                        }
                }
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

sub computeRPGAndPanProteome {
	my ($Xin, %mySumCorrTaxIdHashOrigin) = @_;
	print "Xin: ".$Xin."\n";
	print "InputProteomeScoreHash: ".keys(%mySumCorrTaxIdHashOrigin)."\n";

        my %runningProteomesScoreHash = ();
        my %tmpProteomesScoreHash = ();
	my %mySumCorrTaxIdHash = %mySumCorrTaxIdHashOrigin;
	my %meanCorrAtXin = getMeanCorr($Xin, %mySumCorrTaxIdHashOrigin);
	for my $k (keys %meanCorrAtXin) {
		print "MeanCorrAt $Xin: $k $meanCorrAtXin{$k}\n";
	}
	for my $scoreKey (reverse (sort keys %mySumCorrTaxIdHash)) {
		my $proteomeTaxId = $mySumCorrTaxIdHash{$scoreKey};
		$meanCorrScoreKey = $meanCorrAtXin{$proteomeTaxId};
		if($meanCorrScoreKey) {
			print "Xin $Xin: deleting $scoreKey $proteomeTaxId\n";
			delete $mySumCorrTaxIdHash{$scoreKey};
			$mySumCorrTaxIdHash{$meanCorrScoreKey} = $proteomeTaxId;	
			print "Xin $Xin: adding $meanCorrScoreKey $proteomeTaxId\n";
		}	
	}	
	my @sortedSumCorrTaxIdArray = ();
        foreach my $myProteomesKey (reverse (sort keys (%mySumCorrTaxIdHash))) {
                $runningProteomesScoreHash{$myProteomesKey} = $mySumCorrTaxIdHash{$myProteomesKey};
                $tmpProteomesScoreHash{$myProteomesKey} = $mySumCorrTaxIdHash{$myProteomesKey};
                print "$Xin|".$myProteomesKey ."|=|". $mySumCorrTaxIdHash{$myProteomesKey}."|\n";
		push(@sortedSumCorrTaxIdArray, $myProteomesKey);
        }

	my %rpgHash = ();
	my %rpgXHash = ();
	my %rpgNameHash = ();
	my $rpgTotal = 0;
        my %seedHash = ();
	#foreach my $key1 (reverse (sort keys(%mySumCorrTaxIdHash))) {
	foreach(@sortedSumCorrTaxIdArray) {
		$key1 = $_;
		my $upIdAndTaxId1 = $mySumCorrTaxIdHash{$key1};
		if($upIdAndTaxId1 ne "1") {
			$mySumCorrTaxIdHash{$key1} = "1";
			$rpgHashTmp{$upIdAndTaxId1} = $upIdAndTaxId1.";";		
			print "Outer $Xin: ".$upIdAndTaxId1."\n";	
			$seed = $upIdAndTaxId1;	
			#foreach my $key2 (reverse (sort keys(%mySumCorrTaxIdHash))) {
			foreach (@sortedSumCorrTaxIdArray) {
				$key2 = $_;
				my $upIdAndTaxId2 = $mySumCorrTaxIdHash{$key2};
				if($upIdAndTaxId2 ne "1") {
					my $x = "";
					if($Xin == 95) {	
						$x = $upIdAndTaxIdPairsCorrHash95{$upIdAndTaxId1}{$upIdAndTaxId2};
					}
					else {
						$x = $upIdAndTaxIdPairsCorrHash{$upIdAndTaxId1}{$upIdAndTaxId2};
					}
					if($x >= $Xin) {
						print $upIdAndTaxId1. " vs ".$upIdAndTaxId2.": x = ".$x." (". $Xin.")\n";
						$mySumCorrTaxIdHash{$key2} = "1";
						print "$Xin deleting 1 |$key1|$key2|\n";
						delete $runningProteomesScoreHash{$key1};
						print "$Xin deleting 2 |$key1|$key2|\n";
						delete $runningProteomesScoreHash{$key2};
						$rpgHashTmp{$upIdAndTaxId1} .= $upIdAndTaxId2.";";		
						$rpgXHashTmp{$upIdAndTaxId1."-".$upIdAndTaxId2} = $x;		
					}
					else {
						#print $taxId1." vs ".$taxId2." : ".$Xin ." : ".$x." less than\n"; 
					}	
				}	
			}
			#delete $runningProteomesScoreHash{$key1};
			$groupMemberList = $rpgHashTmp{$upIdAndTaxId1};
			print "$Xin Group meber list:".$upIdAndTaxId1." ".$groupMemberList."\n";	
			$groupMemberList =~ s/\;$//;
			@groupMembers = split(/;/, $groupMemberList);
			
			 my %seen1 = ();
                	my @unique1 = grep { ! $seen1{$_}++} @groupMembers;
			my %groupMemberScoreHash = ();
			foreach(@unique1) {
				my $upIdAndTaxId = $_;
			 	my $proteomeScore = "";
				if($Xin == 95) {
					$proteomeScore = $upIdAndTaxIdScoresHash95{$upIdAndTaxId};
				}
				else {
					$proteomeScore = $upIdAndTaxIdScoresHash{$upIdAndTaxId};
				}
				print "P: ".$upIdAndTaxId." score:".$proteomeScore."\n";
				$scoreKey = sprintf("%d", $proteomeScore*100000000);
				$scoreKey += 10000000000000;
				$scoreKey .=".".$upIdAndTaxId;
				$groupMemberScoreHash{$scoreKey} = $upIdAndTaxId;
				if($runningRP{$upIdAndTaxId}) {
					my $runningMemberList = $runningRP{$upIdAndTaxId}; 
					$runningMemberList =~ s/\;$//;
					my @runningMember = split(/;/, $runningMemberList);
					foreach my $m (@runningMember) {
						print "$Xin runningRP: |$upIdAndTaxId|$m|\n";
			 			my $proteomeScore = $upIdAndTaxIdScoresHash{$m};
						print "$Xin PM: ".$m." score:".$proteomeScore."\n";
						$scoreKey = sprintf("%d", $proteomeScore*100000000);
						$scoreKey += 10000000000000;
						$scoreKey .=".".$m;
						$groupMemberScoreHash{$scoreKey} = $m;
					}	
				}
			}
			$newGroupMemberList = ""; 
			for my $key (reverse sort(keys %groupMemberScoreHash)) {
				print $groupMemberScoreHash{$key}."<-->".$key."\n";
				$newGroupMemberList .= $groupMemberScoreHash{$key}.";";
			}
			my $rpgMemberOnly = "";
			print "New Group: ".$newGroupMemberList."\n";
			$newGroupMemberList =~ s/\;$//;
			@newGroupMembers = split(/;/, $newGroupMemberList);
			
			$newTaxId1 = $newGroupMembers[0];
			$rpgMemberOnly = $newTaxId1.";";
			print "$Xin newTaxId1: |".$newTaxId1."|\n";
        		foreach my $key3 (keys (%tmpProteomesScoreHash)) {
				print "Xin $Xin |$newTaxId1|$key3|$tmpProteomesScoreHash{$key3}|\n";
				#if($tmpProteomesScoreHash{$key3} eq $newTaxId1) {
				#	print "$Xin adding back ".$key3." | ".$newTaxId1."|\n";
				#	$runningProteomesScoreHash{$key3} = $newTaxId1;
				#}
				if($tmpProteomesScoreHash{$key3} eq $seed) {
					print "$Xin adding back ".$key3." | ".$seed."|\n";
					$runningProteomesScoreHash{$key3} = $seed;
				}
			}		
			$rpgHash{$newTaxId1} = $newTaxId1.";";
			$seedHash{$newTaxId1} = $seed;
			#$groupSize = @newGroupMembers;
			 my %seen2 = ();
                	my @unique2 = grep { ! $seen2{$_}++} @newGroupMembers;
                	$groupSize = @unique2;
			
			for(my $i=1; $i < $groupSize; $i++) {
				#$newTaxId2 = $newGroupMembers[$i];
				$newTaxId2 = $unique2[$i];
				$rpgMemberOnly .= $newTaxId2.";";
				$rpgHash{$newTaxId1} .= $newTaxId2.";";
				if($Xin == 95) {
					$rpgXHash{$newTaxId1."-".$newTaxId2} = $upIdAndTaxIdPairsCorrHash95{$newTaxId1}{$newTaxId2};		
				}
				else {
					$rpgXHash{$newTaxId1."-".$newTaxId2} = $upIdAndTaxIdPairsCorrHash{$newTaxId1}{$newTaxId2};		
				}
			}
			print "newTaxId1: ".$newTaxId1."\n"; 	
			my $rpgProteome = $proteomesHash{$newTaxId1};
	        	#$rpgNameHash{$rpgProteome->getScientificName()} = $newTaxId1;
	        	$rpgNameHash{$rpgProteome->getUPId()."_".$rpgProteome->getScientificName()} = $newTaxId1;
			#$runningRP{$newTaxId1} .= $rpgMemberOnly;	
			$runningRP{$seed} .= $rpgMemberOnly;	
		}
	}
	my %upIdAndTaxEntryHash=();
	if( !-d "../results_corr_consist") {
		mkdir("../results_corr_consist") || print $!;
	}	
	if( !-d "../results_corr_consist/$Xin") {
		mkdir("../results_corr_consist/$Xin") || print $!;
	}

	print "rpgNameHash size: ".(keys(%rpgNameHash))."\n";	
	open(RPG, ">", "../results_corr_consist/$Xin/rpg"."-".$Xin.".txt") or die "Can't open $Xin file\n";
	foreach my $k1 (sort keys(%rpgNameHash)) { 
		my $key1 = $rpgNameHash{$k1};
		my $proteome1 = $proteomesHash{$key1};
		my $genusId1 = $upIdAndTaxIdToGenus{$proteome1->getUPIdAndTaxId()};
                my $genusName1 = $upIdAndTaxIdToScientificName{$genusId1};

		$master = $seedHash{$key1};
               	$upId = $proteome1->getUPId();
               	$taxonomyId = $proteome1->getTaxId();
		if($Xin == 95) {
			#print RPG ">".$upId."\t".$taxonomyId."\t".$proteome1->getMnemonic()."\t".$proteome1->getScientificName()."\t".$upIdAndTaxIdToTaxGroupName{$key1}."\t".sprintf("%.5f", $proteome1->getScore())."(".$pps95{$proteome1->getUPIdAndTaxId()}.")\t".$Xin."(CUTOFF)"."\t".$refp{$proteome1->getUPIdAndTaxId()}."\t".sprintf("%.5f", $upIdAndTaxIdPairsCorrHash95{$master}{$key1})."(X-seed)"."\n";
			print RPG ">".$upId."\t".$taxonomyId."\t".$proteome1->getMnemonic()."\t".$proteome1->getScientificName()."\t".$upIdAndTaxIdToTaxGroupName{$key1}."\t".sprintf("%.5f", $upIdAndTaxIdScoresHash95{$proteome1->getUPIdAndTaxId()})."(".$pps95{$proteome1->getUPIdAndTaxId()}.")\t".$Xin."(CUTOFF)"."\t".$refp{$proteome1->getUPIdAndTaxId()}."\t".sprintf("%.5f", $upIdAndTaxIdPairsCorrHash95{$master}{$key1})."(X-seed)"."\n";
		}
		else {
			print RPG ">".$upId."\t".$taxonomyId."\t".$proteome1->getMnemonic()."\t".$proteome1->getScientificName()."\t".$upIdAndTaxIdToTaxGroupName{$key1}."\t".sprintf("%.5f", $proteome1->getScore())."(".$pps{$proteome1->getUPIdAndTaxId()}.")\t".$Xin."(CUTOFF)"."\t".$refp{$proteome1->getUPIdAndTaxId()}."\t".sprintf("%.5f", $upIdAndTaxIdPairsCorrHash{$master}{$key1})."(X-seed)"."\n";
		}

		$rpgTotal++;
		$nrp = $rpgHash{$key1};
		print "nrp1:".$nrp."\n";
		$nrp =~ s/\;$//;
		print "nrp:".$nrp."\n";
		@rec = split(/\;/, $nrp);
		my $uniRef50sRef1 = $proteome1->getUniRef50s();
		my %uniRef50s1 = %$uniRef50sRef1;
		my $membersRef1 = $proteome1->getMembers();
		my %members1 = %$membersRef1;
		my %panMembers= ();
		my $upIdAndTaxId1 = $proteome1->getUPIdAndTaxId();
		print "taxMember: ".$upIdAndTaxId1."|||".keys(%members1)."\n";
		foreach my $key1 (keys %members1) {
			$upIdAndTaxEntryHash{$upIdAndTaxId1}{$upIdAndTaxId1}{$key1} = 1;
			my ($upId, $taxonomyId) = (split(/-/, $upIdAndTaxId1))[0, 1];
			$panMembers{$key1} = $upId."\t".$taxonomyId."\t".$entryProteomeHash{$key1}{$upIdAndTaxId1}; 	
		}
		my %seen = ();
                my @unique = grep { ! $seen{$_}++} @rec;
                $nrpSize = @unique;

		if($nrpSize > 0) {	
			my %rpgMemberNameHash = ();	
			foreach(@unique) {
				my $key2 = $_;
				print "nrpkey: ".$key2."\n";
				my $proteome2 = $proteomesHash{$key2};
				my $genusId2 = $upIdAndTaxIdToGenus{$proteome2->getUPIdAndTaxId()};
                		my $genusName2 = $upIdAndTaxIdToScientificName{$genusId2};

				$master = $seedHash{$key1};
               			$upId = $proteome2->getUPId();
               			$taxonomyId = $proteome2->getTaxId();
                                my $dataStr = "";
                                if($Xin == 95) {
                                	#$dataStr =  " ".$upId."\t".$taxonomyId."\t".$proteome2->getMnemonic()."\t".$proteome2->getScientificName()."\t".$upIdAndTaxIdToTaxGroupName{$key2}."\t".sprintf("%.5f", $proteome2->getScore())."(".$pps95{$proteome2->getUPIdAndTaxId()}.")\t".sprintf("%.5f", $upIdAndTaxIdPairsCorrHash95{$key1}{$key2})."(X-RP)"."\t".$refp{$proteome2->getUPIdAndTaxId()}."\t".sprintf("%.5f", $upIdAndTaxIdPairsCorrHash95{$master}{$key2})."(X-seed)"."\n";
                                	$dataStr =  " ".$upId."\t".$taxonomyId."\t".$proteome2->getMnemonic()."\t".$proteome2->getScientificName()."\t".$upIdAndTaxIdToTaxGroupName{$key2}."\t".sprintf("%.5f", $upIdAndTaxIdScoresHash95{$proteome2->getUPIdAndTaxId()})."(".$pps95{$proteome2->getUPIdAndTaxId()}.")\t".sprintf("%.5f", $upIdAndTaxIdPairsCorrHash95{$key1}{$key2})."(X-RP)"."\t".$refp{$proteome2->getUPIdAndTaxId()}."\t".sprintf("%.5f", $upIdAndTaxIdPairsCorrHash95{$master}{$key2})."(X-seed)"."\n";
				}
				else {
                                	$dataStr =  " ".$upId."\t".$taxonomyId."\t".$proteome2->getMnemonic()."\t".$proteome2->getScientificName()."\t".$upIdAndTaxIdToTaxGroupName{$key2}."\t".sprintf("%.5f", $proteome2->getScore())."(".$pps{$proteome2->getUPIdAndTaxId()}.")\t".sprintf("%.5f", $upIdAndTaxIdPairsCorrHash{$key1}{$key2})."(X-RP)"."\t".$refp{$proteome2->getUPIdAndTaxId()}."\t".sprintf("%.5f", $upIdAndTaxIdPairsCorrHash{$master}{$key2})."(X-seed)"."\n";
				}
				if($key1 ne $key2) {
			        	$rpgMemberNameHash{$proteome2->getUPId()."-".$proteome2->getScientificName()} = $dataStr;
				}
				my $uniRef50sRef2 = $proteome2->getUniRef50s();
				my %uniRef50s2 = %$uniRef50sRef2;
				my $upIdAndTaxId = $proteome2->getUPIdAndTaxId();
					
				foreach my $uniRefAc (keys %uniRef50s2) {
					if($uniRef50s1{$uniRefAc} eq "") {
						my $proteinsRef = $proteomeUniRefEntryHash{$upIdAndTaxId}{$uniRefAc};
                        			my %proteins = %$proteinsRef;
						$protein = findTopProtein(\%proteins);
						if($protein) {
							$ac = $protein->getAC();
							#if($members1{$ac} eq "" && $panMembers{$ac} eq "") {
							if($panMembers{$ac} eq "") {
								#$panMembers{$ac} = $taxId."\tUniRef50_".$uniRefAc;
								($upId, $taxId) = (split(/-/, $upIdAndTaxId))[0, 1];
								$panMembers{$ac} = $upId."\t".$taxId."\t".$uniRefAc;
								$upIdAndTaxEntryHash{$proteome1->getUPIdAndTaxId()}{$upIdAndTaxId}{$ac} = 1;
								$uniRef50s1{$uniRefAc} = "1";
							}	
						}
					}
				}
			}
			foreach(sort keys %rpgMemberNameHash) {
				print RPG $rpgMemberNameHash{$_};
			}
	 		$proteome1->setPanMembers(\%panMembers);
		}
		print RPG "\n";
	}	
	close(RPG);
	print "RPG Total: ".$rpgTotal."\n";

	open(PP, ">", "../results_corr_consist/$Xin/pp"."-".$Xin.".txt") or die "Can't open $Xin pp file\n";
	foreach my $k1 (sort keys (%rpgNameHash)) {
		my $key1 = $rpgNameHash{$k1}; 
		my $proteome1 = $proteomesHash{$key1};
		my $panMembersRef = $proteome1->getPanMembers();
		my %panMembers = %$panMembersRef;
		my $panMemberSize = keys %panMembers;
		if($panMemberSize > 0) {
			my $genusId1 = $upIdAndTaxIdToGenus{$proteome1->getUPIdAndTaxId()};
                	my $genusName1 = $upIdAndTaxIdToScientificName{$genusId1};

               		$upId = $proteome1->getUPId(); 
               		$taxonomyId = $proteome1->getTaxId(); 
			if($Xin == 95) {	
				#print PP ">Pan-Proteome_".$upId."\t".$taxonomyId."\t".$proteome1->getMnemonic()."\t".$proteome1->getScientificName()."\t".$upIdAndTaxIdToTaxGroupName{$key1}."\t".sprintf("%.5f", $proteome1->getScore())."(".$pps95{$proteome1->getUPIdAndTaxId()}.")\t".$Xin."(CUTOFF)"."\t".$refp{$proteome1->getUPIdAndTaxId()}."\n";
				print PP ">Pan-Proteome_".$upId."\t".$taxonomyId."\t".$proteome1->getMnemonic()."\t".$proteome1->getScientificName()."\t".$upIdAndTaxIdToTaxGroupName{$key1}."\t".sprintf("%.5f", $upIdAndTaxIdScoresHash95{$proteome1->getUPIdAndTaxId()})."(".$pps95{$proteome1->getUPIdAndTaxId()}.")\t".$Xin."(CUTOFF)"."\t".$refp{$proteome1->getUPIdAndTaxId()}."\n";
			}
			else {
				print PP ">Pan-Proteome_".$upId."\t".$taxonomyId."\t".$proteome1->getMnemonic()."\t".$proteome1->getScientificName()."\t".$upIdAndTaxIdToTaxGroupName{$key1}."\t".sprintf("%.5f", $proteome1->getScore())."(".$pps{$proteome1->getUPIdAndTaxId()}.")\t".$Xin."(CUTOFF)"."\t".$refp{$proteome1->getUPIdAndTaxId()}."\n";
			}
			$upIdAndTaxId1 = $proteome1->getUPIdAndTaxId();		
			foreach my $memberTaxId (sort keys %{$upIdAndTaxEntryHash{$upIdAndTaxId1}}) {
				 my $entriesRef = $upIdAndTaxEntryHash{$upIdAndTaxId1}{$memberTaxId};
                                 my %entries = %$entriesRef;
				 my $memberCount = keys(%entries);
               			($upId, $taxonomyId) = (split(/-/, $memberTaxId))[0, 1]; 
				 print PP " #".$upId."\t".$taxonomyId."\t".$memberCount."\n";
			}
			foreach(sort keys %panMembers) {
				print PP " ".$_."\t".$panMembers{$_}."\n";
			}
			print PP "\n";
		}		
	}
	close(PP);
	print "running protoemes:".keys(%runningProteomesScoreHash)."\n";
	for $key (keys %runningProteomesScoreHash) {
		print $Xin." end of clustering ".$key."\n";
	}
	#if($Xin == 95) {
	#	open(RUN95, ">", "../data/runningProteomesScoreHash95.txt") or die "Can't open ../data/runningProteomesScoreHash95.txt\n";	 
	#	for $key (keys %runningProteomesScoreHash) {
	#		print RUN95 $key."\t".$runningProteomesScoreHash{$key}."\n";
	#	}	
	#	close(RUN95);
	#}	
	return %runningProteomesScoreHash;
}

sub findTopProtein {
	my ($myProteinsHashRef) = @_;
	my %myProteinsHash = %$myProteinsHashRef;
	my %scoreHash;
	foreach(keys %myProteinsHash) {
		my $protein = $myProteinsHash{$_};
		$scoreHash{$protein->getScore()} = $protein->getAC();
	}
	foreach my $key (reverse (sort keys(%scoreHash))) {
		return $myProteinsHash{$scoreHash{$key}};
	}
}

$date = `date`;
print "End at ".$date;
$end = time - $start;
# Print runtime #
print "\nRuning time(seconds): ".$end."\n"; 
printf("\n\nTotal running time: %02d:%02d:%02d\n\n", int($end / 3600), int(($end % 3600) / 60), 
int($end % 60));

