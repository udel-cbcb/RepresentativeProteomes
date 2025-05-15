#>329726 ACAM1   Acaryochloris marina (strain MBIC 11017)        Bac/CyanoBac    27111.30025(PPS:0,1,1,0,322,7931)       10.047515907978523(AS Mean)     55(CUTOFF)             
if(@ARGV != 1) {
	print "Usage: perl convertRP75And55ToExcel.pl rp75euk55archandbac.txt\n";
	exit 1;
}                                                                                                                                                                             
$header = "RPG"."\t"."UPId"."\t"."ISRP"."\t"."TaxonId"."\t"."OSCode"."\t"."OrganismName"."\t"."TaxonGroup"."\t"."PPS"."\t"."ReferenceProteome-pps"."\t"."PreviousRP-pps"."\t"."#UniquePMID-pps"."\t"."#UniquePDB-pps"."\t"."#Swiss-prot-pps"."\t"."#Entries-pps"."\t"."MeanAnnotationScore"."\t"."Cutoff"."\t"."Co-membership"."\t"."IsReferenceProteome"."\n";
print $header;
open(RP, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<RP>) {
	if($line !~ /^$/) {
		chomp($line);
		($upId, $tax, $os, $name, $group, $ppsStr, $asStr, $corr, $refp) = (split(/\t/, $line))[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]; 
		($ppsTotal, $ppsComp) = (split(/\(PPS:/, $ppsStr))[0, 1];
		$ppsComp =~ s/\)//;
		($refpScore, $prevRPScore, $pmid, $pdb, $sp, $entry) = (split(/\,/, $ppsComp))[0, 1, 2, 3, 4, 5];
		$asMean = $asStr;
		$asMean =~ s/\(AS Mean\)//;
		if($line =~ /^>/) {
			$rp =$upId;
			$rp =~ s/\>//;
			$cutoff = $corr;
			$cutoff =~ s/\(CUTOFF\)//;
			
			#print $tax."\t".$os."\t".$name."\t".$group."\t".$ppsTotal."\t".$refpScore."\t".$prevRPScore."\t".$pmid."\t".$pdb."\t".$sp."\t".$entry."\t".$asMean."\t"."\t".$refp."\n";
			print $rp."\t".$rp."\t"."RP"."\t".$tax."\t".$os."\t".$name."\t".$group."\t".$ppsTotal."\t".$refpScore."\t".$prevRPScore."\t".$pmid."\t".$pdb."\t".$sp."\t".$entry."\t".$asMean."\t".$cutoff."\t"."\t".$refp."\n";
		}
		else {
			$corr =~ s/\(X\)//;
			$upId =~ s/\s+//;
			#print $tax."\t".$os."\t".$name."\t".$group."\t".$ppsTotal."\t".$refpScore."\t".$prevRPScore."\t".$pmid."\t".$pdb."\t".$sp."\t".$entry."\t".$asMean."\t".$corr."\t".$refp."\n";
			print $rp."\t".$upId."\t"."\t".$tax."\t"."\t".$os."\t".$name."\t".$group."\t".$ppsTotal."\t".$refpScore."\t".$prevRPScore."\t".$pmid."\t".$pdb."\t".$sp."\t".$entry."\t".$asMean."\t".$cutoff."\t".$corr."\t".$refp."\n";

		}
	
	}
	else {
		#print $line;
	}
}
close(RP);
