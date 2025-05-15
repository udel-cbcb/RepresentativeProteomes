#!/usr/bin/perl
$argc = @ARGV;
if($argc != 2) {
        print "Usage: perl getSpeciesGenusRPGStatisticsCorrConsist.pl resultDir number\n";
        exit;
}
$resultDir = $ARGV[0];
$number = $ARGV[1];

open(RUNDOWN, "../data/rundown.txt") or die "Can't open ../data/rundown.txt\n";
while($line=<RUNDOWN>) {
        chomp($line);
        ($up, $tax) = (split(/\t/, $line))[0, 1];
        $rundown{$up."-".$tax} = 1;
        $rundowntab{$line} = 1;
}
close(RUNDOWN);

open(SEQ, "<", "../data/totalSeqNumCorrConsist_rundown.txt") or die "Can't open ../data/totalSeqNumCorrConsist_rundown.txt\n";
while($line = <SEQ>) {
	chomp($line);
	$totalSeqNum = $line;
}
close(SEQ);

open(UNIREF, "<", "../data/totalUniRef50CorrConsist_rundown.txt") or die "Can't open ../data/totalUniRef50CorrConsist_rundown.txt\n";
while($line = <UNIREF>) {
	chomp($line);
	$totalUniRef50 = $line;
}
close(UNIREF);

#print "Reading taxId_parentTaxId table ...done\n";
open(SG, "<", "../data/upIdAndTaxIdToSpeciesAndGenus.txt") or die "Can't open ../data/upIdAndTaxIdToSpeciesAndGenus.txt\n";
while($line=<SG>) {
        chomp($line);
        my @rec = split(/\:/, $line);
	if(!$rundown{$rec[0]}) {	
        	$upIdAndTaxIdToSpecies{$rec[0]} = $rec[3];
        	$upIdAndTaxIdToGenus{$rec[0]} = $rec[4];
        	$upIdAndTaxIdToClass{$rec[0]} = $rec[5];
        	$upIdAndTaxIdToPhylum{$rec[0]} = $rec[6];
	}
}
close(SG);


#print "Reading rpg data file ...\n";
$rpgFile = "$resultDir/$number/rpg-$number.txt";
$rpgGroupCount = 0;
$upIdAndTaxIdCount = 0;
open(RPG, "<", $rpgFile) or die;
while($line =<RPG>) {
	if($line =~ /^\>/) {
		($rp, $taxId) = (split(/\t/, $line))[0, 1] ;
		$rp =~ s/\>//;
		if(!$rundown{$rp."-".$taxId}) {		
			$species = $upIdAndTaxIdToSpecies{$rp."-".$taxId};
			$genus = $upIdAndTaxIdToGenus{$rp."-".$taxId};
			if($species eq "") {
                        	$species = $taxId;
                	}
                	if($genus eq "") {
                        	$genus = $taxId;
                	}
			#$speciesRPG{$species}{$rp."-".$taxId} = 1;		
			$speciesRPG{$species}{$taxId} = 1;		
			#$genusRPG{$rp."-".$taxId}{$genus} = 1;		
			$genusRPG{$taxId}{$genus} = 1;		
			$rpgGroupCount++;
			$upIdAndTaxIdCount++;
			$count = 1;
			#$rpUPIdAndTaxId = $rp."-".$taxId;
			$rpUPIdAndTaxId = $taxId;
		}
		else {
			$rpUPIdAndTaxId = "";	
			$count = 0;
		}
	}
	else {
		if($line !~ /^$/) {
			$line =~ s/^\s+//;
			($member, $taxId) = (split(/\t/, $line))[0, 1];
			if(!$rundown{$member."-".$taxId}) {
				$species = $upIdAndTaxIdToSpecies{$member."-".$taxId};
				$genus = $upIdAndTaxIdToGenus{$member."-".$taxId};
				if($species eq "") {
                        		$species = $taxId;
                		}
                		if($genus eq "") {
                        		$genus = $taxId;
                		}
				$speciesRPG{$species}{$rpUPIdAndTaxId} = 1;		
				$genusRPG{$rpUPIdAndTaxId}{$genus} = 1;		
				$count++;
				$upIdAndTaxIdCount++;
			}
		}
	}
	if($rpUPIdAndTaxId && $count > 0) {
		$rpgGroupMemberCount{$rpUPIdAndTaxId} = $count;
	}
}
close(RPG);
#print "Reading rpg data file ...done\n";

$ppFile = "$resultDir"."_rundown/$number/pp-$number.txt";
$ppCount = 0;
open(PP, "<", $ppFile) or die;
while($line = <PP>) {
	chomp($line);
	if($line =~ /#/) {
		@rec = split(/\t/, $line);
		$ppCount += $rec[1];
	}
}
close(PP);

open(PP, "<", $ppFile) or print $!;
while($line=<PP>) {
	chomp($line);
	if($line =~ /\>/) {
		$rpTaxId = (split(/\t/, $line))[0];
		$rpTaxId =~ s/\>//;	
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
open(SpeciesRPG, ">$resultDir"."_rundown/$number/speciesRPG-$number.txt") or die "Can't open $resultDir"."_rundown/$number/speciesRPG-$number.txt\n";
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

open(GenusRPG, ">$resultDir"."_rundown/$number/rpgGenus-$number.txt") or die "Can't open $resultDir"."_rundown/$number/rpgGenus-$number.txt\n";
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

$reduceInProteomes = sprintf("%.4f", (100*($upIdAndTaxIdCount - $rpgGroupCount))/$upIdAndTaxIdCount);
#print $number."\t".$ppCount."\t".$totalSeqNum."\n";
$reduceInSequences = sprintf("%.4f", (100*($totalSeqNum - $ppCount))/$totalSeqNum);
$percentSpeciesInMGroup = sprintf("%.4f", (100*$speciesMRPGCount)/$speciesCount);
$percentGenusInMGroup = sprintf("%.4f", (100*$rpgMGenusCount)/$rpgGenusCount);
$rpSeqCoverage = sprintf("%.4f", (100*$rpSeqCount)/$totalSeqNum);
$rpUniRef50Coverage = sprintf("%.4f", (100*$rpUniRef50Count)/$totalUniRef50);


chomp($elapse);
print "	<tr>\n";
#print "		<td><a href=\"$number/\">".$number."</a></td><td><a href=\"$number/rpg-$number.txt\">".$rpgGroupCount."</a></td><td>".$reduceInProteomes."</td><td><a href=\"$number/pp-$number.txt\">".$reduceInSequences."</a><td><a href=\"$number/speciesRPG-$number.txt\">".$percentSpeciesInMGroup."</a></td><td><a href=\"$number/rpgGenus-$number.txt\">".$percentGenusInMGroup."</a></td>";
print "		<td><a href=\"$number/\">".$number."</a></td><td><a href=\"$number/rpg-$number.txt\">".$rpgGroupCount."</a></td><td>".$reduceInProteomes."</td><td><a href=\"$number/speciesRPG-$number.txt\">".$percentSpeciesInMGroup."</a></td><td><a href=\"$number/rpgGenus-$number.txt\">".$percentGenusInMGroup."</a></td>";
print "<td>".$rpSeqCoverage."</td><td>".$rpUniRef50Coverage."</td>\n";
print "	</tr>\n";

