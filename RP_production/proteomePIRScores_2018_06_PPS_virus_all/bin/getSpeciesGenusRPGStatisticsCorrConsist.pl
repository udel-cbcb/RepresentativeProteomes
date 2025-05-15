#!/usr/bin/perl
$argc = @ARGV;
if($argc != 2) {
        print "Usage: perl getSpeciesGenusRPGStatisticsCorrConsist.pl resultDir number\n";
        exit;
}
$resultDir = $ARGV[0];
$number = $ARGV[1];

open(SEQ, "<", "../data/totalSeqNumCorrConsist.txt") or die "Can't open ../data/totalSeqNumCorrConsist.txt\n";
while($line = <SEQ>) {
	chomp($line);
	$totalSeqNum = $line;
}
close(SEQ);

open(UNIREF, "<", "../data/totalUniRef50CorrConsist.txt") or die "Can't open ../data/totalUniRef50CorrConsist.txt\n";
while($line = <UNIREF>) {
	chomp($line);
	$totalUniRef50 = $line;
}
close(UNIREF);

open(NCBI, "../data/new_nih_taxID_scientific_name_table") or die "Can't open ../data/new_nih_taxID_scientific_name_table\n";
while($line=<NCBI>) {
	chomp($line);
	if($line =~ /unclassified/) {
		@rec = split(/ /, $line);
		$taxId = $rec[0];
		$unclassified{$taxId} = $rec[1];
		for($i = 2; $i < @rec; $i++) {
			$unclassified{$taxId} .= " ".$rec[$i];
		}
	}
	$line =~ s/ /ABCDEFG/;
	($taxId, $name) =(split(/ABCDEFG/, $line))[0,1];
	$taxIdToName{$taxId} = $name;	
}
close(NCBI);

#print "Reading taxId_parentTaxId table ...done\n";
#open(SG, "<", "../data/upIdAndTaxIdToSpeciesAndGenus.txt") or die "Can't open ../data/upIdAndTaxIdToSpeciesAndGenus.txt\n";
open(SG, "<", "../data/upIdAndTaxIdToTaxonomicRanks.txt") or die "Can't open ../data/upIdAndTaxIdToTaxonomicRanks.txt\n";
while($line=<SG>) {
        chomp($line);
        my @rec = split(/\:/, $line);
	
        $upIdAndTaxIdToSpecies{$rec[0]} = $rec[3];
        $upIdAndTaxIdToGenus{$rec[0]} = $rec[4];
        $upIdAndTaxIdToFamily{$rec[0]} = $rec[5];
        $upIdAndTaxIdToOrder{$rec[0]} = $rec[6];
        $upIdAndTaxIdToClass{$rec[0]} = $rec[7];
        $upIdAndTaxIdToPhylum{$rec[0]} = $rec[8];
}
close(SG);


