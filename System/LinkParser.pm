package System::LinkParser;

use Lingua::EN::Sentence qw(get_sentences);
use Lingua::LinkParser;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyLinkParser /

  ];

sub init {
  my ($self,%args) = @_;
}

sub CheckText {
  my ($self,%args) = @_;
  my $t = $args{Text};
  my $sentences = get_sentences($t);
  my $h = {};
  foreach my $sentence (@$sentences) {
    if (! exists $h->{$sentence}) {
      $h->{$sentence} = $self->CheckSentence(Sentence => $sentence);
    }
  }
  return {
	  Sentences => $sentences,
	  Selection => $h,
	 };
}

sub CheckSentence {
  my ($self,%args) = @_;
  # determine whether the link parser agrees
  if (! $self->MyLinkParser) {
    # $Lingua::LinkParser::DATA_DIR = "/usr/local/share/link-grammar/en";
    $self->MyLinkParser
      (Lingua::LinkParser->new);
  }
  # now go ahead and take the incoming sentence
  my $s = $args{Sentence};
  # tokenize it
  # for now just split it
  # eventually actually eliminate nonsense
  my @t = split /\W+/, $s;
  if (scalar @t > 20) {
    # it would take too long
    # this also can tell if its going to take too long: $parser->opts("max_parse_time",3);
    return "0";
  } else {
    # check it
    my $ls = $self->MyLinkParser->create_sentence($s);
    return scalar $ls->linkages;
  }
}

1;
