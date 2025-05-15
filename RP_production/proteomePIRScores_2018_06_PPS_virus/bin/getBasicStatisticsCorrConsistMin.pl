#!/usr/bin/perl
$argc = @ARGV;
if($argc != 2) {
        print "Usage: perl getBasicStatisticsCorrConsist.pl unirefxx.dat uniprotVersionNumber\n";
        exit;
}
$unirefdata = $ARGV[0];
$uniprotVersion = $ARGV[1];

my $pirScoreHash=();
open(PSCORE, "<", "../data/score/proteomeScores.txt") or die "Can't open ../data/score/proteomeScores.txt\n";
while($line = <PSCORE>) {
        chomp($line);
	if($line !~ /^UPId/) {
        	@rec = split(/\t/, $line);
        	$upIdAndTaxId = $rec[0]."-".$rec[1];
		$pirScoreHash{$upIdAndTaxId} = 1;
	}
}
close(PSCORE);

open(RPG, "../results_corr_consist/95/rpg-95.txt") or die "Can't open ../results_corr_consist/95/rpg-95.txt\n";
while($line=<RPG>) {
	if($line !~ /^$/) {
		($upId, $taxId) = (split(/\t/, $line))[0, 1];
		$upId =~ s/>//;
		$upId =~ s/ //;
		$usedProteomes{$upId."-".$taxId} = 1;
	}
}
close(RPG);

#open(SG, "<", "../data/upIdAndTaxIdToSpeciesAndGenus.txt") or die "Can't open ../data/upIdAndTaxIdToSpeciesAndGenus.txt\n";
open(SG, "<", "../data/upIdAndTaxIdToTaxonomicRanks.txt") or die "Can't open ../data/upIdAndTaxIdToTaxonomicRanks.txt\n";
while($line=<SG>) {
        chomp($line);
        my @rec = split(/\:/, $line);
        #$upIdAndTaxIdToSpecies{$rec[0]} = $rec[3];
        #$upIdAndTaxIdToGenus{$rec[0]} = $rec[4];
        #$upIdAndTaxIdToClass{$rec[0]} = $rec[5];
        #$upIdAndTaxIdToPhylum{$rec[0]} = $rec[6];
       	$upIdAndTaxIdToSpecies{$rec[0]} = $rec[3];
        $upIdAndTaxIdToGenus{$rec[0]} = $rec[4];
        $upIdAndTaxIdToFamily{$rec[0]} = $rec[5];
        $upIdAndTaxIdToOrder{$rec[0]} = $rec[6];
        $upIdAndTaxIdToClass{$rec[0]} = $rec[7];
        $upIdAndTaxIdToPhylum{$rec[0]} = $rec[8];
}
close(SG);

open(UNIREF, "<", $unirefdata);
while($line =<UNIREF>) {
	chomp($line);
	@rec = split(/\t/, $line);
	$entryAc = $rec[0];
	$upId = $rec[1];
	$taxId = $rec[2];
	$unirefId = $rec[3];
	if($usedProteomes{$upId."-".$taxId}) {
		$entryHash{$entryAc} = 1;
		$upAndTaxHash{$upId."-".$taxId} = 1;
		$unirefHash{$unirefId} = 1;
		$species = $upIdAndTaxIdToSpecies{$upId."-".$taxId};
		$genus = $upIdAndTaxIdToGenus{$upId."-".$taxId};
		$family = $upIdAndTaxIdToFamily{$upId."-".$taxId};
		$order = $upIdAndTaxIdToOrder{$upId."-".$taxId};
		$class = $upIdAndTaxIdToClass{$upId."-".$taxId};
		$phylum = $upIdAndTaxIdToPhylum{$upId."-".$taxId};
		$speciesHash{$species} = 1;
		$genusHash{$genus} = 1;	
		$familyHash{$family} = 1;	
		$orderHash{$order} = 1;	
		$classHash{$class} = 1;	
		$phylumHash{$phylum} = 1;	
	}	
}
close(UNIREF);

print "<table>\n";
print " <tr><td>\n";
print "		<pre>\n";
print "		Based on UniProt: <b>".$uniprotVersion."</b>\n";
print "		# of proteomes: <b>".(keys %upAndTaxHash)."</b>\n";
print "		# of species: <b>".(keys %speciesHash)."</b>\n";
print "		# of genus: <b>".(keys %genusHash)."</b>\n";
print "		# of family: <b>".(keys %familyHash)."</b>\n";
print "		# of order: <b>".(keys %orderHash)."</b>\n";
print "		# of class: <b>".(keys %classHash)."</b>\n";
print "		# of phylum: <b>".(keys %phylumHash)."</b>\n";
print "		# of sequences: <b>".(keys %entryHash)."</b>\n";
print "		# of UniRef50 clusters: <b>".(keys %unirefHash)."</b>\n";
print "		</pre>\n";
print "</td></tr>";
print "<tr><td>";

open(SEQ, ">", "../data/totalSeqNumCorrConsist.txt") or die "Can't open ../data/totalSeqNumCorrConsist.txt\n";
$totalSeqNum = "".(keys %entryHash);
print SEQ $totalSeqNum;
close(SEQ);

open(UNIREF50, ">", "../data/totalUniRef50CorrConsist.txt") or die "Can't open ../data/totalUniRef50CorrConsist.txt\n" ;
$totalUniRef50Clusters = "".(keys %unirefHash);
print UNIREF50 $totalUniRef50Clusters;
close(UNIREF50);

