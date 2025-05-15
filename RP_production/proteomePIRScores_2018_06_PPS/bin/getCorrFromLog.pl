#open(CP, "../data/score/proteomeASScores.txt") or die "Can't open ../data/score/proteomeASScores.txt\n";
#while($line=<CP>) {
#	chomp($line);
#        ($cp, $tax) = (split(/\t/, $line))[0];
#        $cps{$cp."-".$tax} = 1;
#}
#close(CP);

#Min Thread 6 inside Corr UP000000580-262316 UP000033495-1629720 0.71740 : miny = 0.191938579654511	3(AB) 1563(B) + 599(A)
#Min Thread 6 inside Corr UP000033495-1629720 UP000000580-262316 0.905966885348329
while($line=<>) {
	if($line =~ /^Thread / && $line =~ / inside Corr /) {
		#print $line;
		chomp($line);
		@rec = split(/\s+/, $line);
		if(@rec  == 7) {
			if($rec[4] =~ /^UP00/ && $rec[5] =~ /^UP00/ && $rec[6] =~ /^[+-]?\d+\.?\d*$/) {
				$up1 = $rec[4];
				$up1 =~ s/^\s+//;
				$up1 =~ s/\s+$//;
				$up2 = $rec[5];
				$up2 =~ s/^\s+//;
				$up2 =~ s/\s+$//;
				 #if($cps{$up1} && $cps{$up2}) {
                                        #print $up1."\t".$up2."\t".$rec[7]."\n";
                                #}
				$cpCors{$up1."_".$up2} =  $up1."\t".$up2."\t".$rec[6];
			}
		}
	}
}

for $key (sort keys %cpCors) {
        print $cpCors{$key}."\n";
}
