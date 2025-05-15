if(@ARGV != 1) {
	print "Usage: perl createRP75ViralWithBlankLine.pl resultDir\n";
	exit 1;
}
$resultDir = $ARGV[0];
$prev = "";
$current = "";
@result = ();
open(RPG75, "$resultDir/75/rpg-75.txt") or die "Can't open $resultDir/75/rpg-75.txt\n";
while($line=<RPG75>) { 
	$current = $line;
	($taxGroup) = (split(/\t/, $line))[4];
	#if($taxGroup =~ /Euk\// || $taxGroup =~ /Other Eukaryota/) {
		push(@result, $line);
	#}
}
close(RPG75);
$resultLength = @result;
for ($i=0; $i < $resultLength; $i++) {
	print $result[$i];
	if($result[$i+1] =~ /^>/) {
	#if($result[$i] =~ /^>/) {
		#print "\n";
	}
}
