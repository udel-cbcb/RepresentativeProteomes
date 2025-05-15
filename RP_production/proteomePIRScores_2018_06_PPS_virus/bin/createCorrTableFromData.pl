my $dir = '../data/corr_data';

my %corr_table = ();
my %min_corr_table = ();

my @files = ();

`rm ../logs/table.log`;

opendir(DIR, $dir) or die $!;
while (my $file = readdir(DIR)) {
    push (@files, $file);
}
@files = sort {$a cmp $b} @files;
foreach my $file (@files) {
       	if ($file =~ m/^corr_parallel/) {
		$file_name = $dir."/".$file;
		open(LOG, ">>../logs/table.log") or die "Can't open ../logs/table.log\n";
		print LOG $file_name."\n";
		close(LOG);
		open(F, $file_name) or die $!;
		while($line=<F>) {
			$corr_table{$line} = 1;
		}
		close(F);
	}
}
closedir(DIR);

open(CORR, ">../data/corrTable.txt") or die "Can't open ../data/corrTable.txt\n";
for $key (sort keys (%corr_table)) {
	print CORR $key;
}
close(CORR);
%corr_table = ();

@files = ();
opendir(DIR, $dir) or die $!;
while (my $file = readdir(DIR)) {
    push (@files, $file);
}
@files = sort {$a cmp $b} @files;
foreach my $file (@files) {
       	if ($file =~ m/^min_corr_parallel/) {
		$file_name = $dir."/".$file;
		open(LOG, ">>../logs/table.log") or die "Can't open ../logs/table.log\n";
		print LOG $file_name."\n";
		close(LOG);
		open(F, $file_name) or die $!;
		while($line=<F>) {
			$min_corr_table{$line} = 1;
		}
		close(F);
	}
}
closedir(DIR);



open(MINCORR, ">../data/corrTableMin.txt") or die "Can't open ../data/corrTableMin.txt\n";
for $key (sort keys (%min_corr_table)) {
	print MINCORR $key;
}
close(MINCORR);

%corr_table = ();
