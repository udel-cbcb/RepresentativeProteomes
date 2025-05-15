
open(CP, "../data/proteomes_complete.txt") or die "Can't open ../data/proteomes_complete.txt\n";
while($line=<CP>) {
	($upId) = (split(/\t/, $line))[2];
	$cps{$upId} = 1;
}
close(CP);

open(PP, "../results_corr_consist/PPSeq/PPMembership.txt") or die "Can't open ../results_corr_consist/PPSeq/PPMembership.txt\n";
while($line=<PP>) {
	chomp($line);
	
	($ppId, $memberId) = (split(/\t/, $line))[0, 1];
	if(!$cps{$ppId} || !$cps{$memberId}) {
		print $line;
	}	
}
close(PP);

