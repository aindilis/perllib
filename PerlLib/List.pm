package PerlLib::List;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw (ListContainsElement);

sub ListContainsElement {
  my %args = @_;
  my $elt = $args{Element};
  foreach my $newelt (@{$args{List}}) {
    if ($elt eq $newelt) {
      return 1;
    }
  }
  return 0;
}

1;
