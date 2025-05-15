#!/usr/bin/perl 
use strict;
use warnings;

my %refp = ();

my $refpTable = "../data/refp.tb";
open(REFP, $refpTable) or die "Can't open $refpTable\n";
while(my $line=<REFP>) {
	chomp($line);
	$refp{$line} = 1;
}
close(REFP);


my $usedEntryFile = "../data/score_fresh/proteome_entries.txt";
my %usedEntries = ();
open(ENTRY, $usedEntryFile) or die "Can't open $usedEntryFile\n";
while(my $line=<ENTRY>) {
	chomp($line);
	$usedEntries{$line} = 1;
}
close(ENTRY);

#Q197D0 030L_IIV3 345201 UP000001358
#Q6GZU6 030R_FRG3G 654924 UP000008770
#

my $oneToOneFile = "../data/1to1.dat";
my %upIdAndTaxIdEntry = ();
open(ONE, $oneToOneFile) or die "Can't open $oneToOneFile\n";
while(my $line=<ONE>) {
	chomp($line);
	my ($ac, $taxId, $upId) = (split(/\s+/, $line))[0, 2, 3];
	$upIdAndTaxIdEntry{$upId."-".$taxId} = $ac; 
}
close(ONE);
 
#accession, taxonomy, description, gene, comment, xref, goxref, keyword , feature, citation, total
#Q6GZX4, 654924, 5.0, 0.0, 1.5, 0.6, 6.0, 0.0, 6.0, 0.0, 19.1
#Q6GZX3, 654924, 5.0, 0.0, 0.5, 0.6, 4.0, 0.0, 7.5, 0.0, 17.6

my %entryAS = ();
my $ebiScoreDir = "../data/ebi_score/score";
open(AS, $ebiScoreDir) or die "Can't open $ebiScoreDir\n";
while(my $line=<AS>) {
	chomp($line);
	if($line !~ /^accession/) {
		my ($ac, $scoreTotal) = (split(/\, /, $line))[0, 10];
		if($usedEntries{$ac}) {
			$entryAS{$ac} = $scoreTotal; 
		}
	}
}
close(AS);

my %upIdAndTaxIdASMean = ();

my $scoreDir = "../data/score_fresh";
opendir(DIR, $scoreDir) or die "Can't open $scoreDir\n";
while (my $file = readdir(DIR)) {
      	if($file =~ /_score\.txt$/) {
		my ($upIdAndTaxId) = (split(/\_/, $file))[0];
		my $scoreFilePath = $scoreDir."/".$upIdAndTaxId."_score\.txt";	
        	#print "$file\n";
        	#print "$scoreFilePath\n";
		createPMIDASScorePerProteome($scoreDir, $scoreFilePath, $upIdAndTaxId, \%upIdAndTaxIdASMean);				
	}
}
closedir(DIR);

sub createPMIDASScorePerProteome {
	my ($scoreDir, $scoreFilePath, $upIdAndTaxId, $upIdAndTaxIdASMean) = @_;
	my $entryPMIDTotalMin= 1000000000000000;
	my $entryPMIDTotalMax = -1;
	my $entryASTotalMin= 1000000000000000;
	my $entryASTotalMax = -1;
	#Accession	#PMID	#PDB	SwissProt	Sum
	#A0A024EWZ1	0	0	0	110
	#A0A024EWZ8	0	0	0	110
	#A0A024EX02	0	0	0	110
	open(PPS, $scoreFilePath) or die "Can't open $scoreFilePath\n";
	my %pmidASEntry = ();
	my $sumASTotal = 0;
	my $entryCount = 0;
	while(my $line=<PPS>) {
		chomp($line);
		if($line !~ /^Accession/) {
			my ($ac, $pmidCount) = (split(/\t/, $line))[0, 1];
			if($entryAS{$ac} < $entryASTotalMin) {
				$entryASTotalMin = $entryAS{$ac};	
			}		
			if($entryAS{$ac} > $entryASTotalMax) {
				$entryASTotalMax = $entryAS{$ac};	
			}
			if($pmidCount < $entryPMIDTotalMin) {
				$entryPMIDTotalMin = $pmidCount;
			}		
			if($pmidCount > $entryPMIDTotalMax) {
				$entryPMIDTotalMax = $pmidCount;
			}
			$pmidASEntry{$ac} = $ac."\t".$pmidCount."\t".$entryAS{$ac};		
			$sumASTotal += $entryAS{$ac};
			$entryCount += 1;
		}	
	}
	close(PPS);
	$upIdAndTaxIdASMean{$upIdAndTaxId} = $sumASTotal / $entryCount;

	my $rangeEntryPMIDTotal = $entryPMIDTotalMax - $entryPMIDTotalMin;	
	my $rangeEntryASTotal = $entryASTotalMax - $entryASTotalMin;
	my $entryASFile = $scoreDir."/".$upIdAndTaxId."_AS\.txt";
	open(ENTRYAS, ">", $entryASFile)  or die "Can't open $entryASFile\n";	
	print ENTRYAS "Accession\t#UniqPMID\t#ASTotal\tNormPMID\tNormASTotal\tSum\n";
	for my $ac (keys %pmidASEntry) {
		my ($pmid, $asTotal) = (split(/\t/, $pmidASEntry{$ac}))[1, 2];
	 	my $normEntryPMID = "";
		if($rangeEntryPMIDTotal == 0) {
			$normEntryPMID = 100;
		}
		else {
			$normEntryPMID = 100*(1+(($pmid - $entryPMIDTotalMin)/$rangeEntryPMIDTotal));	
		}
	 	my $normEntryAS = "";
		if($rangeEntryASTotal == 0) {
			$normEntryAS = 10;
		}
		else {
			$normEntryAS = 10*(1+(($asTotal - $entryASTotalMin)/$rangeEntryASTotal));	
		}
		my $sum = $normEntryPMID + $normEntryAS;
		$pmidASEntry{$ac} .= "\t".$normEntryPMID."\t".$normEntryAS."\t".$sum;	
		print ENTRYAS $pmidASEntry{$ac}."\n";
	}
	close(ENTRYAS);
} 

