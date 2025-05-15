while(<>) {
	$line = $_;
	if($line !~ /^$/) {
		if($line =~ /^\>/) {
			$line =~ s/^\>//;
			$taxId = (split(/\t/, $line))[0];
			$taxHash{$taxId}++;		
		}
		else {
			$taxHash{$taxId}++;		

		}
	}
}
foreach my $key (sort keys %taxHash) {
	print $key."\t".$taxHash{$key}."\n";
}
