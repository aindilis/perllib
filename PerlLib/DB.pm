package PerlLib::DB;

use DBI;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw (GetAOH);

$VERSION = '1.00';
use strict;
use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / DB / ];

sub init {
  my ($self, @args) = (shift,@_);
  $self->DB(DBI->connect(@args));
}

sub GetAOH {
    my ($self,$query) = (shift,shift);
    my @matches = ();
    my $sth = $self->DB->prepare($query);
    $sth->execute();
    while (my $ref = $sth->fetchrow_hashref()) {
	push @matches, $ref;
    }
    $sth->finish();
    return \@matches;
}

1;
