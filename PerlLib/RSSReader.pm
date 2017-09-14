package PerlLib::RSSReader;

use PerlLib::HTMLConverter;

use Data::Dumper;
use WWW::Mechanize;
use XML::Simple;
use XML::Twig;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / OPMLFile Queue OPML Links Mech HTMLConverter / ];

sub init {
  my ($self,%args) = (shift,@_);
  $self->OPMLFile($args{OPMLFile});
  $self->Links([]);
  $self->Queue([]);
  $self->LoadOPML;
  $self->Mech(WWW::Mechanize->new());
  $self->HTMLConverter(PerlLib::HTMLConverter->new());
}

sub GetContents {
  my ($self,%args) = (shift,@_);
  if (! @{$self->Links}) {
    $self->LoadOPML;
  }
  if (! @{$self->Queue}) {
    $self->LoadQueue;
  }
  return join("\n",map $self->Preprocess(Item => $_), @{$self->Queue});
}

sub Preprocess {
  my ($self,%args) = (shift,@_);
  my $txt = $self->HTMLConverter->ConvertToTxt
    (Contents => $args{Item}->{'description'});
  $txt =~ s/\P{IsASCII}/ /g;
  return $txt;
}

sub LoadOPML {
  my ($self,%args) = (shift,@_);
  my $c1 = "cat ".$self->OPMLFile;
  my $contents = `$c1`;
  $self->OPML(XMLin($contents));
  my @links;
  foreach my $hash (@{$self->OPML->{'body'}->{'outline'}}) {
    push @links, $hash->{'xmlUrl'};
  }
  $self->Links(\@links);
}

sub LoadQueue {
  my ($self,%args) = (shift,@_);
  # means recheck all links
  foreach my $link (@{$self->Links}) {
    if ($link !~ /\.rdf$/) {
      print "Fetching $link...\n";
      $self->Mech->get( $link );
      my $contents = $self->Mech->content();
      # my $contents = `cat rss/data/index.rss`;
      my $count = 0;
      my $hash = XMLin($contents);
      foreach my $item (@{$hash->{'channel'}->{'item'}}) {
	push @{$self->Queue}, $item;
	++$count;
      }
      print "Fetched $count items\n";
    }
  }
}

1;
