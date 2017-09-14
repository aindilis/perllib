package Rival::Symbol::Table::Package;

use Rival::Symbol::Table::Symbol;
@ISA = ('Rival::Symbol::Table::Symbol');

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [
   qw / Subpackages /
  ];

sub init {
  my ($self,%args) = @_;
  $self->Name($args{Name});
  $self->Package($args{Package});
  print "Initializing name: ".$self->Name."\n";
  $self->GetSubpackages;
}

sub GetSubpackages {
  my ($self,%args) = @_;
  $self->Subpackages({});
  my $name = $self->Name;
  foreach my $key (keys %$name) {
    if ($key =~ /::$/ and $key !~ /main::/) {
      print $key."\n";
      my $newname;
      if ($name ne "main::") {
	$newname = "$name$key";
      } else {
	$newname = $key;
      }
      if (1) {
	$self->Subpackages->{$key} =
	  Rival::Symbol::Table::Package->new
	      (
	       Name => $newname,
	       Package => $self,
	      );
      }
    } else {
      print "${name}$key\n";
    }
  }
}

1;
