#!/usr/bin/perl


use Proteome;
use Protein;
use UniRef50;
use threads;
use threads::shared;

if(@ARGV != 5) {
	print "Usage: perl computeProteomeCorrTableMultiServersHashMin.pl totalNumServers serverNum dataDir logDir outDir\n";
	exit 1;
}
my $numThreads :shared;
$totalNumServers = $ARGV[0];
$serverNum = $ARGV[1];
$dataDir = $ARGV[2];
$logDir = $ARGV[3];
$outDir = $ARGV[4];

local $start = time;
$date = `date`;
print "Start at ".$date;



my %proteinsHash =();
print "Getting entry score ...\n";
#Accession	#UniqPMID	#ASTotal	NormPMID	NormASTotal	Sum
#A0A0A1FMR9	0	0.2	100	10	110
foreach my $taxId (sort keys %taxIdScoresHash) {
	open(SCORE, "<", "$dataDir/score/$taxId"."_AS.txt") or die "Can't open $dataDir/score/$taxId"."_AS.txt\n";
	while($line = <SCORE>) {
       		chomp($line);
		if($line !~ /^Accession/) {
        		my @rec = split(/\t/, $line);
        		$ac = $rec[0];
        		$score = $rec[5];
			$protein = Protein->new($ac);
        		$protein->setScore($score);
        		$proteinsHash{$taxId}{$ac} = $protein;
		}
	}
	close(SCORE);
}
print "Getting entry score ...done\n";

my %proteomeUniRefHash =(); 
open(UNIREF, "<", "$dataDir/uniref50.dat") or die "Can't open $dataDir/uniref50.dat";
print "Reading uniRef50 ...\n";
while($line =<UNIREF>) {
	chomp($line);
	@rec = split(/\t/, $line);
	$ac = $rec[0];
	$taxId = $rec[1]."-".$rec[2];
	$uniRefAc = $rec[3];
	$proteinsHashVal = $proteinsHash{$taxId}{$ac};
	$proteomeUniRefHash{$taxId}{$uniRefAc} = 1;		
	$entryProteomeHash{$ac}{$taxId} = $uniRefAc;		
	$count++;
	if($count % 1000000 eq 0) {
		$date = `date`;
		print $date;
		print "UniRef50 read ".$count." .. done\n";
	}	
}
close(UNIREF);
print "Reading uniRef50 ... done\n";


%proteomesScoreHash = ();
my %proteomesCorMatrixHashTmp :shared;
my %proteomesCorMatrixHashTmpMin :shared;
my %proteomesCorMatrixHash =();
my %proteomesCorMatrixHashMin =();
my %proteomesCorHash =();
my %proteomesCorHashMin =();
print "Calculating proteome Cor Matrix...\n";

my @threads;
#for (my $count = 1; $count <= $numThreads; $count++) {
#	my $t = threads->new(\&computeProteomesCorMatrix, $count, \%proteomeUniRefHash);
#	push(@threads, $t);
#}

#foreach(@threads) {
#	my $num = $_->join;
#	print "done with thread $num\n";
#}

computeProteomesCorMatrix($totalNumServers,  $serverNum, \%proteomeUniRefHash);

