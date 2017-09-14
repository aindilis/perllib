package Capability::WebSearch;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Name FireFox /

  ];

sub init {
  my ($self,%args) = @_;
  my $name = $args{EngineName} || "WWWMechanizeFirefox";
  $self->Name($name);
  require "Capability/WebSearch/Method/$name.pm";
  $self->Engine("Capability::WebSearch::Engine::$name"->new());
  $self->StartServer;
  $self->StartClient;
}

sub StartServer {
  my ($self,%args) = @_;
  $self->Engine->StartServer;
}

sub StartClient {
  my ($self,%args) = @_;
  $self->Engine->StartClient;
}

sub WebSearch {
  my ($self,%args) = @_;
  return $self->Engine->WebSearch(Search => $args{Search});
}

1;
