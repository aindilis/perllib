package PerlLib::Date;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw (Date);

sub Date {
  my $date = `date "+%Y%m%d%H%M%S"`;
  chomp $date;
  return $date;
}

1;
