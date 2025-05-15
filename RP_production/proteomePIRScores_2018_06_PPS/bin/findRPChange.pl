if(@ARGV != 2) {
	print "Usage: perl findRPChange.pl new old\n";
	exit 1;
}
open(RP1, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<RP1>) {
	chomp($line);
	$rp{$line} += 1;
}
close(RP1);

open(RP2, $ARGV[1]) or die "Can't open $ARGV[1]\n";
while($line=<RP2>) {
	chomp($line);
	$rp{$line} += 2;
}
close(RP2);

$new = 0;
$old = 0;
$both = 0;
for $k (keys %rp) {
	print $k."\t".$rp{$k}."\n";	
	if($rp{$k} == 1) {
		$new++;
	}
	if($rp{$k} == 2) {
		$old++;
	}
	if($rp{$k} == 3) {
		$both++;
	}
}

print "\n\n";
print "New: ".$new."\n";
print "Old: ".$old."\n";
print "Both: ".$both."\n";
