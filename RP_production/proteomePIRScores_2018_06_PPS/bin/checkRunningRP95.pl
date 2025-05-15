#UP000075114-446	UP000075114-446;UP000073956-446;UP000074166-446;UP000072126-446;UP000074002-446;UP000092078-446;UP000070201-446;
while($line=<>) {
	($first, $second) = (split(/\t/, $line))[0,1];
	($firstTax) = (split(/\-/, $first))[1];
	$second =~ s/\;$//;
	@rec = split(/\;/, $second);
	foreach(@rec) {
		($secondTax) = (split(/\-/, $_))[1];
		if($firstTax != $secondTax) {
			print $line;
			break;
		}
	}
}