#print "Reading rpg data file ...\n";
$rpgFile = "$resultDir/$number/rpg-$number.txt";
$rpgGroupCount = 0;
$upIdAndTaxIdCount = 0;
open(RPG, "<", $rpgFile) or die "Can't open $rpgFile\n";
while($line =<RPG>) {
	if($line =~ /^\>/) {
		($rp, $taxId) = (split(/\t/, $line))[0, 1] ;
		$rp =~ s/\>//;
		$species = $upIdAndTaxIdToSpecies{$rp."-".$taxId};
		$genus = $upIdAndTaxIdToGenus{$rp."-".$taxId};
		$family = $upIdAndTaxIdToFamily{$rp."-".$taxId};
		$order = $upIdAndTaxIdToOrder{$rp."-".$taxId};
		$class = $upIdAndTaxIdToClass{$rp."-".$taxId};
		$phylum = $upIdAndTaxIdToPhylum{$rp."-".$taxId};
		if($species eq "") {
			#$species = $taxId;
			$species = "na";
		}
		if($genus eq "") {
			#$genus = $taxId;
			$genus = "na";
		}
		if($family eq "") {
			#$family = $taxId;
			$family = "na";
		}	
		if($order eq "") {
			#$order = $taxId;
			$order = "na";
		}	
		if($class eq "") {
			#$class = $taxId;
			$class = "na";
		}	
		if($phylum eq "") {
			#$phylum = $taxId;
			$phylum = "na";
		}
		if($species ne "na" && !$unclassified{$species}) {	
			$speciesRPG{$species}{$rp."-".$taxId} = 1;		
		}
		if($genus ne "na" && !$unclassified{$genus}) {
			$genusRPG{$rp."-".$taxId}{$genus} = 1;		
		}
		if($family ne "na" && !$unclassified{$family}) {
			$familyRPG{$rp."-".$taxId}{$family} = 1;		
		}
		if($order ne "na" && !$unclassified{$order}) {
			$orderRPG{$rp."-".$taxId}{$order} = 1;		
		}
		if($class ne "na" && !$unclassified{$class}) {
			$classRPG{$rp."-".$taxId}{$class} = 1;		
		}
		if($phylum ne "na" && !$unclassified{$phylum}) {
			$phylumRPG{$rp."-".$taxId}{$phylum} = 1;		
		}
		#print $rp."-".$taxId."\t".$class."\n";		
		$rpgGroupCount++;
		$upIdAndTaxIdCount++;
		$count = 1;
		$rpUPIdAndTaxId = $rp."-".$taxId;
	}
	else {
		if($line !~ /^$/) {
			$line =~ s/^\s+//;
			($member, $taxId) = (split(/\t/, $line))[0, 1];
			$species = $upIdAndTaxIdToSpecies{$member."-".$taxId};
			$genus = $upIdAndTaxIdToGenus{$member."-".$taxId};
			$family = $upIdAndTaxIdToFamily{$member."-".$taxId};
			$order = $upIdAndTaxIdToOrder{$member."-".$taxId};
			$class = $upIdAndTaxIdToClass{$member."-".$taxId};
			$phylum = $upIdAndTaxIdToPhylum{$member."-".$taxId};
			if($species eq "") {
				#$species = $taxId;
				$species = "na";
			}
			if($genus eq "") {
				#$genus = $taxId;
				$genus = "na";
			}
			if($family eq "") {
				#$family = $taxId;
				$family = "na";
			}
			if($order eq "") {
				#$order = $taxId;
				$order = "na";
			}
			if($class eq "") {
				#$class = $taxId;
				$class = "na";
			}
			if($phylum eq "") {
				#$phylum = $taxId;
				$phylum = "na"; 
			}
			if($species ne "na" && !$unclassified{$species}) {
				$speciesRPG{$species}{$rpUPIdAndTaxId} = 1;		
			}
			if($genus ne "na" && !$unclassified{$genus}) {
				$genusRPG{$rpUPIdAndTaxId}{$genus} = 1;		
			}
			if($family ne "na" && !$unclassified{$family}) {
				$familyRPG{$rpUPIdAndTaxId}{$family} = 1;		
			}
			if($order ne "na" && !$unclassified{$order}) {
				$orderRPG{$rpUPIdAndTaxId}{$order} = 1;		
			}
			if($class ne "na" && !$unclassified{$class}) {
				$classRPG{$rpUPIdAndTaxId}{$class} = 1;		
			}
			if($phylum ne "na" && !$unclassified{$phylum}) {
				$phylumRPG{$rpUPIdAndTaxId}{$phylum} = 1;		
			}
			#print $rp."-".$taxId."\t".$genus."\n";		
			$count++;
			$upIdAndTaxIdCount++;
		}
	}
	$rpgGroupMemberCount{$rpUPIdAndTaxId} = $count;
}
close(RPG);
#print "Reading rpg data file ...done\n";

