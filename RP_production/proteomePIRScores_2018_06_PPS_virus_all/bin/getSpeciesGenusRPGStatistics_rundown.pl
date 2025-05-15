#!/usr/bin/perl
$argc = @ARGV;
if($argc != 2) {
        print "Usage: perl getSpeciesGenusRPGStatistics_rundown.pl resultDir number\n";
        exit;
}
$resultDir = $ARGV[0];
$number = $ARGV[1];

open(SEQ, "<", "../data/totalSeqNum_rundown.txt") or die "Can't open ../data/totalSeqNum_rundown.txt";
while($line = <SEQ>) {
	chomp($line);
	$totalSeqNum = $line;
}
close(SEQ);

open(UNIREF, "<", "../data/totalUniRef50_rundown.txt") or die "Can't open ../data/totalUniRef50_rundown.txt";
while($line = <UNIREF>) {
	chomp($line);
	$totalUniRef50 = $line;
}
close(UNIREF);

open(RUNDOWN, "../results_corr_consist_rundown/$number/rundown.txt") or die "Can't open ../results_corr_consist_rundown/$number/rundown.txt\n";
while($line=<RUNDOWN>) {
        chomp($line);
        ($up, $tax) = (split(/\t/, $line))[0, 1];
        $rundown{$up."-".$tax} = 1;
        $rundowntab{$line} = 1;
}
close(RUNDOWN);

#print "Reading taxId_parentTaxId table ...\n";
$taxHierarchFile = "../data/new_nih_taxID_parenttaxID_table";
open(TAXParent, "<", $taxHierarchFile) or die "Can't open ../data/new_nih_taxID_parenttaxID_table\n";
while($line = <TAXParent>) {
	chomp($line);
	@rec = split(/\s+/, $line);
	$taxId = $rec[0];
	$parentTaxId = $rec[1];
 	$type = $rec[2];
	#print "|".$taxId."|".$parentTaxId."|".$type."|\n";
	$parentHash{$taxId} = $parentTaxId;
	$typeHash{$taxId} = $type;
}
close(TAXParent);
#print "Reading taxId_parentTaxId table ...done\n";
open(SG, "<", "../data/taxIdToSpeciesAndGenus.txt") or die "Can't open ../data/taxIdToSpeciesAndGenus.txt\n";
while($line=<SG>) {
        chomp($line);
        my @rec = split(/\:/, $line);
        $taxIdToSpecies{$rec[0]} = $rec[3];
        $taxIdToGenus{$rec[0]} = $rec[4];
        $taxIdToClass{$rec[0]} = $rec[5];
        $taxIdToPhylum{$rec[0]} = $rec[6];
}
close(SG);


#print "Reading rpg data file ...\n";
$rpgFile = "$resultDir/$number/rpg-$number.txt";
#print $rpgFile."\n";
$rpgGroupCount = 0;
$taxIdCount = 0;
open(RPG, "<", $rpgFile) or die "Can't open $rpgFile\n";;
while($line =<RPG>) {
	#print $line;
	#chomp($line);
	if($line =~ /^\>/) {
		#print $line;
		$rp = (split(/\t/, $line))[0] ;
		$rp =~ s/\>//;
		#print "|".$rp."|\n";
		#$species = findSpecies($rp);
		$species = $taxIdToSpecies{$rp};
		#$genus = findGenus($rp);
		$genus = $taxIdToGenus{$rp};
		$speciesRPG{$species}{$rp} = 1;		
		$genusRPG{$rp}{$genus} = 1;		
		#print $rp."\t".$species."\t".$rp."\n";
		$rpgGroupCount++;
		$taxIdCount++;
		$count = 1;
	}
	else {
		if($line !~ /^$/) {
			$line =~ s/^\s+//;
			$member = (split(/\t/, $line))[0];
			#$species = findSpecies($member);
			$species = $taxIdToSpecies{$member};
			#$genus = findGenus($member);
			$genus = $taxIdToGenus{$member};
			$speciesRPG{$species}{$rp} = 1;		
			$genusRPG{$rp}{$genus} = 1;		
			#print $member."\t".$species."\t".$rp."\n";
			$count++;
			$taxIdCount++;
		}
	}
	$rpgGroupMemberCount{$rp} = $count;
	#print "rpg: ".$count++."\n";
}
close(RPG);
#print "Reading rpg data file ...done\n";