#UPID	Taxon	#PMID	#PDB	#SwissProt	ScoreSum	TotalEntries	ScoreSum/TotalEntries	ReferenceProteome	PreviousRP
#UP000000204	1221877	0	0	0	19111.0083270475	954	20.0325034874712		
#UP000000211	751945	1	0	0	27111.0384772309	2407	11.2634144068263		PrevRP
#
my $proteomeScoreFile = "../data/score_fresh/proteomeScores.txt";
my $proteomePMIDCountMin= 1000000000000000;
my $proteomePMIDCountMax = -1;
my $proteomeASMeanMin= 1000000000000000;
my $proteomeASMeanMax = -1;
my $proteomeEntryCountMin= 1000000000000000;
my $proteomeEntryCountMax = -1;
my %proteomeASInfo = ();
open(PSCORE, $proteomeScoreFile) or die "Can't open $proteomeScoreFile\n";
while(my $line=<PSCORE>) {
	chomp($line);
	if($line !~ /^UPID/) {
		my $upId = "";
		my $taxId = "";
		my $pmidCount = "";
		my $entryCount = "";
		my $refP = "";
		my $prevRP = "";	
		($upId, $taxId, $pmidCount, $entryCount, $refP, $prevRP) = (split(/\t/, $line))[0, 1, 2, 6, 8, 9];	
		my $upIdAndTaxId = $upId."-".$taxId;
		if($pmidCount < $proteomePMIDCountMin) {
			$proteomePMIDCountMin = $pmidCount;
		}
		if($pmidCount > $proteomePMIDCountMax) {
			$proteomePMIDCountMax = $pmidCount;
		}
		my $ASMean = $upIdAndTaxIdASMean{$upIdAndTaxId};
		if($ASMean < $proteomeASMeanMin) {
			$proteomeASMeanMin = $ASMean;
		}		
		if($ASMean > $proteomeASMeanMax) {
			$proteomeASMeanMax = $ASMean;
		}		
		if($entryCount < $proteomeEntryCountMin) {
			$proteomeEntryCountMin = $entryCount;
		}
		if($entryCount > $proteomeEntryCountMax) {
			$proteomeEntryCountMax = $entryCount;
		}
		#$proteomeASInfo{$upIdAndTaxId} = $upId."\t".$taxId."\t".$refP."\t".$prevRP."\t".$pmidCount."\t".$ASMean."\t".$entryCount;
		$proteomeASInfo{$upIdAndTaxId} = $upId."\t".$taxId."\t".$refP."\t\t".$pmidCount."\t".$ASMean."\t".$entryCount;
	}
}
close(PSCORE); 

my $rangeProteomePMIDCount = $proteomePMIDCountMax - $proteomePMIDCountMin;
my $rangeProteomeASMean = $proteomeASMeanMax - $proteomeASMeanMin;
print "$rangeProteomeASMean = $proteomeASMeanMax - $proteomeASMeanMin\n";
my $rangeProteomeEntryCount = $proteomeEntryCountMax - $proteomeEntryCountMin;

my $proteomeASScoreFile = "../data/score_fresh/proteomeASScores.txt";

open(PAS, ">", $proteomeASScoreFile) or die "Can't open $proteomeASScoreFile\n";
print PAS "UPID\tTaxId\tRefP\tPrevRP\t#UniqPMID\tASMean\t#Entry\tNormPMID\tNormASMean\tNormEntryCount\tSum\n";
for my $upIdAndTaxId (keys %proteomeASInfo) {
	my ($upId, $taxId, $refp, $prevRP, $pmidCount, $ASMean, $entryCount) = (split(/\t/, $proteomeASInfo{$upIdAndTaxId}))[0, 1, 2, 3, 4, 5, 6];
	print PAS $proteomeASInfo{$upIdAndTaxId}."\t";
	my $normPMID = 1000*(1+(($pmidCount - $proteomePMIDCountMin)/$rangeProteomePMIDCount));
	my $normASMean = 100*(1+(($ASMean - $proteomeASMeanMin)/$rangeProteomeASMean));
	my $normEntryCount = 1*(1+(($entryCount - $proteomeEntryCountMin)/$rangeProteomeEntryCount));
		
	my $sum = $normPMID + $normASMean + $normEntryCount;
	if($refp) {
		$sum = 10000+ $sum;
	}

	if($prevRP) {
		#$sum = 8000 + $sum;
	}
	print PAS $normPMID."\t".$normASMean."\t".$normEntryCount."\t".$sum."\n";
}

close(PAS);
