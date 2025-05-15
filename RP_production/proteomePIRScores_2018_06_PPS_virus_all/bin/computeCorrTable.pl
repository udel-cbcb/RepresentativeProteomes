if(@ARGV != 3) {
	print "Usage: perl computeCorrTable.pl uniref50.dat corrTable.txt corrTableMin.txt\n";
	exit 1;	
}

local $start = time;
my $date = `date`;
print "Start at ".$date;

my $debug = 1;

#A0A023J2U4	UP000026903	1414741	UniRef50_D3WAC2
open(UNIREF, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<UNIREF>) {
	chomp($line);
	my ($ac, $up, $tax, $uniref) = (split(/\t/, $line))[0, 1, 2, 3];
	if(!$proteome_uniref{$up."-".$tax}{$uniref}) {	
		$proteome_uniref{$up."-".$tax}{$uniref} = $ac;	
	}
	else {
		$proteome_uniref{$up."-".$tax}{$uniref} = ",".$ac;	
	}
	$proteomes{$up."-".$tax} = 1;
}
close(UNIREF);
my $count = 0;
my %corr = ();
my %corrMin = ();
for $p1 (keys %proteomes) {
	$count++;
	if($count % 100 == 0) {
		my $sysdate = `date`;
		chomp($sysdate);
		print $sysdate." ".$count." processed\n";
	}
	for $p2 (keys %proteomes) {
		if($p1 eq $p2) {
			$corr{$p1."\t".$p2} = 100;
			$corr{$p2."\t".$p1} = 100;
			$corrMin{$p1."\t".$p2} = 100;
			$corrMin{$p2."\t".$p1} = 100;
		}
		else {
			my %rpg = ();
			my %used_uniref = ();
			$rpg{$p1} = 1;
			$rpg{$p2} = 1;
                        my %used_uniref = get_used_uniref(%rpg);			
			#print keys(%used_uniref)."\n";
			my $ASum = 0;
                        my $BSum = 0;
                        my $ABSum = 0;
			my $minx = 0;
			my $miny = 0;
			for my $uniref (keys %used_uniref) {
				if($proteome_uniref{$p1}{$uniref}) {
					$ASum++;
				}
				if($proteome_uniref{$p2}{$uniref}) {
					$BSum++;
				}
				if($proteome_uniref{$p1}{$uniref} && $proteome_uniref{$p2}{$uniref}) {
					$ABSum++;
				}
			}
			if($ASum < $BSum) {
                               	$minx = 100.0*$ABSum / $ASum;
                                $miny = 100.0*$ABSum / $BSum;
				$corrMin{$p1."\t".$p2} = $minx;
				$corrMin{$p2."\t".$p1} = $miny;
			}
			else {
                              	$minx = 100.0*$ABSum / $BSum;
                                $miny = 100.0*$ABSum / $ASum;
				$corrMin{$p1."\t".$p2} = $miny;
				$corrMin{$p2."\t".$p1} = $minx;
			}
			my $x = (200.0*$ABSum)/($ASum+$BSum);
			$corr{$p1."\t".$p2} = $x;
			$corr{$p2."\t".$p1} = $x;
			if($debug) {
				print $p1."\t".$p2."\t".$ASum."\t".$BSum."\t".$ABSum."\t".$x."\n";
				print $p2."\t".$p1."\t".$ASum."\t".$BSum."\t".$ABSum."\t".$x."\n";
				print "Min\t".$p1."\t".$p2."\t".$ASum."\t".$BSum."\t".$ABSum."\t".$corrMin{$p1."\t".$p2}."\n";
				print "Min\t".$p2."\t".$p1."\t".$ASum."\t".$BSum."\t".$ABSum."\t".$corrMin{$p2."\t".$p1}."\n";
			}
		}
	}			
}
#open(CORR, ">", "../data/proteomesCorrTable.txt");
open(CORR, ">", $ARGV[1]) or die "Can't open $ARGV[1]\n";
for my $key (sort keys(%corr)) {
        print CORR $key."\t".$corr{$key}."\n";      
}
close(CORR);

#open(CORRMIN, ">", "../data/proteomesCorrTableMin.txt");
open(CORRMIN, ">", $ARGV[2]) or die "Can't open $ARGV[2]\n";
for my $key (sort keys(%corrMin)) {
        print CORRMIN $key."\t".$corrMin{$key}."\n";      
}
close(CORRMIN);



$date = `date`;
print "End at ".$date;
$end = time - $start;
# Print runtime #
print "\nRuning time(seconds): ".$end."\n";
printf("\n\nTotal running time: %02d:%02d:%02d\n\n", int($end / 3600), int(($end % 3600) / 60), int($end % 60));

sub get_used_uniref {
	my %my_rpg = @_;
	my %my_used_uniref = ();
	for my $up (keys %my_rpg) {
		$proteome_uniref_hashRef = $proteome_uniref{$up};
		%proteome_uniref_hash = %$proteome_uniref_hashRef;
		for my $uniref (keys %proteome_uniref_hash) {
			$my_used_uniref{$uniref} = 1;
		}
	}
	return %my_used_uniref;
}
