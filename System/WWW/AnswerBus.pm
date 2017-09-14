package System::WWW::AnswerBus;

# www.answerbus.com

use Manager::Dialog qw(Approve QueryUser);
use Rival::String::Tokenizer;

use Data::Dumper;
use WWW::Mechanize;

use Class::MethodMaker
  new_with_init => 'new',
  get_set =>
  [
   qw / MyTokenizer MyMechanize /
  ];

sub init {
  my ($self,%args) = @_;
  $self->MyTokenizer
    (Rival::String::Tokenizer->new);
  $self->MyMechanize
    (WWW::Mechanize->new);
}

sub QuestionLook {
  my ($self,%args) = @_;
  while (1) {
    my $question = QueryUser("Question? ");
    if (Approve("Warning: Release Question: $question")) {
      print Dumper(QueryAnswerbus(Question => $question));
    }
  }
}

sub QueryAnswerbus {
  my ($self,%args) = @_;
  my $q = $args{Question};
  $self->MyTokenizer->tokenize($q);
  my $url = "http://www.answerbus.com/cgi-bin/answerbus/xml.cgi?".
    join("%2B",$self->MyTokenizer->getTokens())."%3F";
  $self->MyMechanize->get($url);
  return $self->MyMechanize->content();
}

1;
