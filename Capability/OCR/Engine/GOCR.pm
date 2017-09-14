package Capability::OCR::Engine::GOCR;

use Data::Dumper;
use Net::Telnet;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Server Client /

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

sub OCR {
  my ($self,%args) = @_;

}

sub OCRExtract {
  my ($self,%args) = @_;

}

1;
