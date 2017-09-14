package System::WWW::DBpediaSpotlight;

use Data::Dumper;
use URL::Encode qw(url_encode_utf8);
use WWW::Mechanize;

use Class::MethodMaker
  new_with_init => 'new',
  get_set =>
  [
   qw / MyMechanize /
  ];

sub init {
  my ($self,%args) = @_;
  $self->MyMechanize(WWW::Mechanize->new);
}

sub ProcessTextWithDBpediaSpotlight {
  my ($self,%args) = @_;
  my $text = $args{Text};
  my $formattedtext = url_encode_utf8($text);
  my $url = "http://spotlight.dbpedia.org/rest/annotate?text=${formattedtext}&confidence=0.4&support=20";
  # print $url."\n";
  # process this call
  my $result = "";
  eval {
    $self->MyMechanize->get( $url );
    $result = $self->MyMechanize->content;
  };
  # print Dumper($result);
  return
    {
     Success => 1,
     Result => $result,
    };
}

1;
