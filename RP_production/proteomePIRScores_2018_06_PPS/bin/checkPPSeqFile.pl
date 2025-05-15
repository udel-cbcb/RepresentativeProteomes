if(@ARGV != 1) {
	print "Usage: perl checkPPSeqFile.pl dir\n";
	exit 1;
}

$dir = $ARGV[0];
opendir(DIR, $ARGV[0]) or die "Can't open $ARGV[0]\n"; 

    while (my $file = readdir(DIR)) {

        # Use a regular expression to ignore files beginning with a period
  	next if ($file =~ m/^\./); 
	if($file =~ /fasta.gz$/) {
      		print "$dir/$file\n";
		%ppSeq = ();
		open(IN, "gunzip -c $dir/$file |") || die "can't open pipe to $dir/$file\n";
		while($line=<IN>) {
			if($line =~ /^>/) {
				($id) = (split(/ /, $line))[0];
				if($ppSeq{$id} > 0) {
					print "Duplicate ".$id."\n";
				}
				$ppSeq{$id} += 1;
			}
		}
		close(IN);
	}
   }   
closedir(DIR);
