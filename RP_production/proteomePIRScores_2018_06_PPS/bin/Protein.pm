#!/usr/bin/perl

package Protein;

sub new {
	my $class = shift;
	my $self = {
		_ac => shift,
		#_pmidScore => shift,
		#_pdbScore => shift,
		#_spScore => shift,
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

sub setPmidScore {
	my ( $self, $pmidScore ) = @_;
	$self->{_pmidScore} = $pmidScore if defined ($pmidScore);
	return $self->{_pmidScore};
}

sub getPmidScore {
	my ( $self ) = @_;
	return $self->{_pmidScore};
}

sub setPdbScore {
	my ( $self, $pdbScore ) = @_;
	$self->{_pdbScore} = $pdbScore if defined ($pdbScore);
	return $self->{_pdbScore};
}

sub getPdbScore {
	my ( $self ) = @_;
	return $self->{_pdbScore};
}

sub setSpScore {
	my ( $self, $spScore ) = @_;
	$self->{_spScore} = $spScore if defined ($spScore);
	return $self->{_spScore};
}

sub getSpScore {
	my ( $self ) = @_;
	return $self->{_spScore};
}

sub getScore {
	my ( $self ) = @_;
	return $self->{_score};
}

sub setScore {
	my ( $self, $score ) = @_;
	return $self->{_score} = $score if defined ($score);
}

sub getIsSwissProt {
	my ( $self ) = @_;
	return $self->{_spScore};
}

sub toString {
        my ( $self ) = @_;
	print "\t\t\t".$self->{_ac}." (".$self->{_pmidScore}.", ".$self->{_pdbScore}.", ".$self->{_spScore}.")[".$self->getScore()."]\n";	
}

1;
