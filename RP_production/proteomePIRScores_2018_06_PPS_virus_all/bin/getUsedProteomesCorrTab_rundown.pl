open(RUNDOWN, "../data/rundown.txt") or die "Can't open ../data/rundown.txt\n";
while($line=<RUNDOWN>) {
        chomp($line);
        ($up, $tax) = (split(/\t/, $line))[0, 1];
        $rundown{$up."-".$tax} = 1;
        $rundowntab{$line} = 1;
}
close(RUNDOWN);

#UP000000214-1171373	UP000000214-1171373	100
#UP000000214-1171373	UP000000225-382245	1.11945392491468
#UP000000214-1171373	UP000000229-399739	1.06812556988407
open(CORR, "../data/proteomesCorrTable.txt") or die "Can't open ../data/proteomesCorrTable.txt\n";
while($line=<CORR>){
	($upIdAndTaxId1, $upIdAndTaxId2) = (split(/\t/, $line))[0, 1];
	if(!$rundown{$upIdAndTaxId1} && !$rundonw{$upIdAndTaxId2}) {
		print $line;
	}	
}
close(CORR);
