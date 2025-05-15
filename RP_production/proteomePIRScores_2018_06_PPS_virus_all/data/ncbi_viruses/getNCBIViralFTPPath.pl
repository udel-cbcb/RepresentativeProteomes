while($line=<>) {
	if($line !~ /^#/) {
		chomp($line);
		($ftp) = (split(/\t/, $line))[19];
		#print $ftp."\n";
		($dir) = (split(/GCF_/, $ftp))[1];
		$file = "GCF_".$dir."_genomic.gff.gz";
		if($file =~ /ViralProj/) {
			print "wget ".$ftp."/$file -O $file\n";
		}
	}
}
