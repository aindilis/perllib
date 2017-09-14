package Capability::NER::Engine::Stanford;

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
  my $res = `ps ax | grep stanford-ner.jar | grep -v grep`;
  if (! $res) {
    my $dir = `pwd`;
    chdir "/var/lib/myfrdcsa/sandbox/stanford-ner-20080306/stanford-ner-20080306";
    system "java -server -mx400m -cp stanford-ner.jar edu.stanford.nlp.ie.NERServer 1234 >/dev/null 2>/dev/null &";
    chdir $dir;
    sleep 20;
  }
}

sub StartClient {
  my ($self,%args) = @_;
}

sub NER {
  my ($self,%args) = @_;
  $self->Client
    (Net::Telnet->new
     (Host => "localhost",
      Port => "1234"));
  # send the contents through the telnet server and get the response
  $self->Client->print($args{Text});
  return $self->Client->getline;
}

sub NERExtract {
  my ($self,%args) = @_;
  my @all;
  my @namedentity;
  my $state = "0";
  my $error;
  my $nerresult = $self->NER(Text => $args{Text});
  # print $nerresult."\n";
  foreach my $token (split /\s+/, $nerresult) {
    if ($token =~ /^(.+)\/(\w+)$/) {
      my $snippet = $1;
      my $cat = $2;
      if ($cat ne $state) {
	if (scalar @namedentity) {
	  my @copy = @namedentity;
	  push @all, [\@copy,$state];
	  @namedentity = ();
	}
      }
      push @namedentity, $snippet if $cat ne "O";
      $state = $cat;
    } else {
      # print "ERROR TOKEN <$token>\n";
      $error = 1;
    }
  }
  if ($error) {
    return [];
  } else {
    return \@all;
  }
}

sub DESTROY {
  my ($self,%args) = @_;
  if (defined $self->Client) {
    $self->Client->close;
  }
}

1;
