package PerlLib::Hash;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw (PrintHash);

sub PrintHash {
  my ($hash) = (shift);
  print "\n";
  foreach my $key (keys %$hash) {
    print "<$key><".$hash->{$key}.">\n";
  }
  print "\n";
}

1;
