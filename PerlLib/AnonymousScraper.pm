package PerlLib::AnonymousScraper;

# this is an anonymizing, cloaking scraper to get data that
# is hard to get otherwise

# three things to figure out still
# 1) how to get tor to reroute for each request
# 2) how to randomize the timing
# 3) how to randomize the list

use Manager::Dialog qw(Message);

use Data::Dumper;
use WWW::Mechanize;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / CacheDir Mech UserAgents PercentTotal /

  ];

sub init {
  my ($self,%args) = @_;
  $self->CacheDir($args{CacheDir});
  $self->Mech(WWW::Mechanize->new);
  $self->UserAgents
    ({"Windows IE 6" => 70,
      "Windows Mozilla" => 5,
      "Mac Safari" => 20,
      "Mac Mozilla" => 5,
      "Linux Mozilla" => 10,
      "Linux Konqueror" => 5});
  my $total = 0;
  foreach my $key (keys %{$self->UserAgents}) {
    $total += $self->UserAgents->{$key};
  }
  $self->PercentTotal($total);
  # ensure that TOR, privoxy are up and running
  $self->Mech->proxy(['http', 'ftp'], 'http://localhost:8118/');
}

sub ScrapeURI {
  my ($self,%args) = @_;
  # be sure to go through TOR
  $self->ChangeUserAgent;
  if (0) {
    $self->Mech->get($args{URI});
    # convert the  url to a  suitable storage form  and write it  to the
    # storage dir
    my $file = $self->CacheDir."/".CleanUpURI(URI => $args{URI});
    my $OUT;
    open(OUT,">$file") and print OUT $mech->content and close(OUT);
  }
}

sub CleanUpURI {
  my ($self,%args) = @_;
  my $uri = $args{URI};
  $uri =~ s/\W+/-/g;
  return $uri;
}

sub ChangeUserAgent {
  my ($self,%args) = @_;
  my $useragent = $self->GetRandomUserAgent;
  Message(Message => "User Agent set to: ".$useragent);
  $self->Mech->agent_alias
    ($useragent);
}

sub GetRandomUserAgent {
  my ($self,%args) = @_;
  my $cutoff = rand($self->PercentTotal);
  my $total = 0;
  foreach my $key (keys %{$self->UserAgents}) {
    $total += $self->UserAgents->{$key};
    if ($total > $cutoff) {
      return $key;
    }
  }
}

1;
