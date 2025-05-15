while($line=<>) {
	#print $line."\n";
	if($line =~ /^>/) {
		($rpId, $taxId) = (split(/\t/, $line))[0, 1];
		$rpId =~ s/^>//;
		$value = $taxToUPRP{$taxId};
		#print $value."\n";
		if(!$value) {
			$value = $rpId;
			$taxToUPRP{$taxId} = $value;
		}
		else {
			@rec = split(/;/, $value);	
			$found = 0;
			foreach(@rec) {
				if($_ eq $rpId) {
					$found = 1;
				}
			}
			if($found == 0) {
				if($value) {
					$value .= ";".$rpId;
				}
				else {
					$value = $rpId;
				}
				$taxToUPRP{$taxId} = $value;
			}
		}
	}
	elsif($line !~ /^$/) {
		($upId, $taxId) = (split(/\t/, $line))[0, 1];
		$upId =~ s/\s+//;
		$value = $taxToUPRP{$taxId};
		@rec = split(/;/, $value);	
		$found = 0;
		foreach(@rec) {
			if($_ eq $rpId) {
				$found = 1;
			}
		}
		if($found == 0) {
			if($value) {
				$value .= ";".$rpId;
			}
			else {
				$value = $rpId;
			}
			$taxToUPRP{$taxId} = $value;
			print $taxId."\t".$value."\n";
		}
	}
}

for $taxId(keys %taxToUPRP) {
	print $taxId."\t".$taxToUPRP{$taxId}."\n";
}
