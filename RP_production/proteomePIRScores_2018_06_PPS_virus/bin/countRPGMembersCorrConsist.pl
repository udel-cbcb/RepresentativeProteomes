while(<>) {
	$line = $_;
	if($line !~ /^$/) {
		if($line =~ /^\>/) {
			$line =~ s/^\>//;
			($upId, $taxId) = (split(/\t/, $line))[0, 1];
			$upAndTaxHash{$upId."-".$taxId}++;		
		}
		else {
			$upAndTaxHash{$upId."-".$taxId}++;		

		}
	}
}
foreach my $key (sort keys %upAndTaxHash) {
	print $key."\t".$upAndTaxHash{$key}."\n";
}
