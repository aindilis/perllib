package Capability::TermExtraction;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw (TermExtraction);

use Capability::TermExtraction::TermEx;

sub TermExtraction {
  my %args = @_;
  if ($args{Engine} eq "ASV") {
    
  } else {
    return TermexTermExtraction(%args);
  }
}

1;