$ppFile = "$resultDir/$number/pp-$number.txt";
#print $ppFile."\n";
$ppCount = 0;
open(PP, "<", $ppFile) or die;
while($line = <PP>) {
	chomp($line);
	if($line =~ /#/) {
		@rec = split(/\t/, $line);
		$ppCount += $rec[1];
		#print $line." ".$ppCount."\";
	}
}
close(PP);

open(PP, "<", $ppFile) or print $!;
while($line=<PP>) {
	chomp($line);
	if($line =~ /\>Pan-Proteome/) {
		$rpTaxId = (split(/\t/, $line))[0];
		$rpTaxId =~ s/\>Pan-Proteome_//;	
	}
	else {
		$line =~ s/^\s+//;
		if($line !~ /\#/) {
			@rec = split(/\t/, $line);
			if($rec[1] eq $rpTaxId) {
				$rpSeq{$rec[0]} = 1;
				$rpUniRef50{$rec[2]} = 1;
			}
		}
	}
}
close(PP);
$rpSeqCount = keys(%rpSeq);
$rpUniRef50Count = keys(%rpUniRef50);

$speciesCount = 0;
$speciesMRPGCount = 0;
#print "Printing out results...\n";
open(SpeciesRPG, ">$resultDir/$number/speciesRPG-$number.txt") or die;
print SpeciesRPG "Species\t#Group\tRPGList\n";
foreach my $myspecies (sort keys %speciesRPG) {
	my $rpgCount = keys %{ $speciesRPG{$myspecies}}; 
	my $rpgs = "";	
	foreach my $rpg (sort keys %{ $speciesRPG{$myspecies}}) {
		$rpgs .=$rpg."(".$rpgGroupMemberCount{$rpg}."); ";	
	 }
	$rpgs =~ s/; $//;
	$speciesCount++;
	if($rpgCount >= 2) {
		$speciesMRPGCount++;
	}
	print SpeciesRPG $myspecies."\t".$rpgCount."\t".$rpgs."\n";
}
close(SpeciesRPG);

open(GenusRPG, ">$resultDir/$number/rpgGenus-$number.txt") or die;
print GenusRPG "RPG\t#Genus\tGenusList\n";
$rpgGenusCount = 0;
$rpgMGenusCount = 0;
foreach my $rpg (sort keys %genusRPG) {
	my $genusCount = keys %{ $genusRPG{$rpg}}; 
	my $genuss = "";	
	foreach my $genus ( sort keys %{ $genusRPG{$rpg}}) {
		$genuss .=$genus."; ";	
	 }
	$genuss =~ s/; $//;
	$rpgGenusCount++;
	if($genusCount >= 2) {
		$rpgMGenusCount++;
	}
	print GenusRPG $rpg."(".$rpgGroupMemberCount{$rpg}.")\t".$genusCount."\t".$genuss."\n";
}
close(GenusRPG);
#print "Printing out results...done\n";

#print "X: ".$number."\n";
#print "RPG: ".$rpgGroupCount."\n";
#print "Organism: ".$taxIdCount."\n";
#print "Species: ".$speciesCount."\n";
#print "SpeciesM: ".$speciesMRPGCount."\n";
#print "RPGGenus: ".$rpgGenusCount."\n";
#print "RPGGenusMGroup: ".$rpgMGenusCount."\n";
$reduceInProteomes = sprintf("%.4f", (100*($taxIdCount - $rpgGroupCount))/$taxIdCount);
#print $number."\t".$ppCount."\t".$totalSeqNum."\n";
$reduceInSequences = sprintf("%.4f", (100*($totalSeqNum - $ppCount))/$totalSeqNum);
$percentSpeciesInMGroup = sprintf("%.4f", (100*$speciesMRPGCount)/$speciesCount);
$percentGenusInMGroup = sprintf("%.4f", (100*$rpgMGenusCount)/$rpgGenusCount);
$rpSeqCoverage = sprintf("%.4f", (100*$rpSeqCount)/$totalSeqNum);
$rpUniRef50Coverage = sprintf("%.4f", (100*$rpUniRef50Count)/$totalUniRef50);


