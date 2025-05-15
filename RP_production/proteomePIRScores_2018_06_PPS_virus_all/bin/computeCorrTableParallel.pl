if(@ARGV != 3) {
	print "Usage: perl computeCorrTableParallel.pl uniref50.dat totalJobs jobID\n";
	exit 1;	
}


my $totalJobs = $ARGV[1];
my $jobID = $ARGV[2];
my $count = 0;
my $jobCount = -1;
my %corr = ();
my %corrMin = ();

if( ! -d "../data/corr_data/") {
	mkdir "../data/corr_data/" ;
}
open(LOG, ">../logs/corr_parallel_".$jobID.".log") or die "Can't open ../logs/corr_parallel_".$jobID.".log\n";
open(DATA,  ">../data/corr_data/corr_parallel_".$jobID.".txt") or die "Can't open ../data/corr_data/corr_parallel_".$jobID.".txt\n";
open(MIN,  ">../data/corr_data/min_corr_parallel_".$jobID.".txt") or die "Can't open ../data/corr_data/min_corr_parallel_".$jobID.".txt\n";

local $start = time;
my $date = `date`;
print LOG "Start at ".$date;

my $debug = 0;

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

for $p1 (sort keys %proteomes) {
	$jobCount++;
	if(($jobCount % $totalJobs)+1 == $jobID) {
		$count++;
		if($count % 100 == 0) {
			my $sysdate = `date`;
			chomp($sysdate);
			print LOG $sysdate." ".$count." processed\n";
		}
		for $p2 (sort keys %proteomes) {
			if($p1 eq $p2) {
				if($debug) {
					print LOG $p1."\t".$p2."\t\t\t\t100\n";
					print LOG $p2."\t".$p1."\t\t\t\t100\n";
					print LOG "Min\t".$p1."\t".$p2."\t\t\t\t100\n";
					print LOG "Min\t".$p2."\t".$p1."\t\t\t\t100\n";
				}
				print DATA $p1."\t".$p2."\t100\n";
				print MIN $p1."\t".$p2."\t100\n";
			}
			else {
				my %rpg = ();
				my %used_uniref = ();
				$rpg{$p1} = 1;
				$rpg{$p2} = 1;
                        	my $used_uniref_ref = get_used_uniref(%rpg);
				my %used_uniref = %$used_uniref_ref;			
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
				$min12 = 0;
				$min21 = 0;
				if($ASum < $BSum) {
                               		#$minx = 100.0*$ABSum / $ASum;
                                	#$miny = 100.0*$ABSum / $BSum;
                               		$dx = sprintf("%.3f", 100.0*$ABSum / $ASum);
					$dx =~ s/\.000$//;
                               		$minx = $dx;

                                	$dy = sprintf("%.3f", 100.0*$ABSum / $BSum);
					$dy =~ s/\.000$//;
                               		$miny = $dy;

					$min12 = $minx;
					$min21 = $miny;
				}
				else {
                              		#$minx = 100.0*$ABSum / $BSum;
                                	#$miny = 100.0*$ABSum / $ASum;
                              		$dx = sprintf("%.3f", 100.0*$ABSum / $BSum);
					$dx =~ s/\.000$//;
                               		$minx = $dx;
                                	$dy = sprintf("%.3f", 100.0*$ABSum / $ASum);
					$dy =~ s/\.000$//;
                               		$miny = $dy;
					$min12 = $miny;
					$min21 = $minx;
				}
				#my $x = (200.0*$ABSum)/($ASum+$BSum);
				my $dd = sprintf("%.3f", (200.0*$ABSum)/($ASum+$BSum));
				$dd =~ s/\.000$//;
                               	$x = $dd;
				if($debug) {
					print LOG $p1."\t".$p2."\t".$ASum."\t".$BSum."\t".$ABSum."\t".$x."\n";
					print LOG $p2."\t".$p1."\t".$ASum."\t".$BSum."\t".$ABSum."\t".$x."\n";
					print LOG "Min\t".$p1."\t".$p2."\t".$ASum."\t".$BSum."\t".$ABSum."\t".$corrMin{$p1."\t".$p2}."\n";
					print LOG "Min\t".$p2."\t".$p1."\t".$ASum."\t".$BSum."\t".$ABSum."\t".$corrMin{$p2."\t".$p1}."\n";
				}
				print DATA $p1."\t".$p2."\t".$x."\n";
				print MIN $p1."\t".$p2."\t".$min12."\n";
			}
		}			
	}
}
close(DATA);
close(MIN);

print LOG "Total Job: ".$jobCount."\n";
$date = `date`;
print LOG "End at ".$date;
$end = time - $start;
# Print runtime #
print LOG "\nRuning time(seconds): ".$end."\n";
printf LOG ("\n\nTotal running time: %02d:%02d:%02d\n\n", int($end / 3600), int(($end % 3600) / 60), int($end % 60));

close(LOG);
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
	return \%my_used_uniref;
}
