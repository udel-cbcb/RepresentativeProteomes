#!/usr/bin/perl

local $start = time;
$date = `date`;
print "Start at ".$date;


my %proteomeUniRefHash =(); 
my %proteomeHash =(); 
my %unirefHash = ();
open(UNIREF, "<", "../data/uniref50.dat") or die "Can't open ../data/uniref50.dat";
#open(UNIREF, "<", "t") or die "Can't open ../data/uniref50.dat";
print "Reading uniRef50 ...\n";
while($line =<UNIREF>) {
	chomp($line);
	@rec = split(/\t/, $line);
	$ac = $rec[0];
	$proteomeId = $rec[1]."-".$rec[2];
	$uniRefAc = $rec[3];
	$proteomeUniRefHash{$proteomeId}{$uniRefAc} = 1;		
	$proteomeHash{$proteomeId} = 1;
	$unirefHash{$uniRefAc} = 1;
	$count++;
	if($count % 1000000 eq 0) {
		$date = `date`;
		print $date;
		print "UniRef50 read ".$count." .. done\n";
	}	
}
close(UNIREF);
print "Reading uniRef50 ... done\n";

my %common = ();
$count = 0;
for $pid1 (sort keys %proteomeHash) {
	$count++;
	$log = "";
	$pUniRef = $proteomeUniRefHash{$pid1};
	%pUniRefHash = %$pUniRef;
	#for $uniref (keys %unirefHash) {
	for $uniref (keys %pUniRefHash) {
		for $pid2 (sort keys %proteomeHash) {
			if($proteomeUniRefHash{$pid1}{$uniref} && $proteomeUniRefHash{$pid2}{$uniref}) {
				#print "$pid1 $pid2 $uniref\n";
				$common{$pid1."\t".$pid2} +=1;
				#$log .= $pid1."\t".$pid2."\t".$common{$pid1."\t".$pid2}."\n";
			}
			else {
				#$log .= $pid1."\t".$pid2."\t0\n";
			}
		}
	}
	#print $log;
	print $count." proteomes processed\n";
}

#open(PAIR, ">", "../data/corrTable.txt") or die "Can't open ../data/corrTable.txt\n";
#open(PAIRMIN, ">", "../data/corrTableMin.txt") or die "Can't open ../data/corrTableMin.txt\n";
for $pidPair (sort keys %common) {
	($pid1, $pid2) = (split(/\t/, $pidPair))[0, 1];	
        my $ASum = 0;
        my $BSum = 0;
        my $ABSum = 0;
        my $minx = 0;
        my $miny = 0;
	$log = "";
	$ABSum = $common{$pidPair};
	$pUniRef = $proteomeUniRefHash{$pid1};
	%pUniRefHash = %$pUniRef;
	$ASum = keys (%pUniRefHash);	
	$pUniRef = $proteomeUniRefHash{$pid2};
	%pUniRefHash = %$pUniRef;
	$BSum = keys (%pUniRefHash);	
	if($ASum < $BSum) {
        	$minx = 100*$ABSum /$ASum;
                $miny = 100*$ABSum /$BSum;
                $log .= "min $num 100*$ABSum/$ASum = ".$minx."\n";
                $log .=  "min $num 100*$ABSum/$BSum = ".$miny."\n";
                $log .= "min ".$num." ".$pid1. " vs ".$pid2." : minx = ".$minx."\t$ABSum(AB) $ASum(A) + $BSum(B)\n";
                $log .=  "min ".$num." ".$pid2. " vs ".$pid1." : miny = ".$miny."\t$ABSum(AB) $BSum(B) + $ASum(A)\n";
                $proteomesCorMatrixHashMin{$pid1}{$pid2} = $minx;
                $log .= "min ".$num." A < B ".$pid1. " vs ".$pid2." : ".$minx."\n";
                $proteomesCorMatrixHashMin{$pid2}{$pid1} = $miny;
                $log .= "min ".$num." A < B ".$pid2. " vs ".$pid1." : ".$miny."\n";
        }
        else {
                $minx = 100*$ABSum /$BSum;
                $miny = 100*$ABSum /$ASum;
             	$log .= "min $num 100*$ABSum/$BSum = ".$minx."\n";
                $log .= "min $num 100*$ABSum/$ASum = ".$miny."\n";
                $log .= "min ".$num." ".$pid1. " vs ".$pid2." : miny = ".$miny."\t$ABSum(AB) $ASum(A) + $BSum(B)\n";
                $log .= "min ".$num." ".$pid2. " vs ".$pid1." : minx = ".$minx."\t$ABSum(AB) $BSum(B) + $ASum(A)\n";
                $proteomesCorMatrixHashMin{$pid1}{$pid2} = $miny;
                $log .= "min ".$num." A >= B ".$pid1. " vs ".$pid2." : ".$miny."\n";
                $proteomesCorMatrixHashMin{$pid2}{$pid1} = $minx;
                $log .= "min ".$num." A >= B ".$pid2. " vs ".$pid1." : ".$minx."\n";
        }
        my $x = (200*$ABSum)/($ASum+$BSum);
        $log .= $num." ".$pid1. " vs ".$pid2." : x = ".$x."\t$ABSum(AB) $ASum(A) + $BSum(B)\n";
        $log .= $num." ".$pid2. " vs ".$pid1." : x = ".$x."\t$ABSum(AB) $BSum(B) + $ASum(A)\n";
        $log .= "$num (200*$ABSum)/($ASum+$BSum) = ".$x."\n\n";
        $proteomesCorMatrixHash{$pid1}{$pid2} = $x;
        $proteomesCorMatrixHash{$pid2}{$pid1} = $x;
	print $log;
}
#close(PAIR);
#close(PAIRMIN);

