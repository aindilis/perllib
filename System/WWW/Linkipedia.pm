package System::WWW::Linkipedia;

use JSON;
use URI::Encode;
use WWW::Mechanize;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set =>
  [
   qw / Server Mechanize URIEncode MyToText QueryPrefix /
  ];

sub init {
  my ($self,%args) = @_;
  $self->Server($args{Server} || "http://justin.frdcsa.org");
  $self->Mechanize(WWW::Mechanize->new);
  $self->URIEncode(URI::Encode->new( { encode_reserved => 0 } ));
  $self->QueryPrefix($self->Server.':8080/');
}

sub Query {
  my ($self,%args) = @_;
  my $query = $self->PrepareQuery(Query => $args{Query});
  my $encoded = $self->URIEncode->encode($query);
  $self->Mechanize->get($self->QueryPrefix.'query?query='.$encoded);
  return Process($self->Mechanize->content());
}

sub Linking {
  my ($self,%args) = @_;
  my $query = $self->PrepareQuery(Query => $args{Query});
  my $encoded = $self->URIEncode->encode($query);
  $self->Mechanize->get($self->QueryPrefix.'linking?query='.$encoded);
  return Process($self->Mechanize->content());
}

sub Linkify {
  my ($self,%args) = @_;
  my $query = $self->PrepareQuery(Query => $args{Query});
  my $encoded = $self->URIEncode->encode($query);
  $self->Mechanize->get($self->QueryPrefix.'linkify?query='.$encoded);
  return Process($self->Mechanize->content());
}

sub LinkifyPOST {
  my ($self,%args) = @_;
  my $query = $self->PrepareQuery(Query => $args{Query});
  my $response = $self->Mechanize->post
    (
     $self->QueryPrefix.'linkify',
     [
      'query' => $query,
     ],
     (),
    );
  return Process($response);
}


sub Process {
  my ($json) = @_;
  if ($json) {
    return decode_json($json);
  } else {
    return {};
  }
}

sub PrepareQuery {
  my ($self,%args) = @_;
  my $q = $args{Query};
  $q =~ s/<[^\>]+?>/ /sg;
  $q =~ s/[^[:ascii:]]/ /sg;
  $q =~ s/\s+/ /sg;
  $q =~ s/digg_url = .*?>//sg;
  #$q =~ s/\W+/ /sg;
  $q =~ s/^\s*//sg;
  $q =~ s/\s*$//sg;
  return $q;
}

1;
