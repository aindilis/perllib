package Rival::String::Tokenizer;

use Rival::String::Tokenizer2;

use Data::Dumper;
# use TextMine::Tokens qw(tokens);
use Lingua::EN::Sentence qw(get_sentences);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / T2 Tokens /

  ];

sub init {
  my ($self,%args) = @_;
  $self->T2(Rival::String::Tokenizer2->new);
  $self->Tokens([]);
}

sub tokenize {
  my ($self,$text) = @_;
  $self->Tokens($self->T2->Tokenize(Text => $text));
  #   my @all;
  #   foreach my $sentence (@{get_sentences($text)}) {
  #     my ($tokens,$indexes) = tokens(\$sentence);
  #     foreach my $token (@$tokens) {
  #       if ($token =~ /^\w+$/) {
  # 	push @all, $token;
  #       }
  #     }
  #   }
  #   $self->Tokens(\@all);
}

sub getTokens {
  my $self = shift;
  return @{$self->Tokens};
}

1;
