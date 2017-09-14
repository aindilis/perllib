package Capability::OCR::Engine::Tesseract;

use Capability::OCR::Engine::Tesseract::Helper qw(get_ocr);

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
  # take the image file and return the contents here
  if (exists $args{ImageFile} and
      -f $args{ImageFile}) {
    # check that it is the right kind of file
    $Capability::OCR::Engine::Tesseract::Helper::DEBUG = 1;
    my $text = get_ocr($args{ImageFile});
    return {
	    Success => 1,
	    Text => $text,
	   };
  }
  return {
	  Success => 0,
	 };
}

sub OCRExtract {
  my ($self,%args) = @_;

}

1;
