if(@ARGV != 3) {
	print "Usage: perl catCorrTableFromData.pl corr_data_dir corrTable.txt catCorrTableFromData.log\n";
	exit 1;
}

my $corr_data_dir = $ARGV[0];
opendir(DIR, $ARGV[0]) or die "Can't open $corr_data_dir\n";
open(CORRTABLE, ">", $ARGV[1]) or die "Can't open $ARGV[1]\n";
my $log = $ARGV[2];
open(LOG, ">", $log) or die "Can't open $log\n";	
local $start = time;
my $date = `date`;
print LOG "Start at ".$date;
close(LOG);
#foreach my $file ( sort { $a <=> $b } readdir(DIR) ) {
while (my $file = readdir(DIR)) {
	if($file =~ /^min_corr/) {
		my $corr_table_file = $corr_data_dir."/".$file;
		open(LOG, ">>", $log) or die "Can't open $log\n";	
		print LOG $corr_table_file."\n";
		close(LOG);
		open(CORR, $corr_table_file) or die "Can't open $corr_table_file\n";
		while($line=<CORR>) {
			print CORRTABLE $line;
		}
		close(CORR);
	}
}
closedir(DIR);
close(CORRTABLE);

open(LOG, ">>", $log) or die "Can't open $log\n";	
$date = `date`;
print LOG "End at ".$date;
$end = time - $start;
# Print runtime #
print LOG "\nRuning time(seconds): ".$end."\n";
printf LOG ("\n\nTotal running time: %02d:%02d:%02d\n\n", int($end / 3600), int(($end % 3600) / 60), int($end % 60));
close(LOG)

