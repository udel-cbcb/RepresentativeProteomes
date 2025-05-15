while($line=<>) {
	chomp($line);
	$n{$line} = 1;
}
#>tr|A0A171|A0A171_PYRHR Glutamate synthase small subunit-like protein 1 OS=Pyrococcus horikoshii GN=gltY PE=4 SV=1
 
#open (IN,"/scratch/chenc/uniprot_data/uniprot.fasta") or die "Can't find /scratch/chenc/uniprot_data/uniprot.fasta\n";
open (IN,"../data/uniprot.fasta") or die "Can't find ../data/uniprot.fasta\n";
while($line=<IN>)
{ 
	#print $line;
	if ($line=~/^\>/) { 
		$x=(split / /,$line)[0]; 
		$x=~s/\>//; 
		$y=(split(/\|/, $x))[1];
	}
  	if ($n{$y}) { 
		print $line;
	}
}
close(IN);
