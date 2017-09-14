package Rival::String::Tokenizer2;

use Data::Dumper;
use File::Temp;
use Lingua::EN::Sentence qw(get_sentences);
# use TextMine::Tokens qw(tokens);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / /

  ];

sub init {
  my ($self,%args) = @_;
}

sub tokenize_treebank {
  my $text = shift;
  my $f = File::Temp->new;
  foreach my $sentence (@{get_sentences($text)}) {
    $sentence =~ s/[\n\r]+/ /g;
    $sentence =~ s/\s+/ /g;
    print $f $sentence."\n";
  }
  my $fn = $f->filename;
  my $result = `/var/lib/myfrdcsa/codebases/internal/perllib/scripts/tokenizer.sed < $fn`;
  return $result;
}

sub Tokenize {
  my ($self,%args) = @_;
  if (! $args{Tokenizer}) {
    return [split /\s+/, tokenize_treebank($args{Text})];
  } elsif ($args{Tokenizer} eq "simple") {
    return [split /\W+/,$args{Text}];
  } elsif ($args{Tokenizer} eq "textmine") {
    my @all;
    my $ref = get_sentences($args{Text});
    my $type = ref $ref;
    if ($type eq "ARRAY") {
      foreach my $sentence (@$ref) {
	my ($tokens,$indexes) = tokens(\$sentence);
	foreach my $token (@$tokens) {
	  if ($token =~ /^\w+$/) {
	    push @all, $token;
	  }
	}
      }
    }
    return \@all;
  }
}

1;
