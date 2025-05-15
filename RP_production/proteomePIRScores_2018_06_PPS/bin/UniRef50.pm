#!/usr/bin/perl

package UniRef50;

sub new {
	my $class = shift;
	my $self = {
		_ac => shift,
		_members => shift,
	};
	
	# Print all the values just for clarification
	bless $self, $class;
	return $self;
}



sub setAC {
	my ( $self, $ac ) = @_;
	$self->{_ac} = $ac if defined ($ac);
	return $self->{_ac};
}

sub getAC {
	my ( $self ) = @_;
	return $self->{_ac};
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

sub addMember {
        my ( $self, $member ) = @_;
        my $memberHashRef = $self->{_members};
        my %memberHash = %$memberHashRef;
        if(defined($member)) {
                $memberHash{$member->getAC()} = $member;
        }
        $self->{_members} = \%memberHash;
        return $self->{_members};
}

sub toString {
        my ( $self ) = @_;
	print "\t\tUniRef50: ".$self->{_ac}."\n";
        my $membersHashRef = $self->{_members};
        my %membersHash = %$membersHashRef;
        foreach(keys %membersHash) {
                my $score = $membersHash{$_};
                #$member->toString();
		print "\t\t$_\t$score\n";	
        }
}

1;
