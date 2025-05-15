#!/usr/bin/perl

package RPG;

sub new {
	my $class = shift;
	my $self = {
		_percent => shift,
		_proteomes => shift,
	};
	
	# Print all the values just for clarification
	bless $self, $class;
	return $self;
}

sub setPercent {
	my ( $self, $percent ) = @_;
	$self->{_percent} = $percent if defined ($percent);
	return $self->{_percent};
}

sub getPercent {
	my ( $self ) = @_;
	return $self->{_percent};
}

sub setProteomes {
	my ( $self, $proteomes ) = @_;
	$self->{_proteomes} = $proteomes if defined ($proteomes);
	return $self->{_proteomes};
}

sub getProteomes {
	my ( $self ) = @_;
	return $self->{_proteomes};
}

sub toString {
        my ( $self ) = @_;
	my $proteomesRef = $self->{_proteomes};
	my @proteomes = @$proteomesRef;
	my $size = @proteomes;
	#print "size: ".$size."\n";
	my $rp = $proteomes[0];
	print ">".$rp->getTaxId()."\t".$rp->getMnemonic()."\t".$self->getPercent()."\t".$rp->getScore()."\t".$rp->getScientificName()."\t".$rp->getLineage()."\n"; 
	for($i = 1; $i < $size; $i++) {
		my $proteome = $proteomes[$i];
		print " ".$proteome->getTaxId()."\t".$proteome->getMnemonic()."\t".$self->getPercent()."\t".$proteome->getScore()."\t".$proteome->getScientificName()."\t".$proteome->getLineage()."\n"; 
	}
}


1;
