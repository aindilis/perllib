package System::Rig;

# use PerlLib::Util;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / /

  ];

sub init {
  my ($self,%args) = @_;

}

sub GenerateIdentity {
  my ($self,%args) = @_;
  my $identity = `rig`;
  my @i = split /\n/, $identity;
  my $id = {};

  $id->{Name} = $i[0];
  if ($id->{Name} =~ /^(.*?)\s+(.*)$/) {
    $id->{FirstName} = $1;
    $id->{LastName} = $2;
  }
  $id->{StreetAddress} = $i[1];
  if ($id->{StreetAddress} =~ /^([0-9]+)\s+(.*)$/) {
    $id->{HouseNumber} = $1;
    $id->{Street} = $2;
  }
  $id->{CityAddress} = $i[2];
  if ($id->{CityAddress} =~ /^(.*?),\s+([A-Z]+)\s+([0-9]+)$/) {
    $id->{City} = $1;
    $id->{State} = $2;
    $id->{ZIP} = $3;
  }
  $id->{Phone} = $i[3];
  if ($id->{Phone} =~ /^\(([0-9]+)\)/) {
    $id->{AreaCode} = $1;
  }
  return $id;
}

1;
