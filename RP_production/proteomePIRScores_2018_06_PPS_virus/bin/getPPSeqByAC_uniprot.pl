if(@ARGV != 3) {
	print "Usage: perl getPPSeqByAC_uniprot.pl ppACFile uniprot.fasta PPSeqDir\n";
	exit 1;
}

$ppACFile = @ARGV[0];
$uniprotFasta = @ARGV[1];
$ppSeqDir = @ARGV[2];
#UP000000212	55(CUTOFF)	Bac/Firmicute	K8E169	UP000000212	1234679	UniRef50_K8E169
open(PPAC, $ppACFile) or die "Can't open $ppACFile\n";
while($line=<PPAC>) {
	chomp($line);
	($upId, $ac) = (split(/\t/, $line))[0, 3];
	if($ppAC{$ac}) {
		$ppAC{$ac} .=",".$upId;
	}
	else {
		$ppAC{$ac} = $upId;
	}	
}
close(PPAC);
#>tr|A0A171|A0A171_PYRHR Glutamate synthase small subunit-like protein 1 OS=Pyrococcus horikoshii GN=gltY PE=4 SV=1
 
#open (IN,"/scratch/chenc/uniprot_data/uniprot.fasta") or die "Can't find /scratch/chenc/uniprot_data/uniprot.fasta\n";
open (IN, $uniprotFasta) or die "Can't find $uniprotFasta\n";
while($line=<IN>)
{ 
	chomp($line);
	#print $line;
	if ($line=~/^\>/) { 
		$x=(split / /,$line)[0]; 
		$x=~s/\>//; 
		$y=(split(/\|/, $x))[1];
		if($ppAC{$y}) {
			@ppList = split(/\,/, $ppAC{$y});	
			foreach(@ppList) {
				#print $line." PP=".$ppAC{$y}."\n";
				$ppSeq{$_} .= $line." PP=".$_."\n";
			}
		}
		else {
			$ppAC{$y} = 0;
			$y = 0;
			@ppList = ();
		}
	}
	else {
  		if ($y && $ppAC{$y}) { 
			@ppList = split(/\,/, $ppAC{$y});	
			foreach(@ppList) {
				#print $line."\n";
				$ppSeq{$_} .= $line."\n";
			}
		}
	}
}
close(IN);

for $pp (keys %ppSeq) {
	$ppSeqFile = $ppSeqDir."/".$pp.".fasta";		
	open(PPSEQ, ">".$ppSeqFile) or die "Can't open $ppSeqFile\n";	
	print PPSEQ $ppSeq{$pp};	
	close(PPSEQ);
}
