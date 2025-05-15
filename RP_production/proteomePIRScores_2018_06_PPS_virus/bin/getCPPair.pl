if(@ARGV != 3) {
	print "Usage: perl getCPPair.pl oldRPG75.txt newRPG75.txt replacedTaxId.txt\n";
	exit 1;
}

my %processedOld = ();
my %processedNew = ();
#open(OLDRP, $ARGV[0]."/75/rpg-75.txt") or die "Can't open $ARGV[0]/75/rpg-75.txt\n";
open(OLDRP, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<OLDRP>) {
	chomp($line);
	if($line !~ /^$/) {
		if($line=~ /^>/) {
			my ($rp, $osCode, $os) = (split(/\t/, $line))[0, 1, 2];
			$rp =~ s/>//;
			$oldRPs{$rp} = $osCode."[".$os."]";	
			$processedOld{$rp} = 0;
			$oldCPs{$rp} = $osCode."[".$os."]"."(RP)";	
		}
		else {
			my ($p, $osCode, $os) = (split(/\t/, $line))[0, 1, 2];
			$p =~ s/\s+//;
			$oldCPs{$p} = $osCode."[".$os."]";	
			
		}
	}
}
close(OLDRP);

#print "Old: ".keys(%oldRPs)."\n";
#open(NEWRP, $ARGV[1]."/75/rpg-75.txt") or die "Can't open $ARGV[1]/75/rpg-75.txt\n";
open(NEWRP, $ARGV[1]) or die "Can't open $ARGV[1]\n";
while($line=<NEWRP>) {
	chomp($line);
	if($line !~ /^$/) {
		if($line=~ /^>/) {
			my ($rp, $osCode, $os) = (split(/\t/, $line))[0, 1, 2];
			$rp =~ s/>//;
			$newRPs{$rp} = $osCode."[".$os."]";	
			$newCPs{$rp} = $osCode."[".$os."]"."(RP)";	
		}
		else {
			my ($p, $osCode, $os) = (split(/\t/, $line))[0, 1, 2];
			$p =~ s/\s+//;
			$newCPs{$p} = $osCode."[".$os."]";	
		}
	}
}
close(NEWRP);
#print "New: ".keys(%newRPs)."\n";

#RP75_taxonIDChange.txt 
#OLD_RP_Taxon	#seq	%(#)no_change	%(#)missing	%(#)changed	List_of_change [taxonID:#(example);]
#210[HELPY; Helicobacter pylori (Campylobacter pylori); Bac/Delta-Epsilon-proteo](RP)	1553	0.00(0)	0.13(2)	99.87(1551)	85962:1551:1553(O25079);
#442[GLUOX; Gluconobacter oxydans (Gluconobacter suboxydans); Bac/Alpha-proteo](RP)	2626	0.00(0)	0.11(3)	99.89(2623)	290633:2623:2626(Q5FP92);

#open(REPLACED, "../data/replacedTaxonId.txt") or die "Can't find ../data/replacedTaxonId.txt\n";
open(REPLACED, $ARGV[2]) or die "Can't find $ARGV[2]\n";
while($line=<REPLACED>) {
	chomp($line);
	if($line =~ /^r/) {
		($old, $new) = (split(/\t/, $line))[1, 2];
		$changed{$old} = $new;
	}
}
close(REPLACED);

for my $k (keys %changed) {
	if(!$processedNew{$k}) {
		if($newCPs{$changed{$k}}) {
			$processedOld{$k} = 1;
			$processedNew{$changed{$k}} =  "Changed\t".$k."\t".$oldCPs{$k}."\t".$changed{$k}."\t".$newCPs{$changed{$k}}."\n"; 
		}
		else {
			if($oldCPs{$k}) {
				$processedOld{$k} = 1;
				$processedNew{$k} = "Missing\t$k\t$oldCPs{$k}\t\t\n";
			}
		}
	}
}

for my $k (keys %newCPs) {
	#print $k."\t". $processed{$k}."\n";
	if(!$processedNew{$k}) { 
		if($oldCPs{$k}) {
			$processedOld{$k} = 1;
			$processedNew{$k} = "Same\t".$k."\t".$oldCPs{$k}."\t".$k."\t".$newCPs{$k}."\n";
		}
		else {
			$processedNew{$k} = "New\t\t\t".$k."\t".$newCPs{$k}."\n";
		}
	}	
}
for my $k (sort keys %processedNew) {
	print $processedNew{$k};
}
for my $k (sort keys %processedOld) {
	if($processedOld{$k} == 0) {
		print "Missing\t$k\t$oldRPs{$k}\t\t\n";
	}
}
