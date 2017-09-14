package System::Cyc::Util;

use KBS2::Util;
use String::ShellQuote;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw (QuoteForCyclify);

sub QuoteForCyclify {
  my (%args) = @_;
  # return EmacsQuote(Arg => $args{Text});
  my $quoted = shell_quote($args{Text});
  $quoted =~ s/"/\\"/sg;
  $quoted =~ s/^\'/"/;
  $quoted =~ s/\'$/"/;
  return $quoted;
}

1;
