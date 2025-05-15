#!/usr/bin/perl

#use strict;

my %proteomeHosts = ();

#$tremblViruses = "../data/uniprot_sprot_viruses.dat.gz ../data/uniprot_trembl_viruses.dat.gz";
$tremblViruses = "../data/uniprot_sprot.dat ../data/uniprot_trembl.dat";
#open(TV, "gunzip -c $tremblViruses |") || die "can't open pipe to $tremblViruses\n";
open(TV, "cat $tremblViruses |") || die "can't open pipe to $tremblViruses\n";
while($line=<TV>) {
	#print $line;
	chomp($line);
	if($line =~ /^ID   /) {
		$virusTaxId = "";
		$hostTaxIds = "";
		$hostName = "";
		$proteomeIds = "";
	}
	# OX   NCBI_TaxID=341980 {ECO:0000313|Proteomes:UP000008504};
	elsif($line =~ /^OX/) {
		my @ox = split(/\s+/, $line);
		$virusTaxId = $ox[1];
		$virusTaxId =~ s/NCBI_TaxID=//;
		$virusTaxId =~ s/\;$//;
	}
	elsif ($line =~ /^OC   /) {
		if(!$lineage) {
			$lineage = substr($line, 5);
		}
		else {
                	$lineage .= " ".substr($line, 5);
		}
		#print "|$lineage|\n";
        }

	#4806:OH   NCBI_TaxID=8782; Aves.
	#4807:OH   NCBI_TaxID=9606; Homo sapiens (Human).
	elsif($line =~ /^OH/) {
		my @oh = split(/\;\s+/, $line, 2);
		$hostId = $oh[0];
		$hostId =~ s/OH   NCBI_TaxID=//;
		if($hostTaxIds) {
			$hostTaxIds .=";".$hostId;
		}
		else {
			$hostTaxIds = $hostId;
		}
		$hostNameStr = $oh[1];
		if($hostNameStr =~ /\(/) {
			my ($hostName) = (split(/\s+\(/, $hostNameStr))[0];
			$hostIdToName{$hostId} = $hostName;
		}
		else {
			$hostName = $hostNameStr;
			$hostName =~ s/\.$//;
			$hostIdToName{$hostId} = $hostName;
		}  	
	}
	#22971:DR   Proteomes; UP000008504; Genome.
	#22972:DR   Proteomes; UP000008506; Genome.
	elsif($line =~ /^DR   Proteomes/) {
		($upId) = (split(/\;\s+/, $line))[1];
		if($proteomeIds) {
			$proteomeIds.=";".$upId;
		}
		else {
			$proteomeIds = $upId;
		}
	}	
	elsif($line =~ /^\/\//) {
		if($proteomeIds && $hostTaxIds && $lineage =~ /^Viruses\;/) {
			#print $proteomeIds."??\n";
			my @proteomes = split(/\;/, $proteomeIds);
			my @hosts = split(/\;/, $hostTaxIds);
			foreach my $proteome (@proteomes) {
				foreach my $host (@hosts) {
					$proteomeHosts{$proteome."\t".$virusTaxId}{$host} = 1;
					#print $proteome."\t".$host."??\n";
				}
			}		
		}
		$lineage = "";			
	}	
}
close(TV);

#for $family ( keys %HoH ) {
#    print "$family: ";
#        for $role ( keys %{ $HoH{$family} } ) {
#                 print "$role=$HoH{$family}{$role} ";
#                     }
#                         print "\n";
#                         }
for $proteome (sort keys %proteomeHosts) {
	print $proteome."\t";
	#my $proteomeHostsRef = $proteomeHosts{$proteome};
	#my %proteomeHostsH = %$proteomeHostsRef;
	my $hostNames = "";	
	my $hostTaxIds = "";
	for $hostTaxId (keys %{ $proteomeHosts{$proteome} }) {
		$hostName = $hostIdToName{$hostTaxId};
		if($hostNames) {
			$hostNames .= ";".$hostName;
		}
		else {
			$hostNames = $hostName;
		}
		if($hostTaxIds) {
			$hostTaxIds.=";".$hostTaxId;
		}
		else {
			$hostTaxIds = $hostTaxId;
		}	
	}
	print $hostNames."\t".$hostTaxIds."\n";		
}


