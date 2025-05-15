#!/usr/bin/perl 

my %proteomesHash;

open(CPA, "../data/mapping_accs2upid.txt") or die "Can't open ../data/mapping_accs2upid.txt";
while($line=<CPA>) {
        chomp($line);
        my ($ac, $upId) = (split(/\t/, $line))[0, 1];
        $cpa{$ac} = 1;
        $upCount{$upId."\t".$taxId} += 1;
        if(!$acToUPs{$ac}) {
                $acToUPs{$ac} .= $upId;
        }
        else {
                $acToUPs{$ac} .= ";".$upId;
        }
}
close(CPA);

open(TAX, "<". "../data/up-taxonomy-complete_yes.tab") or die "Can't open ../data/up-taxonomy-complete_yes.tab";
while($line=<TAX>) {
        chomp($line);
        if($line !~ /^UPID/) {
                my @rec = split(/\t/, $line);
		my $upId = $rec[0];
                my $taxId = $rec[1];
                my $lineage = $rec[9];
                if($lineage !~/^Viruses\;/) {
                        $proteomesHash{$upId."\t".$taxId} = 1;
			open(ENTRY, "<", "../data/score/".$upId."-".$taxId."_score.txt") or die "Can not open ../data/score/".$upId."-".$taxId."_score.txt\n";
                        while($line=<ENTRY>) {
                                if($line !~ /Accession/) {
                                        @rec = split(/\t/, $line);
                                        $proteomeEntryHash{$upId."\t".$taxId}{$rec[0]} = 1;
                                }
                        }
                        close(ENTRY);
                }
        }
}

close(TAX);
print "TotalProteomes: ".keys(%proteomesHash)."\n"; 

#<entry id="UniRef50_P85491" updated="2010-02-09">
#<entry id="UniRef50_UPI000023F703" updated="2008-05-20">
#<property type="UniProtKB accession" value="Q5G619"/>
#<property type="NCBI taxonomy" value="3888"/>
#open(UNIREF, "<", "../data/uniref50.xml") or die "$!\n";
#gunzip -c /big/wangy/uniprot_data/curr_tmp/uniref50.xml.gz
#$uniref50GZfile = "/big/wangy/uniprot_data/curr_tmp/uniref50.xml.gz";
$uniref50GZfile = "../data/uniref50.xml.gz";
open(UNIREF, "gunzip -c $uniref50GZfile |") || die "can't open pipe to $uniref50GZfile\n";
while($line=<UNIREF>) {
	if($line =~ /^\<entry id=\"UniRef50_/) {
		if($line !~ /^\<entry id=\"UniRef50_UPI/) {
			$id = (split(/\s+/, $line))[1];
			$uniRefId =(split(/\"/, $id))[1];
		}
	}
	elsif($line =~ /^\<representativeMember\>/ || $line =~ /^\<member\>/) {
		$memberStart = 1;
	}
	elsif($line =~ /^\<\/representativeMember\>/ || $line =~ /^\<\/member\>/) {
		$memberStart = 0;
	}
	elsif($line =~ /^\<property type=\"UniProtKB accession\" value=\"/) {
		if($memberStart eq 1) {
			$ac = substr($line, 36);
			if($ac !~ /\-/) {
				$entryAC =(split(/\"/, $ac))[1];
			}
			$memberStart = 0;
		}
	}
	elsif($line =~ /^\<property type=\"NCBI taxonomy\" value=\"/) {
		$tax = substr($line, 31);
		$taxId =(split(/\"/, $tax))[1];
		if($uniRefId && $entryAC && $taxId) {
			@upIds = split(/\;/, $acToUPs{$entryAC});
                        foreach(@upIds) {
				my $upId = $_;
                        	my $upIdAndTaxId = $upId."\t".$taxId;
				if($proteomesHash{$upIdAndTaxId}) {
                        		print "upIdAndTaxId:  $upIdAndTaxId"."\t".$entryAC."\t".$uniRefId."\n";
					$upIdAndTaxHash{$upIdAndTaxId} = 1;
					#if($proteomeEntryHash{$upIdAndTaxId}{$entryAC}) {
						$uniRef50Key = $entryAC."-".$upIdAndTaxId."-".$uniRefId;
						$uniRef50Str = $entryAC."\t".$upId."\t".$taxId."\t".$uniRefId;
						$uniRef50Hash{$uniRef50Key} = $uniRef50Str;
					#}
				}
			}
			$entryAC = "";
			$taxId = "";
		}
	}
}
close(UNIREF);
print "UniRef50 hash: ".keys(%uniRef50Hash)."\n";
open(UNIREFDAT, ">", "../data/uniref50_ALL.dat");
foreach my $key (sort keys %uniRef50Hash) {
	print UNIREFDAT $uniRef50Hash{$key}."\n"; 
}
close(UNIREFDAT);

print "TotalProteomesUniRef50: ".keys(%upIdAndTaxHash)."\n"; 
