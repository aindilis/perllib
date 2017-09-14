package Capability::SentenceSplitting;

use PerlLib::SwissArmyKnife;
use Lingua::EN::Sentence qw(get_sentences);

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw (SplitSentences);

sub SplitSentences {
  my (%args) = @_;
  my @res;
  my $sentences = get_sentences($args{Text});
  foreach my $sentence (@$sentences) {
    $sentence =~ s/[\n\r]+/ /sg;
    $sentence =~ s/\s+/ /sg;
    $sentence =~ s/^\s+//sg;
    $sentence =~ s/\s+$//sg;
    push @res, $sentence;
  }
  return \@res;
}

1;
