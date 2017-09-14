package Capability::NER::Engine::NamedEntity;

use Lingua::EN::NamedEntity;

use Data::Dumper;
use Net::Telnet;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / /

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

sub NER {
  my ($self,%args) = @_;
  return [extract_entities($args{Text})];
}

sub DESTROY {
  my ($self,%args) = @_;
}

1;

