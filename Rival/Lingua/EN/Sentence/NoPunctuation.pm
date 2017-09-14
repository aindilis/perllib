package Rival::Lingua::EN::Sentence::NoPunctuation;

use Rival::Lingua::EN::Sentence::Helper qw(get_sentences_helper);

use Data::Dumper;
use Error qw(:try);
use IO::File;

require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw (get_sentences rival_get_sentences);

sub rival_get_sentences {
  return get_sentences(@_);
}

sub get_sentences {
  my ($text) = shift;
  # return \@sentencesresult;
}

1;
