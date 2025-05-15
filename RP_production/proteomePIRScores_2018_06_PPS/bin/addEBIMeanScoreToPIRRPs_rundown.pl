if(@ARGV != 2) {
	print "Usage: perl addEBIScoreToPIRRPs.pl ebi_all_score.txt rpg.txt\n";
	exit 1;
}
#tax_id,name,super,count,max,min,mean,std,sum
#11791,AKV murine leukemia virus (AKR (endogenous) murine leukemia virus),viruses,3, 105.8, 79.1, 90.0, 11.437657102746162, 270.0

open(EBI, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<EBI>) {
	chomp($line);
	if($line !~ /^up_id/) {
		($taxId, $mean, $sum) = (split(/\,/, $line))[1, 7, 9];
		$mean =~ s/\s+//g;
		$sum =~ s/\s+//g;
		$ebiMeanScore{$taxId} = sprintf("%.3f",$mean);
		#print $taxId."\t".$mean."\t".$sum."\n";
	}
}
close(EBI);

open(RP, $ARGV[1]) or die "Can't open $ARGV[1]\n";
while($line=<RP>){ 
	chomp($line);
	if($line =~ /^>/) {
		@rec = split(/\t/, $line);
		$id = $rec[0];
		$id =~ s/^>//;
		#print $line."\tAS(mean):".$ebiMeanScore{$id}."\n";	
		print ">$id"."\t".$rec[1]."\t".$rec[2]."\t".$rec[3]."\t".$rec[4]."\t".$ebiMeanScore{$id}."(AS Mean)\t".$rec[5]."\t".$rec[6]."\n";	
	}
	elsif($line =~ /^\s+/) {
		@rec = split(/\t/, $line);
		$id = $rec[0];
		$id =~ s/^\s+//;
		#print $line."\tAS(mean):".$ebiMeanScore{$id}."\n";	
		print " $id"."\t".$rec[1]."\t".$rec[2]."\t".$rec[3]."\t".$rec[4]."\t".$ebiMeanScore{$id}."(AS Mean)\t".$rec[5]."\t".$rec[6]."\n";	

	}
	else {
		print "\n";
	}	
}
close(RP);
