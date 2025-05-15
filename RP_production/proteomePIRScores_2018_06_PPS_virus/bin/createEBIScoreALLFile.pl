if(@ARGV != 3) {
	print "Usage: perl createEBIScoreALLFile.pl  taxonomy-complete_yes.tab 1to1.txt ebi_score\n";
	exit 1;
}
#UPID	Taxon	Mnemonic	Scientific Name	Common Name	Synonym	Other Names	Reviewed	Rank	Lineage	Parent
#UP000000204	1221877	CHLPS	Chlamydia psittaci 01DC12						Bacteria; Chlamydiae; Chlamydiales; Chlamydiaceae; Ch
#lamydia/Chlamydophila group; Chlamydia	
#UP000000211	751945	THEOS	Thermus oshimai JL-2						Bacteria; Deinococcus-Thermus; Deinococci; Thermales; Thermac
#eae; Thermus
open(TAX, $ARGV[0]) or die "Can't open !$\n";
while($line=<TAX>) {
	chomp($line);
	($up_id, $tax_id, $name, $lineage) = (split(/\t/, $line))[0, 1, 3, 9];
	($super) = (split(/\; /, $lineage))[0];
	$orgInfo{$up_id.",".$tax_id} = $up_id.",".$tax_id.",".$name.",".lc($super);	
}
close(TAX);


open(ONETOONE, $ARGV[1]) or die "Can't open !$\n";
while($line=<ONETOONE>) {
	chomp($line);
	($ac, $tax_id, $up_id) = (split(/\s+/, $line))[0, 2, 3];
	$oneToOne{$ac} = $up_id.",".$tax_id;
}
close(ONETOONE);

#accession, taxonomy, description, gene, comment, xref, goxref, keyword , feature, citation, total\n
#Q6GZX4, 654924, 5.0, 0.0, 1.5, 0.7, 6.0, 0.0, 6.0, 0.0, 19.2

open(EBI, $ARGV[2]) or die "!$\n";
while($line=<EBI>) {
	chomp($line);
	if($line !~ /^accession, /) {
		($ac, $total) = (split(/\, /, $line))[0, 10];
		if($oneToOne{$ac}) {
			if($scores{$oneToOne{$ac}}) {
				$scores{$oneToOne{$ac}} .=",".$total;
			}
			else {
				$scores{$oneToOne{$ac}} .=$total;
			}			
		}
	}
}
close(EBI);

#tax_id,name,super,count,max,min,mean,std,sum
print "up_id,tax_id,name,super,count,max,min,mean,std,sum\n";

for $up_tax_id (keys %scores) {
	if($orgInfo{$up_tax_id}) {
		print $orgInfo{$up_tax_id}.",";
	}
	else {
		print $up_tax_id.",,,";
	}
		@values = split(/\,/, $scores{$up_tax_id});	
		print &count(\@values).",";
		print &max(\@values).",";
		print &min(\@values).",";
		print &mean(\@values).",";
		print &stdev(\@values).",";
		print &sum(\@values)."\n";
	#}
	#else {
		#print "No org info: $tax_id\n";
	#}	
}

sub average{
        my($data) = @_;
        if (not @$data) {
                die("Empty array\n");
        }
        my $total = 0;
        foreach (@$data) {
                $total += $_;
        }
        my $average = $total / @$data;
        return $average;
}
sub stdev{
        my($data) = @_;
        if(@$data == 1){
                return 0;
        }
        my $average = &average($data);
        my $sqtotal = 0;
        foreach(@$data) {
                $sqtotal += ($average-$_) ** 2;
        }
        my $std = ($sqtotal / (@$data-1)) ** 0.5;
        return $std;
}
sub min {
        @ == 1 or die ('Sub usage: $min = min(\@array);');
        my ($array_ref) = @_;
        my @array = sort { $a <=> $b } @$array_ref;
        #print "@array\n";
        return @array[0];
}

sub max {
        @ == 1 or die ('Sub usage: $max = max(\@array);');
        my ($array_ref) = @_;
        my @array = sort { $a <=> $b } @$array_ref;
        my $count = scalar @$array_ref;
        return @array[$count-1];
}

sub mean() {
        @_ == 1 or die ('Sub usage: $mean = mean(\@array);');
        my ($array_ref) = @_;
        my $sum;
        my $count = scalar @$array_ref;
        foreach (@$array_ref) {
                $sum += $_;
        }
        return $sum / $count;
}

sub sum() {
        @_ == 1 or die ('Sub usage: $mean = mean(\@array);');
        my ($array_ref) = @_;
        my $sum;
        foreach (@$array_ref) {
                $sum += $_;
        }
	return $sum;
}

sub count() {
        @_ == 1 or die ('Sub usage: $mean = mean(\@array);');
        my ($array_ref) = @_;
        my $count = scalar @$array_ref;
	return $count;
}

sub median() {
        @_ == 1 or die ('Sub usage: $median = median(\@array);');
        my ($array_ref) = @_;
        my $count = scalar @$array_ref;
        # Sort a COPY of the array, leaving the original untouched
        my @array = sort { $a <=> $b } @$array_ref;
        if ($count % 2) {
                return $array[int($count/2)];
        } else {
                return ($array[$count/2] + $array[$count/2 - 1]) / 2;
        }
}
