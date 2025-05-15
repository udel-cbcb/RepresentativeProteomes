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
	($ppId, $ac, $upId) = (split(/\t/, $line))[0, 3, 4];
	if($ppAC{$ac}) {
		$ppAC{$ac} .=",".$ppId;
		$ppACUP{$ppId."\t".$ac} = $upId;
	}
	else {
		$ppAC{$ac} = $ppId;
		$ppACUP{$ppId."\t".$ac} = $upId;
	}	
	$allACs{$upId."\t".$ac} = 1;
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
				$allACs{$ppACUP{$_."\t".$y}."\t".$y} = 2; 
				$ppSeq{$_} .= $line." UPId=".$ppACUP{$_."\t".$y}." PPId=".$_."\n";
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
			$allACs{$y} = 2; 
			@ppList = split(/\,/, $ppAC{$y});	
			foreach(@ppList) {
				#print $line."\n";
				$allACs{$ppACUP{$_."\t".$y}."\t".$y} = 2; 
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
	`gzip $ppSeqFile`;
}

print "Total UP-ACs: ".keys(%allACs)."\n";
for $ac (keys %allACs) {
	if($allACs{$ac} == 1) {
		print $ac."\t".$allACs{$ac}."\n";
	}
}
