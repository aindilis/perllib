package System::JavaRAP;

use File::Temp;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw (ResolveAnaphoras);

sub ResolveAnaphoras {
  my %args = @_;
  my $fh = File::Temp->new;
  my $filename = $fh->filename;
  print $fh $args{Text};
  chdir "/var/lib/myfrdcsa/sandbox/javarap-1.11/javarap-1.11";
  my $res = `java -jar AnaphoraResolution.jar $filename`;
  undef $fh;
  return $res;
}

1;
