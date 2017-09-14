package Capability::TextClustering;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Name Engine /

  ];

sub init {
  my ($self,%args) = @_;
  my $name = $args{EngineName} || "OSKM";
  $self->Name($name);
  require "Capability/TextClustering/Engine/$name.pm";
  $self->Engine("Capability::TextClustering::Engine::$name"->new());
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

sub AddTexts {
  my ($self,%args) = @_;
  $self->Engine->AddTexts(%args);
}

sub GetClusters {
  my ($self,%args) = @_;
  $self->Engine->GetClusters(%args);
}

# sub TextClustering {
#   my ($self,%args) = @_;
#   return $self->Engine->TextClustering(Text => $args{Text});
# }

# sub TextClusteringExtract {
#   my ($self,%args) = @_;
#   return $self->Engine->TextClusteringExtract(Text => $args{Text});
# }

1;
