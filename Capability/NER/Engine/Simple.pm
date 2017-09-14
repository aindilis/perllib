package Capability::NER::Engine::Simple;

use Rival::String::Tokenizer2;

use Data::Dumper;
use Net::Telnet;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Names MyTokenizer /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Names({});
}

sub StartServer {
  my ($self,%args) = @_;
  my $dir = `pwd`;
  my $names;

  my $text = `zcat /var/lib/myfrdcsa/datasets/names/cis-surname.gz`;
  $text .= `zcat /var/lib/myfrdcsa/datasets/names/cis-givenname.gz`;

  # my $text = `zcat /var/lib/myfrdcsa/datasets/names/fast-names.gz`;
  # $text .= `zcat /var/lib/myfrdcsa/datasets/names/Family-Names.gz`;
  foreach my $line (split /\n/, $text) {
    if ($line !~ /\#/) {
      $self->Names->{lc($line)}++;
    }
  }
  $self->MyTokenizer
    (Rival::String::Tokenizer2->new);
}

sub StartClient {
  my ($self,%args) = @_;
}

sub NER {
  my ($self,%args) = @_;
  # simply tokenize and then
  return $self->NERTokens
    (Tokens => $self->MyTokenizer->Tokenize
     (Text => $args{Text}));
}

sub NERExtract {
  my ($self,%args) = @_;
  my @all;
  my @namedentity;
  my $state = "0";
  my $error;
  my $nerresult = $self->NER(Text => $args{Text});
  # print $nerresult."\n";
  foreach my $entry (@$nerresult) {
    my $snippet = $entry->{Token};
    my $cat = $entry->{Type} || "0";
    if ($cat eq "Name") {
      $cat = "PERSON";
    }
    if ($cat ne $state) {
      if (scalar @namedentity) {
	my @copy = @namedentity;
	push @all, [\@copy,$state];
	@namedentity = ();
      }
    }
    push @namedentity, $snippet if $cat ne "O";
    $state = $cat;
  }
  if ($error) {
    return [];
  } else {
    return \@all;
  }
}

sub NERTokens {
  my ($self,%args) = @_;
  # simply tokenize and then
  my @ret;
  foreach my $token (@{$args{Tokens}}) {
    if (exists $self->Names->{lc($token)}) {
      push @ret, {
		  Token => $token,
		  Type => "Name",
		 };
    } else {
      push @ret, {
		  Token => $token,
		 };
    }
  }
  return \@ret;
}

sub DESTROY {
  my ($self,%args) = @_;
}

1;

