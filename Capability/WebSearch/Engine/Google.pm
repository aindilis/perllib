package Capability::WebSearch::Engine::Google;

use Capability::WebSearch::Method::WWWMechanizeFirefox;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / WWWMechanizeFirefox /

  ];

sub init {
  my ($self,%args) = @_;
  $self->WWWMechanizeFirefox
    (Capability::WebSearch::Method::WWWMechanizeFirefox->new
     (
      ViewHeadless => $args{ViewHeadless},
      Method => $args{Method},
      SearchEngine => 'Google',
     ));
}

sub StartServer {
  my ($self,%args) = @_;
  $self->WWWMechanizeFirefox->StartServer;
}

sub StartClient {
  my ($self,%args) = @_;

}

sub WebSearch {
  my ($self,%args) = @_;
  $args{ContentArgs} = {format => 'text'};
  $self->WWWMechanizeFirefox->WebSearch(%args);
}

1;
