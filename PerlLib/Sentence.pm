package PerlLib::Sentence;

use Lingua::EN::Sentence qw(get_sentences);

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / /

  ];

sub init {
  my ($self,%args) = @_;

}

sub GetSentences {
  my ($self,%args) = @_;
  # have the option of tokenizing, etc
  my $res = get_sentences($args{Text});
  my @results;
  foreach my $entry (@$res) {
    if ($args{Clean}) {
      $entry =~ s/[\n\r]/ /g;
      $entry =~ s/\s+/ /g;
      $entry =~ s/^\s*//;
      $entry =~ s/\s*$//;
    }
    push @results, $entry;
  }
  return \@results;
}

1;