$cmd = "grep \"Total running\" ../logs/log.$number | sed 's/Total running time: //'";
#print $cmd."\n";
$elapse = `$cmd`;
chomp($elapse);
#print $number."\t".$rpgGroupCount."\t".$reduceInProteomes."\t".$reduceInSequences."\t".$percentSpeciesInMGroup."\t".$percentGenusInMGroup."\n";
print "	<tr>\n";
#print "		<td>".$number."</td><td>".$rpgGroupCount."</td><td>".$reduce."</td><td>".$percentSpeciesInMGroup."</td><td>".$percentGenusInMGroup."</td><td>".$elapse."</td>\n";
#print "		<td>".$number."</td><td>".$rpgGroupCount."</td><td>".$reduce."</td><td>".$percentSpeciesInMGroup."</td><td>".$percentGenusInMGroup."</td>\n";
print "		<td><a href=\"$number/\">".$number."</a></td><td><a href=\"$number/rpg-$number.txt\">".$rpgGroupCount."</a></td><td>".$reduceInProteomes."</td><td><a href=\"$number/pp-$number.txt\">".$reduceInSequences."</a><td><a href=\"$number/speciesRPG-$number.txt\">".$percentSpeciesInMGroup."</a></td><td><a href=\"$number/rpgGenus-$number.txt\">".$percentGenusInMGroup."</a></td>";
print "<td>".$rpSeqCoverage."</td><td>".$rpUniRef50Coverage."</td>\n";
print "	</tr>\n";

sub findSpecies {
	my ($taxId) = @_;
	my $start = $taxId;
	$type = $typeHash{$taxId};
	#print "finding |".$taxId."|\n";
	if($type eq "species" || $type eq "class") {
		#print "1: ".$start."\t".$taxId."\t".$typeHash{$taxId}."\n";
		#print $start."\t".$taxId."\t".$typeHash{$taxId}."\n";
		return $taxId;
	}
	else {
		$taxIds = "";
		while($typeHash{$taxId} ne "species") {
			if($typeHash{$taxId} eq "class") {
			#print "2: ".$start."\t".$taxId."\t".$typeHash{$taxId}."\n";
			#print $start."\t".$taxId."\t".$typeHash{$taxId}."\n";
				return $taxId;
			}
			else {
				$taxIds .= $taxId.", ";	
				$taxId = $parentHash{$taxId};	
				$taxIds .= $taxId.", ";	
			}
		}
		#print "3: ".$start."\t".$taxIds."\t".$typeHash{$taxId}."\n";
		#print $start."\t".$taxIds."\t".$typeHash{$taxId}."\n";
		#print "4: ".$start."\t".$taxIds."\t".$typeHash{$taxId}."\n";
		return $taxId;	
	}
}

sub findGenus {
	my ($taxId) = @_;
	$type = $typeHash{$taxId};
	#print "finding".$taxId."\n";
	if($type eq "genus" || $type eq "class" || $type eq "phylum") {
		return $taxId;
	}
	else {
		my $start = $taxId;
		while($typeHash{$taxId} ne "genus") {
			if($typeHash{$taxId} eq "phylum" || $typeHash{$taxId} eq "superkingdom") {
                                return $taxId;
                        }
			else {
				$taxId = $parentHash{$taxId};	
			}
		}
		#print $start."<-->".$taxId."<-->".$typeHash{$taxId}."\n";
		return $taxId;
	}
}	