for my $pid1 (sort keys %proteomesCorMatrixHash) {
	my $corMatrixHashRef = $proteomesCorMatrixHash{$pid1};
	my %corMatrixHash = %$corMatrixHashRef;
	for my $Id2 (sort keys %threadCorMatrixHash) {
		$proteomesCorMatrixHashTmp{$pid1."\t".$pid2} = $proteomesCorMatrixHash{$pid1}{$pid2};
		$proteomesCorMatrixHashTmp{$pid2."\t".$pid1} = $proteomesCorMatrixHash{$pid2}{$pid1};
	}
}
for my $pid1 (sort keys %proteomesCorMatrixHashMin) {
	my $corMatrixHashRefMin = $proteomesCorMatrixHashMin{$pid1};
	my %corMatrixHashMin = %$corMatrixHashRefMin;
	for my $pid2 (sort keys %corMatrixHashMin) {
		$proteomesCorMatrixHashTmpMin{$pid1."\t".$pid2} = $proteomesCorMatrixHashMin{$pid1}{$pid2};
		$proteomesCorMatrixHashTmpMin{$pid2."\t".$pid1} = $proteomesCorMatrixHashMin{$pid2}{$pid1};
	}
}

for my $k (keys %proteomesCorMatrixHashTmp) {
	my ($pid1, $pid2) = (split(/\t/, $k))[0, 1];	
	$proteomesCorMatrixHash{$pid1}{$pid2} = $proteomesCorMatrixHashTmp{$k};
}

for my $k (keys %proteomesCorMatrixHashTmpMin) {
	my ($pid1, $pid2) = (split(/\t/, $k))[0, 1];	
	$proteomesCorMatrixHashMin{$pid1}{$pid2} = $proteomesCorMatrixHashTmpMin{$k};
}

print "Writing output...\n";
open(CORRMIN, ">", "../data/proteomesCorrMin.txt");
print CORRMIN "AA\t";
for my $key1 (sort keys(%proteomesCorMatrixHashMin)) {
	print CORRMIN $key1."\t";	
} 
print CORRMIN "\n";



for my $key1 (sort keys(%proteomesCorMatrixHashMin)) {
	my $sum = 0;
	my $details = "";
	my $secondHashRef = $proteomesCorMatrixHashMin{$key1};
	my %secondHash = %$secondHashRef;
	foreach my $key2 (sort keys(%secondHash)) {
		$details .= $secondHash{$key2}."\t";		
		$sum += $secondHash{$key2};
	}
	$proteomesCorHashMin{$key1} = $sum; 
	print CORRMIN $key1."($sum)\t".$details."\n";
}
close(CORRMIN);			

open(CORR, ">", "../data/proteomesCorr.txt");
print CORR "AA\t";
for my $key1 (sort keys(%proteomesCorMatrixHash)) {
	print CORR $key1."\t";	
} 
print CORR "\n";
for my $key1 (sort keys(%proteomesCorMatrixHash)) {
	my $sum = 0;
	my $details = "";
	my $secondHashRef = $proteomesCorMatrixHash{$key1};
	my %secondHash = %$secondHashRef;
	foreach my $key2 (sort keys(%secondHash)) {
		$details .= $secondHash{$key2}."\t";		
		$sum += $secondHash{$key2};
	}
	$proteomesCorHash{$key1} = $sum; 
	print CORR $key1."($sum)\t".$details."\n";
}
close(CORR);			


open(CORRTABMIN, ">", "../data/proteomesCorrTableMin.txt");
for my $key1 (sort keys(%proteomesCorMatrixHashMin)) {
       	my $secondHashRef= $proteomesCorMatrixHashMin{$key1};
       	my %secondHash = %$secondHashRef;
       	for my $key2 (sort keys(%secondHash)) {
      		print CORRTABMIN $key1."\t".$key2."\t".$proteomesCorMatrixHashMin{$key1}{$key2}."\n";
      	}
}
close(CORRTABMIN);

open(CORRTAB, ">", "../data/proteomesCorrTable.txt");
for my $key1 (sort keys(%proteomesCorMatrixHash)) {
       	my $secondHashRef= $proteomesCorMatrixHash{$key1};
       	my %secondHash = %$secondHashRef;
       	for my $key2 (sort keys(%secondHash)) {
      		print CORRTAB $key1."\t".$key2."\t".$proteomesCorMatrixHash{$key1}{$key2}."\n";
      	}
}
close(CORRTAB);

$date = `date`;
print "End at ".$date;
$end = time - $start;
# Print runtime #
print "\nRuning time(seconds): ".$end."\n"; 
printf("\n\nTotal running time: %02d:%02d:%02d\n\n", int($end / 3600), int(($end % 3600) / 60), 
int($end % 60));


