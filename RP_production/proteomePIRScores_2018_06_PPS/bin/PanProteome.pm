#!/usr/bin/perl

package PanProteome;
use Proteome;
our @ISA = qw(Proteome);    # inherits from Proteome

# Override constructor
sub new {
	my ( $class ) = @_;
	
	# Call the constructor of the parent class, Proteome
	my $self = $class->SUPER::new( $_[1], $_[2], $_[3] );
	# Add few more attributes
	$self->{_orphans} = undef;
	bless $self, $class;
	return $self;
}

sub setOrphans {
 	my ( $self, $orphans ) = @_;
	if(defined($orphans)) {
		$self->{_orphans} = $orphans;
        	my $orphansHashRef = $self->{_orphans};
		my %orphansHash = %$orphansHashRef;
		foreach(keys %orphansHash) {
			my $orphan = $orphansHash{$_};
			#$self->addMember($orphan);
		}
	}
	return $self->{_orphans};

}

sub getOrphans {
	my ( $self ) = @_;
	return $self->{_orphans};
}

sub addOrphan { 
        my ( $self, $orphan ) = @_;
        my $orphansHashRef = $self->{_orphans};
	my %orphansHash = %$orphansHashRef;
        if(defined($orphan)) {
                $orphansHash{$orphan->getAC()} = $orphan;
	}
	$self->{_orphans} = \%orphansHash;
	return $self->{_orphans};
}														

1;
