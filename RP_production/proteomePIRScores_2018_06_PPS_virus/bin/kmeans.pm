
$finalClusterRef = kmeans(\%taxIdPairsCorrHash, \%sumCorrTaxIdHash, 10);
%finalCluster = %$finalClusterRef;
for my $k (keys %finalCluster) {
        print $k.": ".$finalCluster{$k}."\n";
}

sub kmeans {
	my ($taxIdPairsCorrHashRef, $sumCorrTaxIdHashRef, $percent) = @_;
	my %taxIdPairsCorrHash = %$taxIdPairsCorrHashRef;
	my %sumCorrTaxIdHash = %$sumCorrTaxIdHashRef;	
	for my $key (keys %taxIdPairsCorrHash) {
		push(@proteomes, $key);
		#print $k."\n";
	}
	print "TaxId1: $taxIds1Size\n";
	print "TaxId2: $taxIds2Size\n";
	#my $percent = 1;
	my $k = int($taxIds1Size * $percent /100.0+0.5);
	print "K: $k\n";
	$count = 0;
	my $previousCentroids = ();
	my $currentCentroids = ();
	my %used = ();

	for (my $i = 0; $i < $k; $i++) {
	#for my $sumCorr (keys (%sumCorrTaxIdHash)) {
		do {
			my $j = int rand (keys(%sumCorrTaxIdHash)+1);
			$proteome = $proteomes[$j];
		} while($used{$proteome});	
		print "proteome: ". $proteome."\n";
		if($count < $k) {
			#print $sumCorr."\t".$sumCorrTaxIdHash{$sumCorr}."\n";
			$initCentroids[$count] = $proteome;
			$previousCentroids[$count] = $proteome;
			$currentCentroids[$count] = $proteome;
		}
		$count++;	
	}

	foreach(@initCentroids) {
		print $_."\n";
	}

	#for my $key (sort {$a <=> $b} keys %initCentroids) {
	#	print $key."|".$initCentroids{$key}."\n";
	#}

	my @cluster = ();
	for my $sumCorr (keys %sumCorrTaxIdHash) {
		my $taxId = $sumCorrTaxIdHash{$sumCorr};
		my $myCluster = findClosestCentroids(\@currentCentroids, $taxId, \%taxIdPairsCorrHash);
 		$cluster[$myCluster] .= $taxId.";"; 
	} 

	#for(my $i=0; $i< 1; $i++) {
	do {
		@previousCentroids = @currentCentroids;
		for(my $i=0; $i< @cluster; $i++) {
			#print $i."\t".$cluster[$i]."\n\n";
			my $centroid = computeCentroid($cluster[$i], \%taxIdPairsCorrHash);
			$currentCentroids[$i] = $centroid;
			print "Cluster $i\n";
			#print $currentCentroids[$i] ."<||>".$centroid."\n";
			foreach(@currentCentroids) {
				print $_."\n";
			}
		}
		print "Centroids no change: ".sameCentroids(\@previousCentroids, \@currentCentroids)."??\n";
		my $clusterRef = computeCluster(\@currentCentroids, \@proteomes, %taxIdPairsCorrHash);
		$cluster = @$clusterRef;
	}
	while(!sameCentroids(\@previousCentroids, \@currentCentroids));
	my %finalCluster = ();

	for(my $k=0; $k<@currentCentroids; $k++) {
		$centroid =  $currentCentroids[$k];
		$finalCluster{$centroid} = $centroid;	
		$members = $cluster[$k];
		$members =~ s/\;$//;
		@member = split(/\;/, $members);
		foreach(@member) {
			#print $centroid."\t".$_."\t".$taxIdPairsCorrHash{$centroid}{$_}."\n"; 
			if($_ ne $centroid) {
				$finalCluster{$centroid} .= ";".$_;	
			}
		}
	}
	for my $k (keys %finalCluster) {
		#print $k.": ".$finalCluster{$k}."\n";	
	}
	return \%finalCluster;
}

sub computeCluster {
	my($currentCentroidsRef, $protoemesArrayRef, $taxIdPairsCorrHashRef) = @_; 
	my @newCluster = ();
	my @proteomes = @$proteomesArrayRef;
	foreach(@protoemes) {
		$taxId = $_;
		my $myCluster = findClosestCentroids($currentCentroidsRef, $taxId, $taxIdPairsCorrHashRef);
 		$newcluster[$myCluster] .= $taxId.";"; 
	}
	return \@newCluster;
}
sub computeCentroid {
	my ($members, $taxIdPairsCorrHashRef) = @_;
	#print $members."\n";
	$members =~ s/\;$//;
	#print $members."\n";
	my @member = split(/\;/, $members);
	my %taxIdPairsCorrHash = %$taxIdPairsCorrHashRef;
	my %sumDist = ();
	for(my $i = 0; $i< @member; $i++) {
		for(my $j=0; $j<@member; $j++) {
			if($member[$i] ne "" && $member[$j] ne "") {
				$memberTaxId = $member[$i];
				#print "key ".$memberTaxId."\n";
				$sum = $sumDist{$memberTaxId};
				$sum +=$taxIdPairsCorrHash{$member[$i]}{$member[$j]};
				$sumDist{$memberTaxId} = $sum;
				#print $member[$i]." <|> ".$member[$j]." <|> ".$taxIdPairsCorrHash{$member[$i]}{$member[$j]}."|\n";
			}
			else {
				print $member[$i]." <|> ".$member[$j]." <|> ".$taxIdPairsCorrHash{$member[$i]}{$member[$j]}."|\n";
			}
		}
	}
	my %sumDistTaxIdHash = ();
	print "Keys: ".keys(%sumDist)."\n";
	for my $key (keys %sumDist) {
		my $scoreKey = sprintf("%d", $sumDist{$key}*100000000);
        	$scoreKey += 10000000000000;
                $scoreKey .=".".$key;
		#print $socrekey."++".$
                $sumDistTaxIdHash{$scoreKey} = $key;
	}
	my $max = 0;
	my $maxTaxId = "";
	for my $key1 (reverse (sort keys(%sumDistTaxIdHash))) {
		$sum = $key1;
		if($sum > $max) {
			$max = $sum;
			$maxTaxId = $sumDistTaxIdHash{$key1};
		}
		#print $key1."\t".$sumDistTaxIdHash{$key1}."\n";
	}			
	print "largest: ".$max."\t".$maxTaxId."\n";
	return $maxTaxId;
}

sub findClosestCentroids {
	my ($currentCentroidsRef, $taxId, $taxIdPairsCorrHashRef)= @_;
	my @currentCentroids = @$currentCentroidsRef;
	my %taxIdPairsCorrHash = %$taxIdPairsCorrHashRef;
	my $dist = 0;
	my $myCluster = 0;	
	for(my $i=0; $i < @currentCentroids; $i++) {
		my $centroid = $currentCentroids[$i];
		if($taxIdPairsCorrHash{$taxId}{$centroid} > $dist) {
			$dist = $taxIdPairsCorrHash{$taxId}{$centroid};
			$myCluster = $i;
		}	
	}
	return $myCluster;
}

sub sameCentroids {
	my ($prev, $current) = @_;
	@previousCentroids = @$prev;	
	@currentCentroids = @$current;
	$k = @previousCentroids;
	for ($i = 0; $i < $k; $i++) {
		if($previousCentroids[$i] != $currentCentroids[$i]) {
			print "Diff: ".$previousCentroids[$i]. " <|> ".$currentCentroids[$i]."\n";
			return 0;
		}
	}
	return 1;	
}
