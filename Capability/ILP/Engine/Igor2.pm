package Capability::ILP::Engine::Igor2;

# use Capability::ILP;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Engine /

  ];

sub init {
  my ($self,%args) = @_;
}

sub StartServer {
  my ($self,%args) = @_;
}

sub StartClient {
  my ($self,%args) = @_;
}

sub ProcessData {
  my ($self,%args) = @_;
}

1;
