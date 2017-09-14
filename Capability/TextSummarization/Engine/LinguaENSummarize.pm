package Capability::TextSummarization::Engine::LinguaENSummarize;

use Data::Dumper;
use Lingua::EN::Summarize;

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

sub StopServer {
  my ($self,%args) = @_;
}

sub StartClient {
  my ($self,%args) = @_;
}

sub StopClient {
  my ($self,%args) = @_;
}

sub SummarizeText {
  my ($self,%args) = @_;
  return {
	  Success => 1,
	  Result => summarize( $args{Text} ),
	 };
}

1;
