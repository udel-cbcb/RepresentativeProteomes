if(@ARGV != 1) {
	print "Usage: perl addBack.pl rpg.txt\n";

	exit 1;
}

open(DEDUP, "../data/dedupe_info.txt") or die "Can't open ../data/dedupe_info.txt\n";
while($line=<DEDUP>) {
        chomp($line);
        ($count, $taxId, $keepUPId, $removeUPIds) = (split(/\t/, $line))[0,1,2,3];
	$taxKeep{$taxId} = $keepUPId;
	$taxRemove{$taxId} = $removeUPIds;
}
close(DEDUP);

$fileContent = "";
open(TMP, ">", "tmp.txt") or die "Can't open tmp.txt";
open(RPG, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<RPG>) {
	if($line =~ /^>/) {
		print TMP $line;
	}
	elsif($line =~ /^$/) {
		print TMP "\n";	
	}
	else {
		($upId, $taxId) = (split(/\t/, $line))[0, 1];
		$upId =~ s/^\s+//;
		if($taxKeep{$taxId}) {
			if($taxKeep{$taxId} ne $upId) {
				$taxRemove{$taxId}.= ";".$upId;
			}
			else {
				print TMP $line;
			}
		}
		else {
			print TMP $line;
		}	
	}
}
close(TMP);

open(TAXREMOVE, ">", "../data/taxRemove.txt") or die "Can't open ../data/taxRemove.txt\n";
for $k (keys %taxRemove) {
	print TAXREMOVE $k."\t".$taxRemove{$k}."\n";
}
close(TAXREMOVE);

my %rpgMembers = ();
open(TMP, "tmp.txt") or die "Can't open tmp.txt";
while($line=<TMP>) {
	if($line =~ /^>/) {
		#chomp($line);	
		%rpgMembers = ();	
		my ($upId, $taxId, $osCode, $rpX, $seedX) = (split(/\t/, $line))[0, 1, 2, 6, 8];
		$upId =~ s/^>//;
		$rp = $upId."-".$taxId;
		chomp($seedX);
		$seedX =~ s/\(X-seed\)//;
		if($seedX == 100.0000) {
			$seed = $upId."-".$taxId;	
		}
		print $line;	
		if($taxRemove{$taxId}) {
			$removed = $taxRemove{$taxId};
			$removed =~ s/\;$//;
			my @rec = split(/\;/, $removed);
			foreach(@rec) {
				$rpgMembers{$_."\t".$taxId} = " ".$_."\t".$taxId."\n";
			}		
		}
	}
	elsif($line =~ /^$/) {
		for $k (sort keys %rpgMembers) {
			$val= $rpgMembers{$k};
			if($val =~ /X-seed/) {
				print $rpgMembers{$k};
			}
			else {
				chomp($val);
				print $val."\t".$seed."\t".$rp."\n";
			}
			#print $val;
		}
		print "\n";
	}	
	else {
		#chomp($line);	
		my ($upId, $taxId, $osCode, $rpX, $seedX) = (split(/\t/, $line))[0, 1, 2, 6, 8];
		$upId =~ s/^\s+//;
		chomp($seedX);
		$seedX =~ s/\(X-seed\)//;
		if($seedX  == 100.00000) {
			$seed = $upId."-".$taxId;	
		}
		if($taxKeep{$taxId}) {
			$rpgMembers{$upId."\t".$taxId} = " ".$upId."\t".$taxId."\n";
			$removed = $taxRemove{$taxId};
			$removed =~ s/\;$//;
			my @rec = split(/\;/, $removed);
			foreach(@rec) {
				$rpgMembers{$_."\t".$taxId} = " ".$_."\t".$taxId."\n";
			}		
		}
		else {
			$rpgMembers{$upId."\t".$taxId} = $line; 		
		}
	}
}
close(TMP);
#`rm tmp.txt`;
