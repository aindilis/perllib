package System::TARSQI;

use File::Temp;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw /  /

  ];

sub init {
  my ($self,%args) = @_;
  # $self->FakeEnju($args{FakeEnju});
}

sub ProcessString {
  my ($self,%args) = @_;
  # somewhere verify that this is in text format

  my $tempfile = File::Temp->new();
  my $infile = $tempfile->filename;
  print $tempfile "<DOC>\n<DOCID> Simple Test </DOCID>\n<TEXT>\n".$args{String}."\n</TEXT>\n</DOC>\n";
  my $tempfile2 = File::Temp->new();
  my $outfile = $tempfile2->filename;
  $tempfile2 = undef;
  my $flags = "--pipeline=PREPROCESSOR,GUTIME,EVITA,SLINKET,S2T,BLINKER,CLASSIFIER,LINK_MERGER";
  my $c = "python tarsqi.py simple-xml $flags $infile $outfile";
  chdir "/var/lib/myfrdcsa/sandbox/tarsqi-1.0/tarsqi-1.0/code";
  system $c;

  # my $contents = `cat "$outfile"`;
  # system "rm \"$outfile\"";

  my $contents = `cat "/var/lib/myfrdcsa/sandbox/tarsqi-1.0/tarsqi-1.0/code/data/tmp/fragment_001.mer.t.xml"`;
  return $contents;
}

1;
