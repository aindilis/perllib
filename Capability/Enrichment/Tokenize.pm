package Capability::Enrichment::Tokenize;

use Rival::String::Tokenizer2;

use Data::Dumper;
use Lingua::EN::Sentence qw(get_sentences);
use Lingua::EN::Tagger;
# use TextMine::Tokens qw(tokens);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / T2 Tokens MyTagger /

  ];

sub init {
  my ($self,%args) = @_;
  $self->T2(Rival::String::Tokenizer2->new);
  $self->Tokens([]);

  $self->MyTagger(Lingua::EN::Tagger->new);
}

sub tokenize {
  my ($self,$text) = @_;
  $self->Tokens($self->T2->Tokenize(Text => $text));

  # my $self = $UNIVERSAL::textanalysis;
  my $tagged_text = $self->MyTagger->add_tags($text);
  my %res = $self->MyTagger->get_noun_phrases($tagged_text);
  push @{$self->Tokens}, grep {/\s/} sort keys %res;

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
