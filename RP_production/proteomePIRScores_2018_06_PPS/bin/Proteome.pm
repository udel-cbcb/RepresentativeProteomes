#!/usr/bin/perl

package Proteome;
use UniRef50;

sub new {
	my $class = shift;
	my $self = {
		_upIdAndTaxId => shift,
		_upId => shift,
		_taxId => shift,
		_mnemonic => shift,
		_scientificName => shift,
		_lineage => shift,
		_uniRef50s => shift,
	};
	$self->{_score} = 0;
	$self->{_scoreSum} = 0;
	$self->{_memberCount} = 0;
	$self->{_entryTotal} = 0;
	$self->{_members} = undef;
	$self->{_panMembers} = undef;
	bless $self, $class;
	return $self;
}
sub setUPIdAndTaxId {
	my ( $self, $upIdAndTaxId ) = @_;
	$self->{_upIdAndTaxId} = $upIdAndTaxId if defined ($upIdAndTaxId);
	return $self->{_upIdAndTaxId};
}

sub getUPIdAndTaxId {
	my ( $self ) = @_;
	return $self->{_upIdAndTaxId};
}

sub setUPId {
	my ( $self, $upId ) = @_;
	$self->{_upId} = $upId if defined ($upId);
	return $self->{_upId};
}

sub getUPId {
	my ( $self ) = @_;
	return $self->{_upId};
}

sub setTaxId {
	my ( $self, $taxId ) = @_;
	$self->{_taxId} = $taxId if defined ($taxId);
	return $self->{_taxId};
}

sub getTaxId {
	my ( $self ) = @_;
	return $self->{_taxId};
}

sub setMnemonic {
	my ( $self, $mnemonic ) = @_;
	$self->{_mnemonic} = $mnemonic if defined ($mnemonic);
	return $self->{_mnemonic};
}

sub getMnemonic {
	my ( $self ) = @_;
	return $self->{_mnemonic};
}

sub setScientificName {
	my ( $self, $scientificName ) = @_;
	$self->{_scientificName} = $scientificName if defined ($scientificName);
	return $self->{_scientificName};
}

sub getScientificName {
	my ( $self ) = @_;
	return $self->{_scientificName};
}

sub setLineage {
	my ( $self, $lineage ) = @_;
	$self->{_lineage} = $lineage if defined ($lineage);
	return $self->{_lineage};
}

sub getLineage {
	my ( $self ) = @_;
	return $self->{_lineage};
}

sub setUniRef50s {
	my ( $self, $uniRef50s ) = @_;
	$self->{_uniRef50s} = $uniRef50s if defined ($uniRef50s);
	return $self->{_uniRef50s};
}

sub getUniRef50s {
	my ( $self ) = @_;
	return $self->{_uniRef50s};
}

sub setMembers {
	my ( $self, $members ) = @_;
	$self->{_members} = $members if defined ($members);
	return $self->{_members};
}

sub getMembers {
	my ( $self ) = @_;
	return $self->{_members};
}

sub setEntryTotal {
	my ( $self, $entryTotal ) = @_;
	$self->{_entryTotal} = $entryTotal if defined ($entryTotal);
	return $self->{_entryTotal};
}

sub getEntryTotal {
	my ( $self ) = @_;
	return $self->{_entryTotal};
}

sub setPanMembers {
	my ( $self, $panMembers ) = @_;
	$self->{_panMembers} = $panMembers if defined ($panMembers);
	return $self->{_panMembers};
}

sub getPanMembers {
	my ( $self ) = @_;
	return $self->{_panMembers};
}

sub setMemberCount {
	my ( $self, $memberCount ) = @_;
	$self->{_memberCount} = $memberCount if defined ($memberCount);
	return $self->{_memberCount};
}

sub getMemberCount {
	my ( $self ) = @_;
	return $self->{_memberCount};
}

sub setScoreSum {
	my ( $self, $scoreSum ) = @_;
	$self->{_scoreSum} = $scoreSum if defined ($scoreSum);
	return $self->{_scoreSum};
}

sub getScoreSum {
	my ( $self ) = @_;
	return $self->{_scoreSum};
}

