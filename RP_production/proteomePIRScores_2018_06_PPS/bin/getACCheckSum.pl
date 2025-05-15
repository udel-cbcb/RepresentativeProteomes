while($line=<>) {
	if($line=~ /^AC   /) {
        	$ac=(split /\s+/,$line)[1]; 
		$ac=~s/\;//;
                if($firstAC eq "") {
                        $firstAC = $ac;
               	}
	}
	#SQ   SEQUENCE   256 AA;  29735 MW;  B4840739BF7D4121 CRC64;
	if($line =~ /^SQ   /) {
		($checkSum) = (split(/\s+/, $line))[6];
		print $ac."\t".$checkSum."\n";
	}
	                
}
