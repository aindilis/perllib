package Capability::NER::Engine::CAndC;

use Lingua::EN::Sentence;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Engine /

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

sub NER {
  my ($self,%args) = @_;
  # have to format the text carefully
  my $OUT;
  open (OUT, ">/tmp/candctext") or die "death!\n";
  print OUT $args{Text};
  close (OUT);
  my $dir = `pwd`;
  chdir "/var/lib/myfrdcsa/sandbox/candc-1.00/candc-1.00";
  my $res = `cat /tmp/candctext | bin/pos --model models/pos | bin/ner --model models/ner`;
  chdir $dir;
  return $res;
}

1;
