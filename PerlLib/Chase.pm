package PerlLib::Chase;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(chase);

use String::ShellQuote;

# for now, just use chase
sub chase {
  my $fn = shift;
  if (-f $fn or -d $fn) {
    my $command = 'chase '.shell_quote($fn);
    my $res = `$command`;
    $res =~ s/[\n\r]+$//sg;
    return $res;
  } else {
    return $fn;
  }
}

1;

