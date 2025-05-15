#!/usr/bin/perl
$argc = @ARGV;
if($argc != 2) {
        print "Usage: perl getBasicStatisticsCorrConsist.pl unirefxx.dat uniprotVersionNumber\n";
        exit;
}
$unirefdata = $ARGV[0];
$uniprotVersion = $ARGV[1];

open(RUNDOWN, "../data/rundown.txt") or die "Can't open ../data/rundown.txt\n";
while($line=<RUNDOWN>) {
        chomp($line);
        ($up, $tax) = (split(/\t/, $line))[0, 1];
        $rundown{$up."-".$tax} = 1;
        $rundowntab{$line} = 1;
}
close(RUNDOWN);

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

open(RPG, "../results_corr_consist/75/rpg-75.txt") or die "Can't open ../results_corr_consist/75/rpg-75.txt\n";
while($line=<RPG>) {
	if($line !~ /^$/) {
		($upId, $taxId) = (split(/\t/, $line))[0, 1];
		$upId =~ s/>//;
		$upId =~ s/ //;
		if(!$rundown{$upId."-".$taxId}) {
			$usedProteomes{$upId."-".$taxId} = 1;
		}
	}
}
close(RPG);

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
		$speciesHash{$species} = 1;
		$genusHash{$genus} = 1;	
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
print "		# of sequences: <b>".(keys %entryHash)."</b>\n";
print "		# of UniRef50 clusters: <b>".(keys %unirefHash)."</b>\n";
print "		</pre>\n";
print "</td></tr>";
print "<tr><td>";

open(SEQ, ">", "../data/totalSeqNumCorrConsist_rundown.txt") or die "Can't open ../data/totalSeqNumCorrConsist_rundown.txt\n";
$totalSeqNum = "".(keys %entryHash);
print SEQ $totalSeqNum;
close(SEQ);

open(UNIREF50, ">", "../data/totalUniRef50CorrConsist_rundown.txt") or die "Can't open ../data/totalUniRef50CorrConsist_rundown.txt\n" ;
$totalUniRef50Clusters = "".(keys %unirefHash);
print UNIREF50 $totalUniRef50Clusters;
close(UNIREF50);

