package Capability::NER::Engine::TagEn;

use Data::Dumper;

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

sub StartClient {
  my ($self,%args) = @_;
}

sub NER {
  my ($self,%args) = @_;
  # have to format the text carefully
  my $OUT;
  if (! -d "/tmp/ner") {
    system "mkdirhier /tmp/ner";
  }
  open (OUT, ">/tmp/ner/tagen.txt") or die "death!\n";
  print OUT $args{Text};
  close (OUT);
  my $dir = `pwd`;
  chdir "/var/lib/myfrdcsa/sandbox/tagen-20080306/tagen-20080306";
  system "echo y | ./tagen :wiki -t /tmp/ner/tagen.txt";
  my $res = `cat /tmp/ner/tagen.tag.txt`;
  chdir $dir;
  return $res;
}

1;