sub getPmidScore {
	my ( $self ) = @_;
	my $pmidScore = 0;
	my $membersHashRef = $self->{_members};
	my %membersHash = %$membersHashRef;
	foreach(keys %membersHash) {
		my $member = $membersHash{$_};
		$pmidScore += $member->getPmidScore(); 
	}
	return $pmidScore;
}

sub getPdbScore {
	my ( $self ) = @_;
	my $pdbScore = 0;
	my $membersHashRef = $self->{_members};
	my %membersHash = %$membersHashRef;
	foreach(keys %membersHash) {
		my $member = $membersHash{$_};
		$pdbScore += $member->getPdbScore(); 
	}
	return $pdbScore;
}

sub getSpScore {
	my ( $self ) = @_;
	my $spScore = 0;
	my $membersHashRef = $self->{_members};
	my %membersHash = %$membersHashRef;
	foreach(keys %membersHash) {
		my $member = $membersHash{$_};
		$spScore += $member->getSpScore(); 
	}
	return $spScore;
}

sub mergeMembers1 {
	#print "!!!\n";
	my %merged;
	my $uniRef50sRef = $self->{_uniRef50s};
	my %uniRef50s = %$uniRef50sRef;
	#print "Size: ".(keys %uniRef50s)."\n";
	foreach(keys %uniRef50s) {
		print "???\n";
		my $uniRef50Ref = $uniRef50s{$_};
		print $_."\t".$unRef50Ref->toString()."\n";
		my $uniRefMembersRef = %$uniRef50Ref->getMembers;
		my %uniRefMembers = %$uniRefMembersRef;
		foreach my $k(keys %uniRefMembers) {
			$merged{$k} = $uniRefMembers{$k};
		}	
	}
	$self->{_members} = \%merged;
	return $self->{_members};	
}

sub computeScore {
	my ( $self ) = @_;
	my $count = 0.0;
	$self->mergeMembers();	
	my $membersHashRef = $self->{_members};
	my %membersHash = %$membersHashRef;
	$count = keys %membersHash;  
	#print "count: ".$count."\n";	
	$score = 0.0;
	if($count ne 0) {
		foreach(keys %membersHash) {
			my $memberScore = $membersHash{$_};
			#print $member->getScore()."\n";
			$score += $memberScore;	
		}		
		$self->{_score} = $score/$count;
	}
	return $self->{_score};
}

sub getScore {
	my ( $self ) = @_;
	return $self->{_score};
}

sub setScore {
	my ( $self, $score ) = @_;
	$self->{_score} = $score if defined ($score);
	return $self->{_score};
}

sub toString {
	my ( $self ) = @_;
	my $uniRef50sRef = $self->{_uniRef50s};
	my %uniRef50s = %$uniRef50sRef;
	$count = keys %uniRef50s;
	print "\n************************\n";  
	print "Proteome: ".$self->{_taxId}."\n";		
	print "Mnemonic: ".$self->{_mnemonic}."\n";		
	print "ScientificName: ".$self->{_scientificName}."\n";		
	print "Lineage: ".$self->{_lineage}."\n";		
	print "Score: ".$self->getScore()."\n";		
	print "UniRef50s: ".$count."\n";
	foreach(keys %uniRef50s) {
		my $uniRef50 = $uniRef50s{$_};
		$uniRef50->toString();
	}
}

sub createReportEntry {
	my ( $self ) = @_;
	print $self->{_taxId}."^|^";		
	print $self->getScore()."^|^";		
	print $self->{_mnemonic}."^|^";		
	print $self->{_scientificName}."^|^";		
	print $self->{_lineage}."^|^";		
}

sub mergeMembers {
	my ( $self ) = @_;
	my $uniRef50sRef = $self->{_uniRef50s};
	my %uniRef50s = %$uniRef50sRef;
	$count = keys %uniRef50s;
	#print "UniRef50s: ".$count."\n";
	my %merged=();
	foreach(keys %uniRef50s) {
		my $uniRef50 = $uniRef50s{$_};
		my $membersHashRef = $uniRef50->{_members};
       		my %membersHash = %$membersHashRef;
        	foreach(keys %membersHash) {
                	my $member = $membersHash{$_};
                	$merged{$member->getAC()} = $member;
        	}
	}
	$self->{_members}= \%merged;
	return $self->{_members};
}

1;