$ppFile = "$resultDir/$number/pp-$number.txt";
$ppCount = 0;
open(PP, "<", $ppFile) or die;
while($line = <PP>) {
	chomp($line);
	if($line =~ /#/) {
		@rec = split(/\t/, $line);
		$ppCount += $rec[2];
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
			if($rpTaxId eq $rec[1]) {
				$rpSeq{$rec[0]} = 1;
				$rpUniRef50{$rec[3]} = 1;
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
open(SpeciesRPG, ">$resultDir/$number/speciesRPG-$number.txt") or die "Can't open $resultDir/$number/speciesRPG-$number.txt\n";
print SpeciesRPG "Species\t#Group\tRPGList\n";
foreach my $myspecies (sort keys %speciesRPG) {
	my $rpgCount = keys %{ $speciesRPG{$myspecies}}; 
	my $rpgs = "";	
	foreach my $rpg (sort keys %{ $speciesRPG{$myspecies}}) {
		($up, $tax) = (split(/-/, $rpg))[0,1];
		$rpgs .=$rpg."(".$rpgGroupMemberCount{$rpg}.") {".$taxIdToName{$tax}."}; ";	
	 }
	$rpgs =~ s/; $//;
	$speciesCount++;
	if($rpgCount >= 2) {
		$speciesMRPGCount++;
	}
	#print SpeciesRPG $myspecies."\t".$rpgCount."\t".$rpgs."\n";
	print SpeciesRPG $myspecies." {".$taxIdToName{$myspecies}."}\t".$rpgCount."\t".$rpgs."\n";
}
close(SpeciesRPG);

open(GenusRPG, ">$resultDir/$number/rpgGenus-$number.txt") or die "Can't open $resultDir/$number/rpgGenus-$number.txt\n";
print GenusRPG "RPG\t#Genus\tGenusList\n";
$rpgGenusCount = 0;
$rpgMGenusCount = 0;
foreach my $rpg (sort keys %genusRPG) {
	my $genusCount = keys %{ $genusRPG{$rpg}}; 
	my $genuss = "";	
	foreach my $genus ( sort keys %{ $genusRPG{$rpg}}) {
		$genuss .=$genus." {".$taxIdToName{$genus}."}; ";	
	 }
	$genuss =~ s/; $//;
	$rpgGenusCount++;
	if($genusCount >= 2) {
		$rpgMGenusCount++;
	}
	($up, $tax) = (split(/-/, $rpg))[0,1];
	
	print GenusRPG $rpg."(".$rpgGroupMemberCount{$rpg}.") {".$taxIdToName{$tax}."}\t".$genusCount."\t".$genuss."\n";
}
close(GenusRPG);
#print "Printing out results...done\n";

open(FamilyRPG, ">$resultDir/$number/rpgFamily-$number.txt") or die "Can't open $resultDir/$number/rpgFamily-$number.txt\n";
print FamilyRPG "RPG\t#Family\tFamilyList\n";
$rpgFamilyCount = 0;
$rpgMFamilyCount = 0;
foreach my $rpg (sort keys %familyRPG) {
	my $familyCount = keys %{ $familyRPG{$rpg}}; 
	my $familys = "";	
	foreach my $family ( sort keys %{ $familyRPG{$rpg}}) {
		$familys .=$family." {".$taxIdToName{$family}."}; ";	
	 }
	$familys =~ s/; $//;
	$rpgFamilyCount++;
	if($familyCount >= 2) {
		$rpgMFamilyCount++;
	}
	($up, $tax) = (split(/-/, $rpg))[0,1];
	print FamilyRPG $rpg."(".$rpgGroupMemberCount{$rpg}.") {".$taxIdToName{$tax}."}\t".$familyCount."\t".$familys."\n";
}
close(FamilyRPG);

open(OrderRPG, ">$resultDir/$number/rpgOrder-$number.txt") or die "Can't open $resultDir/$number/rpgOrder-$number.txt\n";
print OrderRPG "RPG\t#Order\tOrderList\n";
$rpgOrderCount = 0;
$rpgMOrderCount = 0;
foreach my $rpg (sort keys %orderRPG) {
	my $orderCount = keys %{ $orderRPG{$rpg}}; 
	my $orders = "";	
	foreach my $order ( sort keys %{ $orderRPG{$rpg}}) {
		$orders .=$order." {".$taxIdToName{$order}."}; ";	
	 }
	$orders =~ s/; $//;
	$rpgOrderCount++;
	if($orderCount >= 2) {
		$rpgMOrderCount++;
	}
	($up, $tax) = (split(/-/, $rpg))[0,1];
	print OrderRPG $rpg."(".$rpgGroupMemberCount{$rpg}.") {".$taxIdToName{$tax}."}\t".$orderCount."\t".$orders."\n";
}
close(OrderRPG);

open(ClassRPG, ">$resultDir/$number/rpgClass-$number.txt") or die "Can't open $resultDir/$number/rpgClass-$number.txt\n";
print ClassRPG "RPG\t#Class\tClassList\n";
$rpgClassCount = 0;
$rpgMClassCount = 0;
foreach my $rpg (sort keys %classRPG) {
	my $classCount = keys %{ $classRPG{$rpg}}; 
	my $classes = "";	
	foreach my $class ( sort keys %{ $classRPG{$rpg}}) {
		$classes .=$class." {".$taxIdToName{$class}."}; ";	
	 }
	$classes =~ s/; $//;
	$rpgClassCount++;
	if($classCount >= 2) {
		$rpgMClassCount++;
	}
	($up, $tax) = (split(/-/, $rpg))[0,1];
	print ClassRPG $rpg."(".$rpgGroupMemberCount{$rpg}.") {".$taxIdToName{$tax}."}\t".$classCount."\t".$classes."\n";
}
close(ClassRPG);

open(PhylumRPG, ">$resultDir/$number/rpgPhylum-$number.txt") or die "Can't open $resultDir/$number/rpgPhylum-$number.txt\n";
print PhylumRPG "RPG\t#Phylum\tPhylumList\n";
$rpgPhylumCount = 0;
$rpgMPhylumCount = 0;
foreach my $rpg (sort keys %phylumRPG) {
	my $phylumCount = keys %{ $phylumRPG{$rpg}}; 
	my $phylums = "";	
	foreach my $phylum ( sort keys %{ $phylumRPG{$rpg}}) {
		$phylums .=$phylum." {".$taxIdToName{$phylum}."}; ";	
	 }
	$phylums =~ s/; $//;
	$rpgPhylumCount++;
	if($phylumCount >= 2) {
		$rpgMPhylumCount++;
	}
	($up, $tax) = (split(/-/, $rpg))[0,1];
	print PhylumRPG $rpg."(".$rpgGroupMemberCount{$rpg}.") {".$taxIdToName{$tax}."}\t".$phylumCount."\t".$phylums."\n";
}
close(PhylumRPG);

$reduceInProteomes = sprintf("%.4f", (100*($upIdAndTaxIdCount - $rpgGroupCount))/$upIdAndTaxIdCount);
#print $number."\t".$ppCount."\t".$totalSeqNum."\n";
#$reduceInSequences = sprintf("%.4f", (100*($totalSeqNum - $ppCount))/$totalSeqNum);
$percentSpeciesInMGroup = sprintf("%.4f", (100*$speciesMRPGCount)/$speciesCount);
$percentGenusInMGroup = sprintf("%.4f", (100*$rpgMGenusCount)/$rpgGenusCount);
$percentFamilyInMGroup = sprintf("%.4f", (100*$rpgMFamilyCount)/$rpgFamilyCount);
$percentOrderInMGroup = sprintf("%.4f", (100*$rpgMOrderCount)/$rpgOrderCount);
if($rpgClassCount > 0) {
	$percentClassInMGroup = sprintf("%.4f", (100*$rpgMClassCount)/$rpgClassCount);
}
else {
	$percentClassInMGroup = sprintf("%.4f", (100*$rpgMClassCount)/1);
}
if($rpgPhylumCount > 0) {
	$percentPhylumInMGroup = sprintf("%.4f", (100*$rpgMPhylumCount)/$rpgPhylumCount);
}
else {
	$percentPhylumInMGroup = sprintf("%.4f", (100*$rpgMPhylumCount)/1);
}
$rpSeqCoverage = sprintf("%.4f", (100*$rpSeqCount)/$totalSeqNum);
$rpUniRef50Coverage = sprintf("%.4f", (100*$rpUniRef50Count)/$totalUniRef50);


chomp($elapse);
print "	<tr>\n";
print "		<td><a href=\"$number/\">".$number."</a></td><td><a href=\"$number/rpg-$number.txt\">".$rpgGroupCount."</a></td><td>".$reduceInProteomes."</td><td><a href=\"$number/speciesRPG-$number.txt\">".$percentSpeciesInMGroup."</a></td>";
print "<td><a href=\"$number/rpgGenus-$number.txt\">".$percentGenusInMGroup."</a></td>";
print "<td><a href=\"$number/rpgFamily-$number.txt\">".$percentFamilyInMGroup."</a></td>";
print "<td><a href=\"$number/rpgOrder-$number.txt\">".$percentOrderInMGroup."</a></td>";
print "<td><a href=\"$number/rpgClass-$number.txt\">".$percentClassInMGroup."</a></td>";
print "<td><a href=\"$number/rpgPhylum-$number.txt\">".$percentPhylumInMGroup."</a></td>";
print "<td>".$rpSeqCoverage."</td><td>".$rpUniRef50Coverage."</td>\n";
print "	</tr>\n";

