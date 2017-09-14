package Capability::OCR::Engine::Cuneiform;

use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Server Client /

  ];

my $which_cuneiform;
BEGIN { $which_cuneiform = CheckWhich(Name => 'cuneiform'); }

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
    # ensure this is installed before using
    system "$which_cuneiform ".shell_quote($args{ImageFile});
    my $outfile = "cuneiform-out.txt";
    if (-f $outfile) {
      my $text = read_file($outfile);
      system "rm cuneiform-out.txt";
      return {
	      Success => 1,
	      Text => $text,
	     };
    }
  }
  return {
	  Success => 0,
	 };
}

sub OCRExtract {
  my ($self,%args) = @_;

}

1;
