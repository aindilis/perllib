package PerlLib::BodyTextExtractor;

use Data::Dumper;

use File::Temp;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw ( BodyTextExtractor );

sub BodyTextExtractor {
  my %args = @_;
  return unless $args{HTML};
  my $ft = File::Temp->new;
  print $ft $args{HTML};
  my $fn = $ft->filename;
  my $res = `/var/lib/myfrdcsa/codebases/internal/perllib/scripts/bte/bte.py $fn`;
  $ft = undef;
  return $res;
}

1;
