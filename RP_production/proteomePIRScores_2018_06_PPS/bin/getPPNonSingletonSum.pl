if(@ARGV != 5) {
	print "Usage: perl getPPNonSingletonSum.pl mapping_accs2upid.txt taxToTaxGroup.txt proteomes_complete.txt 1to1.dat pp-x.txt\n";
	exit 1;
}

open(UP, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<UP>) {
	chomp($line);
	($ac, $upId) = (split(/\t/, $line))[0, 1];
	$upACs{$upId}{$ac} = 1;
}
close(UP);

for $upId (keys %upACs) {
	$upACsRef = $upACs{$upId};
	%upACsHash = %$upACsRef;
	$upACCount{$upId} = scalar keys(%upACsHash);
}

open(TAX, $ARGV[1]) or die "Can't open $ARGV[1]\n";
while($line=<TAX>) {
	chomp($line);
	($tax, $taxGroup) = (split(/\t/, $line))[0, 1];
	$taxToTaxGroup{$tax} = $taxGroup;
}
close(TAX);

#Taxon	Mnemonic	UPID	Scientific name	Common name	Synonym	Other Names	Rank	Lineage	Parent	Component Name
#305	RALSL	UP000006858	Ralstonia solanacearum	
open(CP, $ARGV[2]) or die "Can't open $ARGV[2]\n";
while($line=<CP>) {
	chomp($line);
	($tax, $os, $up, $sciname, $comm, $syn, $other) = (split(/\t/, $line))[0, 1, 2, 3, 4, 5, 6];
	if($sciname) {
		$upName{$up} = $tax."\t".$sciname."\t".$taxToTaxGroup{$tax};	
	}
	elsif($comm) {
		$upName{$up} = $tax."\t".$comm."\t".$taxToTaxGroup{$tax};	
	}
	elsif($syn) {
		$upName{$up} = $tax."\t".$syn."\t".$taxToTaxGroup{$tax};	
	}
	elsif($other) {
		$upName{$up} = $tax."\t".$other."\t".$taxToTaxGroup{$tax};	
	}
}
close(CP);

open(ONE, $ARGV[3]) or die "Can't open $ARGV[3]\n";
while($line=<ONE>) {
	chomp($line);
	($ac, $upId) = (split(/\s+/, $line))[0, 3];
	$oneACs{$upId}{$ac} = 1;
}
close(ONE);

open(PP, $ARGV[4]) or die "Can't open $ARGV[4]\n";
while($line=<PP>) {
	if($line =~ /^>/) {
		chomp($line);
		($pp) = (split(/\t/, $line))[0];
		$pp =~ s/>//;
		$ppInfo{$pp} = $line;
	}
	#>Pan-Proteome_UP000000211	751945	THEOS	Thermus oshimai JL-2	Bac/Dein-Therm	27111.03853(PPS:0,1,1,0,0,2407)	75(CUTOFF)	
	# #UP000000211	751945	2407
	elsif($line =~ /^\s+\#/) {
		chomp($line);
		$line =~ s/^\s+\#//;
		($up, $one) = (split(/\t/, $line))[0, 2];
		$reducedCP = $upACCount{$up} - $one;
		$percentReducedCP = sprintf("%.2f", ($reducedCP*100/$upACCount{$up}));
		$oneACsRef = $oneACs{$up};
		%oneACsHash = %$oneACsRef;
		$oneACsCount = scalar keys(%oneACsHash);
		$reduced1to1 = $oneACsCount - $one;
		$percentReduced1to1 = sprintf("%.2f", ($reduced1to1*100/$oneACsCount));
		#$ppMember{$pp}{$up."\t".$upName{$up}."\t".$one."\t".$upACCount{$up}."\t".$oneACsCount} = 1;	
		$ppMember{$pp}{$up."\t".$upName{$up}."\t".$one."\t".$upACCount{$up}."\t".$percentReducedCP} = 1;	
	}
}
close(PP);

$ppns = $ARGV[4];
$ppnssum = $ARGV[4];
$ppns =~ s/pp-/pp-ns-/;
$ppnssum =~ s/pp-/pp-ns-sum-/;

open(PPNS, ">", $ppns) or die "Can't open $ppns\n";
open(PPNSSUM, ">", $ppnssum) or die "Can't open $ppnssum\n";
#print PPNSSUM "Pan-Proteome\tTaxId\tOrgName\tTaxGroup\t#Pan-Orgs\t#Pan-Proteins\t#RP-Proteins\t#KB-Proteins\t#1to1-Proteins\t%reduction(KB)\t%reduction(1to1)\n";
print PPNSSUM "Pan-Proteome\tTaxId\tOrgName\tTaxGroup\t#Pan-Orgs\t#Pan-Proteins\t#RP-Proteins\t#CP-Proteins\t%reduction(CP)\n";
for $pp (keys %ppMember) {
	$ppMemberRef = $ppMember{$pp};
	%ppMemberHash = %$ppMemberRef;
	$memberCount = scalar keys(%ppMemberHash);
	if($memberCount > 1) {
		print PPNS $ppInfo{$pp}."\n";
		$orgCount = 0;
		$oneEntryCount = 0;
		$upEntryCount = 0;
		$oneACsEntryCount = 0;
		$ppId = $pp;
		$ppId =~ s/Pan-Proteome_//;	
		$rpProteinCount = 0;
		for $member (sort keys %ppMemberHash) {
			
			$orgCount++;
			#my ($oneEntry, $upEntry, $oneACsEntry) = (split(/\t/, $member))[4, 5, 6];
			my ($oneEntry, $upEntry) = (split(/\t/, $member))[4, 5];
			$oneEntryCount += $oneEntry;
			$upEntryCount += $upEntry;	
			$oneACsEntryCount += $oneACsEntry;	
			print PPNS " #".$member."\n";
			#print $member."\t".$ppId."\n";
			if($member =~ /$ppId/) {
				$rpProteinCount = $oneEntry;
			}
		}
		print PPNS "\n";
		print PPNSSUM $pp."\t".$upName{$ppId}."\t".$orgCount."\t".$oneEntryCount."\t".$rpProteinCount."\t".$upEntryCount."\t".sprintf("%.2f", ($upEntryCount - $oneEntryCount)*100/$upEntryCount)."\n";	
		#print PPNSSUM $pp."\t".$upName{$ppId}."\t".$orgCount."\t".$oneEntryCount."\t".$rpProteinCount."\t".$upEntryCount."\t".$oneACsEntryCount."\t".sprintf("%.2f", ($upEntryCount - $oneEntryCount)*100/$upEntryCount)."\t".sprintf("%.2f", ($oneACsEntryCount - $oneEntryCount)*100/$oneACsEntryCount)"\n";	
	}	
}
close(PPNS);
close(PPNSSUM);
