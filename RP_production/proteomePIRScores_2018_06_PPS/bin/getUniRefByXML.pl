#!/usr/bin/perl 


#<entry id="UniRef50_P85491" updated="2010-02-09">
#<entry id="UniRef50_UPI000023F703" updated="2008-05-20">
#<property type="UniProtKB accession" value="Q5G619"/>
#<property type="NCBI taxonomy" value="3888"/>
#open(UNIREF, "<", "../data/uniref50.xml") or die "$!\n";
#gunzip -c /big/wangy/uniprot_data/curr_tmp/uniref50.xml.gz
#$uniref50GZfile = "/big/wangy/uniprot_data/curr_tmp/uniref50.xml.gz";
$uniref50GZfile = "../data/uniref100.xml.gz";
open(UNIREF, "gunzip -c $uniref50GZfile |") || die "can't open pipe to $uniref50GZfile\n";
while($line=<UNIREF>) {
	if($line =~ /^\<entry id=\"UniRef100_/) {
		if($line !~ /^\<entry id=\"UniRef100_UPI/) {
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
					if($proteomeEntryHash{$upIdAndTaxId}{$entryAC}) {
						$uniRef50Key = $entryAC."-".$upIdAndTaxId."-".$uniRefId;
						$uniRef50Str = $entryAC."\t".$upId."\t".$taxId."\t".$uniRefId;
						$uniRef50Hash{$uniRef50Key} = $uniRef50Str;
					}
				}
			}
			$entryAC = "";
			$taxId = "";
		}
	}
}
close(UNIREF);
print "UniRef50 hash: ".keys(%uniRef50Hash)."\n";
open(UNIREFDAT, ">", "../data/uniref50.dat");
foreach my $key (sort keys %uniRef50Hash) {
	print UNIREFDAT $uniRef50Hash{$key}."\n"; 
}
close(UNIREFDAT);

print "TotalProteomesUniRef50: ".keys(%upIdAndTaxHash)."\n"; 