sub computeProteomesCorMatrix {
	my $totalServers = shift;
	my $num = shift;
	my $threadProteomeUniRefHashRef = shift;
	my %threadProteomeUniRefHash = %$threadProteomeUniRefHashRef;		
	print "started server $num\n";
	my @taxIds = ();
	my %threadProteomesCorMatrixHash = ();
	my %threadProteomesCorMatrixHashMin = ();
	for my $key1 (sort keys(%threadProteomeUniRefHash)) {
		my $taxId1 = $key1;
		push(@taxIds, $taxId1);
	}
	for(my $i = 0; $i < @taxIds; $i++) {
		if(($i % $totalServers)+1 == $num) {	
			$taxId1 = $taxIds[$i];
			$log = "Server $num Corr ".$taxId1."\n"; 
			for(my $j = 0; $j < @taxIds; $j++) {
				$taxId2 = $taxIds[$j];
				if(!exists($threadProteomesCorMatrixHash{$taxId1}{$taxId2}) && !exists($threadProteomesCorMatrixHash{$taxId2}{$taxId1})) {
					if($taxId1 eq $taxId2) {
						$threadProteomesCorMatrixHash{$taxId1}{$taxId2} = 100;	
						$threadProteomesCorMatrixHash{$taxId2}{$taxId1} = 100; 	
						$threadProteomesCorMatrixHashMin{$taxId1}{$taxId2} = 100;	
						$threadProteomesCorMatrixHashMin{$taxId2}{$taxId1} = 100; 	
					}
					else {
                                        	my $uniRef1 = $threadProteomeUniRefHash{$taxId1};
                                        	my $uniRef2 = $threadProteomeUniRefHash{$taxId2};
                                        	my %uniRef1Hash = %$uniRef1;
                                        	my %uniRef2Hash = %$uniRef2;
                                        	my $ASum = 0;
                                        	my $BSum = 0;
                                        	my $ABSum = 0;
                                        	my %ABHash=();
						my $minx = 0;
						my $miny = 0;
                                        	foreach my $k1 (keys %uniRef1Hash) {
                                                	$ABHash{$k1} = "A";
                                                	$ASum++;
                                        	}
                                        	foreach my $k2 (keys %uniRef2Hash) {
                                                	$ABHash{$k2} .= "B";
                                                	$BSum++;
                                        	}
                                        	foreach my $k12 (keys %ABHash) {
                                                	if($ABHash{$k12} eq "AB") {
                                                        	$ABSum++;
                                                	}
                                        	}
						if($ASum < $BSum) {
							$minx = 100*$ABSum /$ASum;
							$miny = 100*$ABSum /$BSum;
							$log .= "min $num 100*$ABSum/$ASum = ".$minx."\n";
							$log .="min $num 100*$ABSum/$BSum = ".$miny."\n";
                                                	$log .= "min ".$num." ".$taxId1. " vs ".$taxId2." : minx = ".$minx."\t$ABSum(AB) $ASum(A) $BSum(B)\n";
                                                	$log .= "min ".$num." ".$taxId2. " vs ".$taxId1." : miny = ".$miny."\t$ABSum(AB) $ASum(A) $BSum(B)\n";
                                        		$threadProteomesCorMatrixHashMin{$taxId1}{$taxId2} = $minx;
                                        		$threadProteomesCorMatrixHashMin{$taxId2}{$taxId1} = $miny;
						}
						else {
							$minx = 100*$ABSum /$BSum;
							$miny = 100*$ABSum /$ASum;
							$log .= "min $num 100*$ABSum/$BSum = ".$minx."\n";
							$log .= "min $num 100*$ABSum/$ASum = ".$miny."\n";
                                                	$log .= "min ".$num." ".$taxId1. " vs ".$taxId2." : miny = ".$miny."\t$ABSum(AB) $ASum(A) $BSum(B)\n";
                                                	$log .= "min ".$num." ".$taxId2. " vs ".$taxId1." : minx = ".$minx."\t$ABSum(AB) $ASum(A) $BSum(B)\n";
                                        		$threadProteomesCorMatrixHashMin{$taxId1}{$taxId2} = $miny;
                                        		$threadProteomesCorMatrixHashMin{$taxId2}{$taxId1} = $minx;
						}
						my $x = (200*$ABSum)/($ASum+$BSum);
                                                $log .= $num." ".$taxId1. " vs ".$taxId2." : x = ".$x."\n";
                                                $log .= "$num (200*$ABSum)/($ASum+$BSum) = ".$x."\n\n";
                                        	$threadProteomesCorMatrixHash{$taxId1}{$taxId2} = $x;
                                        	$threadProteomesCorMatrixHash{$taxId2}{$taxId1} = $x;
                                	}
				}
			}
		
			open(LOG, ">>", "$logDir/corrMatrixServer_".$num.".log") or die "Can't open $logDir/corrMatrixServer_".$num.".log";
			print LOG $log;
			close(LOG);
		}
	}
	lock(%proteomesCorMatrixHashTmp);	
	print "Server $num out cor matrix size ".keys(%threadProteomesCorMatrixHash)."\n";
	open(TCORR, ">>", "$outDir/server_".$num."_corr.txt");
	for my $taxId1 (sort keys %threadProteomesCorMatrixHash) {
		my $threadCorMatrixHashRef = $threadProteomesCorMatrixHash{$taxId1};
		print "Server $num OUT Corr $taxId1\n";
		my %threadCorMatrixHash = %$threadCorMatrixHashRef;
		print "Server $num ins cor matrix size ".keys(%threadCorMatrixHash)."\n";
		for my $taxId2 (sort keys %threadCorMatrixHash) {
			$proteomesCorMatrixHashTmp{$taxId1."\t".$taxId2} = $threadProteomesCorMatrixHash{$taxId1}{$taxId2};
			$proteomesCorMatrixHashTmp{$taxId2."\t".$taxId1} = $threadProteomesCorMatrixHash{$taxId2}{$taxId1};
			print "Server $num inside Corr $taxId1 $taxId2 $threadProteomesCorMatrixHash{$taxId1}{$taxId2}\n";
			print TCORR $taxId1."\t".$taxId2."\t".$threadProteomesCorMatrixHash{$taxId1}{$taxId2}."\n";
		}
	}
	close(TCORR);
	$date = `date`;
	print $date." done with Server $num\n";
	lock(%proteomesCorMatrixHashTmpMin);	
	print "Min Server $num out cor matrix size ".keys(%threadProteomesCorMatrixHashMin)."\n";
	open(TCORRMIN, ">>", "$outDir/min_server_".$num."_min_corr.txt");
	for my $taxId1 (sort keys %threadProteomesCorMatrixHashMin) {
		my $threadCorMatrixHashRefMin = $threadProteomesCorMatrixHashMin{$taxId1};
		print "Min Server $num OUT Corr $taxId1\n";
		my %threadCorMatrixHashMin = %$threadCorMatrixHashRefMin;
		print "Min Server $num ins cor matrix size ".keys(%threadCorMatrixHashMin)."\n";
		for my $taxId2 (sort keys %threadCorMatrixHashMin) {
			$proteomesCorMatrixHashTmpMin{$taxId1."\t".$taxId2} = $threadProteomesCorMatrixHashMin{$taxId1}{$taxId2};
			$proteomesCorMatrixHashTmpMin{$taxId2."\t".$taxId1} = $threadProteomesCorMatrixHashMin{$taxId2}{$taxId1};
			print "Min Server $num inside Corr $taxId1 $taxId2 $threadProteomesCorMatrixHashMin{$taxId1}{$taxId2}\n";
			print TCORRMIN $taxId1."\t".$taxId2."\t".$threadProteomesCorMatrixHashMin{$taxId1}{$taxId2}."\n";
		}
	}
	close(TCORRMIN);
	$date = `date`;
	print $date." done with Min Server $num\n";
	return $num;
}

$date = `date`;
print "End at ".$date;
$end = time - $start;
# Print runtime #
print "\nRuning time(seconds): ".$end."\n"; 
printf("\n\nTotal running time: %02d:%02d:%02d\n\n", int($end / 3600), int(($end % 3600) / 60), 
int($end % 60));

