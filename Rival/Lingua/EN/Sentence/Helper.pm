package Rival::Lingua::EN::Sentence::Helper;

use Lingua::EN::Sentence qw(get_sentences);

require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw (get_sentences_helper);

sub get_sentences_helper {
  return get_sentences(@_);
}

1;
