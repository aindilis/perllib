package Capability::OCR;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Name Engine /

  ];

sub init {
  my ($self,%args) = @_;
  my $name = $args{EngineName} || "Tesseract";
  $self->Name($name);
  require "Capability/OCR/Engine/$name.pm";
  $self->Engine
    ("Capability::OCR::Engine::$name"->new
     (%args));
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

sub OCR {
  my ($self,%args) = @_;
  return $self->Engine->OCR(ImageFile => $args{ImageFile});
}

sub MakeSearchablePDF {
  my ($self,%args) = @_;
  return $self->Engine->MakeSearchablePDF
    (%args);
}

sub SearchablePdfP {
  my ($self,%args) = @_;
  return $self->Engine->SearchablePdfP
    (%args);
}

sub OCRFile {
  my ($self,%args) = @_;
  return $self->Engine->OCRFile
    (%args);
}

sub OCRExtract {
  my ($self,%args) = @_;
  return $self->Engine->OCRExtract(Text => $args{Text});
}

1;
