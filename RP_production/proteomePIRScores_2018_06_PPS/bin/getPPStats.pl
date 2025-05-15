#>UP000000212	1234679	CARML	Carnobacterium maltaromaticum LMA28	Bac/Firmicute	37111.25720(PPS:1,1,1,12.31,3250)	75(CUTOFF)	RefP	81.35541(X-seed)
#UP000051477	1449341	CARML	Carnobacterium maltaromaticum DSM 20342	Bac/Firmicute	19110.18333(PPS:0,0,0,11.05,3401)	81.35541(X-RP)		100.00000(X-seed)
# UP000051747	2751	CARML	Carnobacterium maltaromaticum (Carnobacterium piscicola)	Bac/Firmicute	19110.67255(PPS:0,0,4,11.57,3163)	79.54399(X-RP)		83.63352(X-seed)

if(@ARGV != 2) {
	print "Usage: perl getPPStats.pl rp.txt pp.txt\n";
	exit 1;
}

print "PP\tPPMember\tTaxonId\tOSCode\tName\tTaxonGroup\t#CPSeq\t#PPSeq\n";
#open(RP, "../results_corr_consist/75/rpg-75.txt") or die "Can't open ../results_corr_consist/75/rpg-75.txt\n";
open(RP, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<RP>) {
	if($line !~ /^$/) {
		($up, $tax, $os, $name, $taxgroup, $pps) = (split(/\t/, $line))[0, 1, 2, 3, 4, 5];
		$up =~ s/^>//g;
		$up =~ s/\s+//g;
		($cp) = (split(/,/, $pps))[4];
		$cp =~ s/\)//;
		$info{$up} = $tax."\t".$os."\t".$name."\t".$taxgroup."\t".$cp;
	}
}
close(RP);

#UP000000212	55(CUTOFF)	Bac/Firmicute	K8E1D6	UP000000212	1234679	UniRef50_K8E7P9
#UP000000212	55(CUTOFF)	Bac/Firmicute	K8E1D7	UP000000212	1234679	UniRef50_K8E1D7
#UP000000212	55(CUTOFF)	Bac/Firmicute	K8E1D8	UP000000212	1234679	UniRef50_Q839Y6
#open(PP, "../results_corr_consist/pp-55bac_arch-75fungi-NS.txt") or die "Can't open ../results_corr_consist/pp-55bac_arch-75fungi-NS.txt\n";
open(PP, $ARGV[1]) or die "Can't open $ARGV[1]\n";
while($line=<PP>) {
	($rp, $pp) = (split(/\t/, $line))[0, 4];
	$stats{$rp}{$pp} += 1;
}
close(PP);

foreach my $rp (sort keys %stats) {
    foreach my $pp (sort keys %{ $stats{$rp} }) {
	print $rp."\t".$pp."\t".$info{$pp}."\t".$stats{$rp}{$pp}."\n";
    }
}

