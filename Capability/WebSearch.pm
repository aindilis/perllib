package Capability::WebSearch;

# see Capability::WebSearch::Engine::DuckDuckGo
# see Capability::WebSearch::Engine::Google

# see Capability::WebSearch::Method::WWWMechanizeFirefox

# see System::WWW::Firefox

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Name Engine /

  ];

sub init {
  my ($self,%args) = @_;
  my $name = $args{EngineName} || "Google";
  $self->Name($name);
  require "Capability/WebSearch/Engine/$name.pm";
  # Capability::WebSearch::Engine::Google
  # Capability::WebSearch::Engine::DuckDuckGo
  $self->Engine
    ("Capability::WebSearch::Engine::$name"->new
     (
      ViewHeadless => $args{ViewHeadless},
      Method => $args{Method},
     ));
  $self->StartServer;
  $self->StartClient;
  print "Done Initializing Capability::WebSearch\n";
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
  return $self->Engine->WebSearch(%args);
}

1;
