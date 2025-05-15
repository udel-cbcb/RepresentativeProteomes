$taxtb = "../data/new_nih_taxID_parenttaxID_table";
open(IN, $taxtb);
while($line = <IN>) {
        chop $line;
        $line=~s/ /:/;
	$line=~s/ /:/;
        ($a,$b,$c)= (split /:/, $line)[0,1,2];
        $pid{$a} = $b;
        $type{$a} =$c;
}
close IN;


open(IN, $taxtb);
while($line = <IN>) {
        chop $line;
        $line=~s/ /:/;
        $line=~s/ /:/;
        ($a,$b,$c)= (split /:/, $line)[0,1,2];
	$record{$a} = $line;
        if ($c eq "species") { $species{$a} = $a;}
        elsif ($a eq "1") {  $species{$a} = "na";}
         else {  $x=$a;
           while( $type{$x} ne "species") { 
             if ($pid{$x} eq "1") { last;}
             elsif ($pid{$x}) {$x=$pid{$x};}
             else {last;}
	     }
           if ($type{$x} eq "species") { $species{$a} = $x;}
           else {  $species{$a} = "na";}
           }
	
        if ($c eq "genus") { $genus{$a} = $a;}
        elsif ($a eq "1") {  $genus{$a} = "na";}
         else {  $y=$a;
           while( $type{$y} ne "genus") { 
             if ($pid{$y} eq "1") { last;}
             elsif ($pid{$y}) {$y=$pid{$y};}
             else {last;}
	     }
           if ($type{$y} eq "genus") { $genus{$a} = $y;}
           else {  $genus{$a} = "na";}
	}

        if ($c eq "class") { $class{$a} = $a;}
        elsif ($a eq "1") {  $class{$a} = "na";}
         else {  $z=$a;
           while( $type{$z} ne "class") { 
             if ($pid{$z} eq "1") { last;}
             elsif ($pid{$z}) {$z=$pid{$z};}
             else {last;}
	     }
           if ($type{$z} eq "class") { $class{$a} = $z;}
           else {  $class{$a} = "na";}
	}
        if ($c eq "phylum") { $phylum{$a} = $a;}
        elsif ($a eq "1") {  $phylum{$a} = "na";}
         else {  $w=$a;
           while( $type{$w} ne "phylum") { 
             if ($pid{$w} eq "1") { last;}
             elsif ($pid{$w}) {$w=$pid{$w};}
             else {last;}
	     }
           if ($type{$w} eq "phylum") { $phylum{$a} = $w;}
           else {  $phylum{$a} = "na";}
	}
}

my %taxToUP = ();
open(TAXTOUP, "../data/taxIdToUPIdMapping.txt") or die "Can't open ../data/taxIdToUPIdMapping.txt\n";
while($line=<TAXTOUP>) {
	chomp($line);
	($taxId, $upId) = (split(/\t/, $line))[0, 1];
	if(!$taxToUP{$taxId}) {
		$taxToUP{$taxId} = $upId;
	}
	else {
		$taxToUP{$taxId} .= ";".$upId;
	}
}


for $taxId (keys %taxToUP) {
	#print $taxId."|".$taxToUP{$taxId}."\n";
}

for my $k (keys %record) {
	#print $k."|".$record{$k}."|\n";
	#($taxId, $pid, $species) = (split(/\:/, $record{$k}))[0, 1,2];
	my @rec = split(/\;/, $taxToUP{$k});
	#print "?".$record{$k}."?:".$species{$k}.":".$genus{$k}.":".$class{$k}.":".$phylum{$k}."\n";
	foreach(@rec) {		
		print $_."-".$record{$k}.":".$species{$k}.":".$genus{$k}.":".$class{$k}.":".$phylum{$k}."\n";
	}
}
