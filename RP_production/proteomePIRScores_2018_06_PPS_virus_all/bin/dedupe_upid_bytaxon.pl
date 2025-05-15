#!/usr/bin/perl
#cd /data/wangy/RPS/2016/test
#perl dedupe_upid_bytaxon.pl ../data/score/proteomeScores.txt ../data/runningRP95.txt ../data/runningProteomesScoreHash95.txt ../data/failsafe.list> this.log
#perl dedupe_upid_bytaxon.pl ../data/score/proteomeScores.txt ../data/sample.txt ../data/runningProteomesScoreHash95.txt > dedupe_info.txt
#preserve backup_files
$retval=`date +%s`; chomp($retval);
`cp $ARGV[1] $ARGV[1].backup_$retval`;
`cp $ARGV[2] $ARGV[2].backup_$retval`;
#readin source file
my $file_to_open;
$file_to_open=$ARGV[0];
open(PSCORE, "<", $file_to_open) or die "Can't open $file_to_open\n";
$file_to_open=$ARGV[1];
open(SRC1, "<", $file_to_open) or die "Can't open $file_to_open\n";
$file_to_open=$ARGV[2];
open(SRC2, "<", $file_to_open) or die "Can't open $file_to_open\n";
$file_to_open=$ARGV[3];
open(LIST, "<", $file_to_open) or die "Can't open $file_to_open\n";
#write to output file
$file_to_open="../data/dedupe.chk.log";
open(CHK, ">", $file_to_open) or die "Can't write $file_to_open\n";
$file_to_open="$ARGV[1].reped";
open(DST0, ">", $file_to_open) or die "Can't write $file_to_open\n";
$file_to_open="$ARGV[1].fixed";
open(DST1, ">", $file_to_open) or die "Can't write $file_to_open\n";
$file_to_open="$ARGV[2].fixed";
open(DST2, ">", $file_to_open) or die "Can't write $file_to_open\n";
$file_to_open="../data/dedupe_info.txt";
open(INFO, ">", $file_to_open) or die "Can't write $file_to_open\n";
my $upid="";
my $taxid="";
my $tmpstr="";
my @tmparr=();
my %tax2list=();
my %taxonlist=();
#-------------------------------------------
print "Filtering proteome score ...\n";
#UP000000204     1221877 0       0       0       19111.0089126749        956     19.9905950969402
my $tnum=0;
my $prp=0;
my $bestnum=0;
my %taxon2bestup=();
my %hashdupe=(); 
$cnt=0;
#$line=<PSCORE>; #print $line; #remove header
while($line=<PSCORE>){	chomp($line);
	if($line=~/^(UP00[0-9]+)\s+/){ $cnt++;
		$upid=$1; #next if (!defined  $upid2tax{$upid});
		@tmparr=split("\t",$line);	$taxon=$tmparr[1];
		#next if (!defined  $tax2upid{$taxon});
		$tnum=$tmparr[5];$prp=0;$prp=1 if($tmparr[9]=~/PrevRP/);
		my $tmpscore=$prp*10000000+$tnum;
		$upid2score{$upid}=$tmpscore;
		$upid2taxon{$upid}=$taxon;
		#print "$upid|$taxon|\$tmpscore=$prp*10000000+$tnum;$tmpscore\n";
	}
}
print "$cnt upids had scores\n";
#-------------------------------------------
print "pre-read 95 score txt (for compare) ...\n";
#UP000008520-420890      UP000008520-420890;
$cnt=0;
while($line=<SRC1>){	chomp($line);
	#if($line=~/^(UP00[0-9]+)\-([0-9]+)\s+(.*)$/){
	if($line=~/^(UP00[0-9]+)\-([0-9]+)\s+(\S*)\s*(UP00[0-9]+)\-([0-9]+)$/){
		$seed=$1; $seedtax=$2; $members=$3; $upid=$4; $taxid=$5; $upid2mems{$upid}=$members;
		$upid2seed{$upid}=$seed; #will use scores of rep to compare quality of proteomes
		#print "\$seed=$1; \$seedtax=$2; \$members=$3; \$upid=$4; \$taxid=$5;\n";
		if(defined $upid2taxon{$upid} && $upid2taxon{$upid} eq $taxid){ #good entry
			#print "checking \$upid=$1; \$taxid=$2;\n";
			if(!defined $tax2best{$taxid}){
				$tax2best{$taxid}="$upid";
				$tax2removal{$taxid}="";
			}else{ #replace best, add dupe list
				$oldupid=$tax2best{$taxid};
				$oldscore=$upid2score{$oldupid}; #use score of the rep
				$newscore=$upid2score{$upid};
				#print "dupe $taxid with \$upid=$upid|$newscore; \$oldupid=$oldupid|$oldscore\n";
				#print "removal=$tax2removal{$taxid}\n";
				if($oldscore>=$newscore){ #preserve, new upid go to trash
					$tax2removal{$taxid}.=";$upid";
				}else{ #replace, old upid go trash
					$tax2best{$taxid}="$upid";
					$tax2removal{$taxid}.=";$oldupid";
				}
				#print "$line\n\tUpdate|$taxid| best=|$tax2best{$taxid}| removal=$tax2removal{$taxid}\n";
				#print "removal=$tax2removal{$taxid}\n";
			}
		}else{ #sth wrong:
			print "ERROR:Entry $upid mismatch with taxon; $upid2taxon{$upid}|$taxid\n";
			$cnt++;
		}
	}
}
print "$cnt Errors of taxon mismatch\n";
my $cnt=0; my $cnt1=0;
my %upid2tax=(); 
while(my ($tax,$removal) = each %tax2removal){
	#print "EXAM:$tax,$removal\n";
	next if $removal eq "";
	$removal=~s/^;//;
	@tmparr=split(";",$removal);
	$num=$#tmparr+2;
	print INFO "$num\t$tax\t$tax2best{$tax}\t$removal\n";
	$tmpkey=$tax2best{$tax}; 
	$tax2upid{$tax}=$tmpkey; #record for this tax should check
	#print "\n$num\t$tax\t$tmpkey\t$upid2score{$tmpkey}\n";
	$toaddback_removal="";
	foreach my $tmpkey_rep (@tmparr){ #record upid to delete
		$tmpkey=$upid2seed{$tmpkey_rep};
		$hashdupe{$tmpkey}=$tax; $cnt1++;
		#print "\t$tmpkey\t$upid2score{$tmpkey}\n";
		$toaddback_removal.=";$upid2mems{$tmpkey_rep}";
	}
	$cnt++;
	#added to add back
	$tmpkey_rep=$tax2best{$tax}; 
	$tmpkey=$upid2seed{$tmpkey_rep};
	if(!defined $best2resume{$tmpkey}){ #correct case
		$best2resume{$tmpkey}=$toaddback_removal;
	}else{
		print "ERROR: multiple removal for TAX=$tax, BEST=$tmpkey, $best2resume{$tmpkey}=>$removal\n";
	}
}
# finished hashing
print "$cnt taxons checked with duplications\n\n";
print "$cnt1 entries removed\n";
$file_to_open=$ARGV[1];
close SRC1; # reopen for process
open(SRC1, "<", $file_to_open) or die "Can't open $file_to_open\n";
#-------------------------------------------
print "processing 95 score txt ...\n";
#UP000008520-420890      UP000008520-420890;
$cnt=0; $cntabk=0;
while($line=<SRC1>){	chomp($line);
	#if($line=~/^(UP00[0-9]+)\-([0-9]+)\s+(\S*)\s*/){
	if($line=~/^(UP00[0-9]+)\-([0-9]+)\s+(\S*)\s*(UP00[0-9]+)\-([0-9]+)/){
		$upid=$1; $taxon=$2;	$members=$3;	$rep_id=$4; $rep_taxon=$5;
		#if(defined $hashdupe{$upid} && $hashdupe{$upid} eq $taxon){
		if(defined $hashdupe{$upid} && $hashdupe{$upid} eq $rep_taxon){
			#print "Removed:|$line\n"; $cnt++;
		}else{
			if(defined $best2resume{$upid}){ $cntabk++;	#add patches back for removed RP
				$removal=$best2resume{$upid};
				$removal=~s/^;//; $removal=~s/;;/;/g; 
				#print "ADDING BACK: $upid-$taxon|$removal\n";
				print DST0 "$upid\-$taxon\t$members$removal\n"; 
				$upid2rmhash2{$upid}="$members$removal";
			}else{
				print DST0 "$upid\-$taxon\t$members\n";
				$upid2rmhash2{$upid}="$members";
			}
			#check if duplicate seed id still existed		
			$best_score=$upid2score{$rep_id}; $duped_seedscore{$upid}=$best_score; #record score of this seed's rep, now we are comparing seed
			if(!defined $duped_seedtax{$taxon}){ #record this tax to be dupilcated in remaining lines
				$duped_seedtax{$taxon}="$upid";				
				$duped_ndex_best{$taxon}=$best_score;
				$duped_ndex_bestid{$taxon}=$upid;
			}else{ # duplicate really happens
				$duped_seedtax{$taxon}.=";$upid"; # the list of duplicated entries
				if($duped_ndex_best{$taxon} < $best_score){
					$duped_ndex_best{$taxon}=$best_score;
					$duped_ndex_bestid{$taxon}=$upid;
				}				
				$duped_ndex{$taxon}=$best_score;
			}
		}
	}
}	
print "$cnt entries removed from runningRP95.txt\n";
print "\tadded back to $cntabk taxons\n";
$file_to_open=$ARGV[1];
close SRC1; # reopen for process
open(SRC1, "<", $file_to_open) or die "Can't open $file_to_open\n";
#-------------------------------------------
while($line=<LIST>){	chomp($line);
	if($line=~/(\d+)/){
		$taxon=$1;		$taxon2fail{$taxon}=$taxon;
		print "failsafe $taxon;\n";
	}
}
#process duped seed list to add more hash dupe
while(my ($taxon,$score) = each %duped_ndex){
	$best_score = $duped_ndex_best{$taxon};
	$best_id = $duped_ndex_bestid{$taxon};
	$id_list = $duped_seedtax{$taxon};
	$outstr=">$taxon BEST_SEED=$best_id REP_SCORE=$best_score\n$duped_seedtax{$taxon}\n";
	print CHK $outstr;
	next if(!defined $taxon2fail{$taxon}); #let go if not causing problem
	print CHK "---- Collapsing $taxon due to list ---- \n";
	my @arr=split(/;/,$id_list);
	foreach my $id (@arr){
		if($id eq $best_id){ # keep this
			print CHK "$id\tkept\t$duped_seedscore{$id}\n";			
			#$best2resume{$best_id}=""; #no add for myself
		}else{ #add to hashdupe, and hash removal again
			$hashdupe{$id}=$taxon;			
			print CHK "$id\trmed\t$duped_seedscore{$id}\n";
			$best2resume{$best_id}.=$upid2rmhash2{$id}; #add for removed
			#print "\$best2resume{$best_id}.=$upid2rmhash2{$id};\n";
		}
	}
}
#now re-open partly processed file to see if 
print "================Testing Point=============\n";
$cnt=0; $cntabk=0;
while($line=<SRC1>){	chomp($line);
	if($line=~/^(UP00[0-9]+)\-([0-9]+)\s+(\S*)\s*(UP00[0-9]+)\-([0-9]+)/){
		$upid=$1; $taxon=$2;	$members=$3;	$rep_taxon=$5;
		#if(defined $hashdupe{$upid} && $hashdupe{$upid} eq $rep_taxon){
		if(defined $hashdupe{$upid}){ $cnt++;
		}else{				
			if(defined $best2resume{$upid}){	$cntabk++; #add patches back for removed RP
				$removal=$best2resume{$upid};
				$removal=~s/^;//; $removal=~s/;;/;/g; 
				#if($upid eq "UP000144986"){				print "REM=$removal\n";			}
				print DST1 "$upid\-$taxon\t$members$removal\n"; 
			}else{
				#if($upid eq "UP000144986"){				print "REM=WRONG\n";			}
				print DST1 "$upid\-$taxon\t$members\n";				
			}
		}
	}
}
print "$cnt entries removed in second round from runningRP95.txt\n";
print "\tadded back to $cntabk taxons\n";
#-------------------------------------------
print "processing 95 hashing score txt ...\n";
#11105780955780.UP000007477-871585       UP000007477-871585
$cnt=0;
while($line=<SRC2>){	chomp($line);
	if($line=~/^[0-9]+\.(UP00[0-9]+)\-([0-9]+)\s+/){
		$upid=$1; $taxon=$2;
		#if(defined $hashdupe{$upid} && $hashdupe{$upid} eq $taxon){
		if(defined $hashdupe{$upid}){	$cnt++;
			#print "Removed:|$line\n"; $cnt++;
		}else{
			print DST2 "$line\n";
		}
	}
}	
print "$cnt entries removed from runningProteomesScoreHash95.txt\n";
