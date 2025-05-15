if(@ARGV != 2) {
	print "Usage: perl addEBIScoreToPIRRPs.pl ebi_all_score.txt rpg.txt\n";
	exit 1;
}

#up_id,tax_id,name,super,count,max,min,mean,std,sum
#UP000006093,1133853,Escherichia coli O104:H4 (strain 2009EL-2071),bacteria,5030,73.7,0.5,11.8045129224652,14.1121907840253,59376.7000000002
#
open(EBI, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<EBI>) {
	chomp($line);
	if($line !~ /^up_id/) {
		($upId, $mean, $sum) = (split(/\,/, $line))[0, 7, 9];
		$mean =~ s/\s+//g;
		$sum =~ s/\s+//g;
		$ebiMeanScore{$upId} = sprintf("%.3f", $mean);
	}
}
close(EBI);

open(RP, $ARGV[1]) or die "Can't open $ARGV[1]\n";
while($line=<RP>){ 
	chomp($line);
	if($line =~ /^>/) {
		@rec = split(/\t/, $line);
		$upId = $rec[0];
		$upId =~ s/^>//;	
		print "$rec[0]"."\t".$rec[1]."\t".$rec[2]."\t".$rec[3]."\t".$rec[4]."\t".$rec[5]."\t".$ebiMeanScore{$upId}."(AS Mean)\t".$rec[6]."\t".$rec[7]."\n";	
	}
	elsif($line =~ /^\s+/) {
		@rec = split(/\t/, $line);
		$upId = $rec[0];
		$upId =~ s/\s+//;	
		print "$rec[0]"."\t".$rec[1]."\t".$rec[2]."\t".$rec[3]."\t".$rec[4]."\t".$rec[5]."\t".$ebiMeanScore{$upId}."(AS Mean)\t".$rec[6]."\t".$rec[7]."\n";	
	}
	else {
		print "\n";
	}	
}
close(RP);
