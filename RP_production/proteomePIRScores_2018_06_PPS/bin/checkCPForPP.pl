
open(CP, "../data/proteomes_complete.txt") or die "Can't open ../data/proteomes_complete.txt\n";
while($line=<CP>) {
	($upId) = (split(/\t/, $line))[2];
	$cps{$upId} = 1;
}
close(CP);

open(PP, "../results_corr_consist/pp-55bac_arch-75fungi-NS-Prev.txt.2016_02_22") or die "Can't open ../results_corr_consist/pp-55bac_arch-75fungi-NS-Prev.txt\n";
while($line=<PP>) {
	($ppId, $memberId) = (split(/\t/, $line))[0, 4];
	if(!$cps{$ppId} || !$cps{$memberId}) {
		print $line;
	}	
}
close(PP);

