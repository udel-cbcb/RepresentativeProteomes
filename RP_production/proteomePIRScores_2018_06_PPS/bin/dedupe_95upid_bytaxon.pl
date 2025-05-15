#!/usr/bin/perl
#perl dedupe_95upid_bytaxon.pl ../results_corr_consist/75/rpg-75.txt ../data/score/proteomeScores.txt ../data/runningRP95.txt ../data/runningProteomesScoreHash95.txt
#perl dedupe_95upid_bytaxon.pl rpg-75.txt proteomeScores.txt runningRP95.txt runningProteomesScoreHash95.txt

#readin source file
my $file_to_open=$ARGV[0];
open(F75, "<", $file_to_open) or die "Can't open $file_to_open\n";
$file_to_open=$ARGV[1];
open(PSCORE, "<", $file_to_open) or die "Can't open $file_to_open\n";
$file_to_open=$ARGV[2];
open(SRC1, "<", $file_to_open) or die "Can't open $file_to_open\n";
$file_to_open=$ARGV[3];
open(SRC2, "<", $file_to_open) or die "Can't open $file_to_open\n";
#write to output file
$file_to_open="$ARGV[2].fixed";
open(DST1, ">", $file_to_open) or die "Can't write $file_to_open\n";
$file_to_open="$ARGV[3].fixed";
open(DST2, ">", $file_to_open) or die "Can't write $file_to_open\n";

my $upid="";
my $taxid="";
my $tmpstr="";
my @tmparr=();
my %tax2list=();
my %taxonlist=();
print "Filtering 75 File ...\n";
#>UP000000211    751945  THEOS   Thermus oshimai JL-2    Bac/Dein-Therm  27110.45455(PPS:0,1,1,10.38,2409)       75(CUTOFF)          100.00000(X-seed)

while($line=<F75>){	chomp($line);
	if($line=~/^>(UP00[0-9]+)\s+([0-9]+)\s+/){
		$upid=$1; $taxid=$2;
		if(!defined $tax2list{$taxid}){
			$tax2list{$taxid}="1:$upid;";
		}else{
			@tmparr=split("\:",$tax2list{$taxid});
			#print "\@tmparr=split(\":\",$tax2list{$taxid});\n";
			#print "0=$tmparr[0]; 1=$tmparr[1]; 2=$tmparr[2];\n";
			$tax2list{$taxid}=($tmparr[0]+1).":".$tmparr[1]."$upid;";
			$taxonlist{$taxid}=$tmparr[0]+1;
			#print "\$tax2list{$taxid}=($tmparr[0]+1).\":\".$tmparr[1].$upid;\n";
		}
	}else{
		#print "??$line\n";		
	}
}

my $cnt=0;
my %upid2tax=(); 
while(my ($tax,$num)=each %taxonlist){
	print "$num\t$tax\n";
	@tmparr=split(":",$tax2list{$tax});
	if($tmparr[0] != $num){
		print "\tERROR |$tmparr[0]| dupe listed in original\n";
	}else{	$cnt++;
		$tmpstr=$tmparr[1];
		@tmparr=split(";",$tmpstr);
		print "\t";
		for my $tmpkey (@tmparr){
			print "$tmpkey;";
			$upid2tax{$tmpkey}=$tax;
			$tax2upid{$tax}=$tmpkey;
		}
		print "\n";
	}
	
}
# finished hashing
print "$cnt taxons checked with duplications\n\n";
#while(my ($upid,$tax)=each %upid2tax){
#	print "$upid\t$tax\n";
#}
#-------------------------------------------
print "Filtering proteome score ...\n";
#UP000000204     1221877 0       0       0       19111.0089126749        956     19.9905950969402
my $tnum=0;
my $prp=0;
my $bestnum=0;
my %taxon2bestup=();
my %hashdupe=(); 
$cnt=0;
$line=<PSCORE>; #print $line; #remove header
while($line=<PSCORE>){	chomp($line);
	if($line=~/^(UP00[0-9]+)\s+/){
		$upid=$1; #next if (!defined  $upid2tax{$upid});
		@tmparr=split("\t",$line);	$taxon=$tmparr[1];
		next if (!defined  $tax2upid{$taxon});
		$tnum=$tmparr[6];$prp=0;$prp=1 if($tmparr[9]=~/PrevRP/);
		if(!defined $taxon2bestup{$taxon}){
			$taxon2bestup{$taxon}="$upid;$prp;$tnum";
		}else{ #store best key and hash removed key
			@tmparr=split(";",$taxon2bestup{$taxon});	
			my $tmpscore=$prp*10000000+$tnum;
			my $oldscore=$tmparr[1]*10000000+$tmparr[2];
			if($tmpscore>$oldscore){ #replace best
				$taxon2bestup{$taxon}="$upid;$prp;$tnum";
				$hashdupe{$tmparr[0]}=$taxon;
				print "$taxon\t$tmparr[0]\t$tmparr[2]\t$tmparr[1];\n";
			}else{ #keep old drop new
				$hashdupe{$upid}=$taxon;
				print "$taxon\t$upid\t$tnum\t$prp;\n";
			}
		}
	}
}

while(my ($upid,$taxon)=each %hashdupe){	$cnt++;
	@tmparr=split(";",$taxon2bestup{$taxon});	
	print "$upid,$taxon;$tmparr[0];$tmparr[2];$tmparr[1];\n";
}
print "$cnt upids to remove\n";


#-------------------------------------------
print "processing 95 score txt ...\n";
#UP000008520-420890      UP000008520-420890;
$cnt=0;

while($line=<SRC1>){	chomp($line);
	if($line=~/^(UP00[0-9]+)\-([0-9]+)\s+/){
		$upid=$1; $taxon=$2;
		if(defined $hashdupe{$upid} && $hashdupe{$upid} eq $taxon){
			print "Removed:|$line\n"; $cnt++;
		}else{
			print DST1 "$line\n";
		}
	}
}	
print "$cnt entries removed\n";

#-------------------------------------------
print "processing 95 hashing score txt ...\n";
#11105780955780.UP000007477-871585       UP000007477-871585
$cnt=0;

while($line=<SRC2>){	chomp($line);
	if($line=~/^[0-9]+\.(UP00[0-9]+)\-([0-9]+)\s+/){
		$upid=$1; $taxon=$2;
		if(defined $hashdupe{$upid} && $hashdupe{$upid} eq $taxon){
			print "Removed:|$line\n"; $cnt++;
		}else{
			print DST2 "$line\n";
		}
	}
}	
print "$cnt entries removed\n";
