open(S, "../data/score/proteomeScores.txt") or die "Can't open ../data/score/proteomeScores.txt\n";
while($line=<S>) {
	if($line !~ /^UPID/) {
		($upId, $taxId) = (split(/\t/, $line))[0, 1];
		$proteomes{$upId."-".$taxId} = 1;
	}
}
close(S);

while($line=<>) {
	($upId1, $upId2) = (split(/\t/, $line))[0, 1];
	if($proteomes{$upId1} && $proteomes{$upId2}) {
		print $line;
	}
}
