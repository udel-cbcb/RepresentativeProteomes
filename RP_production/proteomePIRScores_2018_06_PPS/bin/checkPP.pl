#>Pan_Proteome_UP000000204	1221877	CHLPS	Chlamydia psittaci 01DC12	Bac/Chlamyd	95(CUTOFF)	
# #UP000000204	1221877	959
#  #UP000015899	1112256	207
#   #UP000014548	1112252	289
#    A0A0E1QZ41	UP000000204	1221877	UniRef50_Q9Z7G3
#     A0A0E1QZ46	UP000000204	1221877	UniRef50_Q824Y0
#
%rpUniRef = ();
%cpCount = ();
%ppCount = ();
%entry = ();
while($line=<>) {
	chomp($line);
	if($line =~ /^>Pan_Proteome/) {
		($rp, $rpTaxId) = (split(/\t/, $line))[0, 1];
		$rp =~ s/>Pan_Proteome_//;
		%rpUniRef = ();
		%cpCount = ();
		%ppCount = ();
		%entry = ();
	}
	elsif( $line =~ /^ #/) {
		($cp, $taxId, $count) = (split(/\t/, $line))[0, 1, 2];
		$cp =~ s/\s+#//;
		$cpCount{$cp."-".$taxId} = $count;
		#print $cp."-".$taxId."\t".$count."\n";
	}
	elsif( $line =~ /^ / && $line !~ /^ #/) {
		($ac, $cp, $taxId, $uniref) = (split(/\t/, $line))[0, 1, 2, 3];
		if($entry{$ac}) {
			print "Duplicate entry ".$line."\n";
		}		
		$ac =~ s/\s+//;
		#print $line."\n";
		if($ppAC{$cp."-".$taxId}{$ac} == 1) {
			print "Duplicate Error ".$line."($rp."-".$rpTaxId)\n";
		}
		#print $cp."-".$taxId."\t".$ac."\n";
		$ppAC{$cp."-".$taxId}{$ac} = 1;
		$ppCount{$cp."-".$taxId} += 1;
		if(($cp."-".$taxId) =~ ($rp."-".$rpTaxId)) {
			$rpUniRef{$rp."-".$rpTaxId}{$uniref} = 1;
		}
		else {
			if($rpUniRef{$rp."-".$rpTaxId}{$uniref} == 1) {
				print "UniRef Error ".$line."($rp."-".$rpTaxId)\n";
			}	
		} 	
	}
	elsif($line =~ /^$/) {
		for $key (keys(%ppCount)) {
			if($cpCount{$key} != $ppCount{$key}) {
				print "Count Error " .$key."\t".$cpCount{$key}."\t".$ppCount{$key}.  "\n";
			} 
		}		
	}
        	
}
