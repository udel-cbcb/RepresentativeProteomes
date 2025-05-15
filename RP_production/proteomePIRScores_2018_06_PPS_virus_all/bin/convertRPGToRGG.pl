if(@ARGV != 2) { 
	print "Usage: perl convertRPGToRGG.pl rp2rgmapping.txt rpg.txt\n";
	exit 1;
}

#RefSeq project ID       Genome project ID       NCBI taxonomy ID        UniProt taxonomy ID     NCBI organism name      UniProtKB OS code       UniProt organism name
#59081   21101   394     394     Sinorhizobium fredii NGR234     RHISN   Rhizobium sp (strain NGR234).
#57645   51      882     882     Desulfovibrio vulgaris str. Hildenborough       DESVH   Desulfovibrio vulgaris (strain Hildenborough / ATCC 29579 / NCIMB 8303)

my %gp2rp = ();
my %gpInfo = ();

open(PG, $ARGV[0]) or die "Can't open $ARGV[0]\n";
while($line=<PG>) {
	chomp($line);
	($refSeqP_id, $gp_id, $ncbi_taxon_id, $uniprot_taxon_id, $ncbi_name) = (split(/\t/, $line))[0, 1, 2, 3, 4];
	$refSeq2rp{$uniprot_taxon_id} = $refSeqP_id;
	$gp2rp{$uniprot_taxon_id} = $gp_id;
	$gpInfo{$gp_id} = $ncbi_taxon_id."\t".$ncbi_name;	
} 
close(PG);

#chenc@glycine bin]$ grep 700015 ../data/RepGenome_2011_12-unix.txt 
#65787   42699   700015  700015  Coriobacterium glomerans PW2    CORGP   Coriobacterium glomerans (strain ATCC 49209 / DSM 20642 / JCM 10262 / PW2)

open(RP, $ARGV[1]) or die "Can't open $ARGV[1]\n";
while($line=<RP>) { 
	if($line =~ /^>/) {
		chomp($line);
		my ($upId, $uniprot_taxon_id, $uniprot_os_code, $uniprot_name, $taxon_group, $score, $cutoff, $refp) = (split(/\t/, $line))[0, 1, 2, 3, 4, 5, 6, 7];
		$upId =~ s/^>//;
		$gp_id = $gp2rp{$uniprot_taxon_id};
		$refSeq = $refSeq2rp{$uniprot_taxon_id};
		print ">".$upId."\t".$gp_id."\t".$refSeq."\t".$gpInfo{$gp_id}."\t".$uniprot_taxon_id."\t".$uniprot_os_code."\t".$uniprot_name."\t".$taxon_group."\t".$score."\t".$cutoff."\t".$refp."\n";	
	}
	elsif($line =~ /^ /) {
		chomp($line);
		my ($upId, $uniprot_taxon_id, $uniprot_os_code, $uniprot_name, $taxon_group, $score, $cutoff, $refp) = (split(/\t/, $line))[0, 1, 2, 3, 4, 5, 6, 7];
		$upId =~ s/^\s+//;
		$refSeq = $refSeq2rp{$uniprot_taxon_id};
		$gp_id = $gp2rp{$uniprot_taxon_id};
		print " ".$upId."\t".$gp_id."\t".$refSeq."\t".$gpInfo{$gp_id}."\t".$uniprot_taxon_id."\t".$uniprot_os_code."\t".$uniprot_name."\t".$taxon_group."\t".$score."\t".$cutoff."\t".$refp."\n";	
			
	}
	else {
		print $line;
	}
}
close(RP);
#


