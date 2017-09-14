package Capability::QueryExpansion;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw (QueryExpansion);

use Data::Dumper;

sub QueryExpansion {
  my (%args) = @_;
  my $expansion = {};
  chdir "/var/lib/myfrdcsa/sandbox/lucqe-20081020/lucqe-20081020";
  my $query = $args{Query};
  my $contents = `/usr/bin/java -classpath .:src:lib/junit.jar:lib/:lib/googleapi.jar:lib/lucene-1.4.3.jar:lib/lucene-demos-1.2.jar: SingleSearch "$query" 2>&1`;
  # my $contents = `cat /var/lib/myfrdcsa/codebases/internal/perllib/scripts/t/sample`;
  foreach my $line (split /\n/, $contents) {
    if ($line =~ /^INFO: Expanded Query: (.+)$/) {
      my $results = $1;
      my @res = split /\s?text:/,$results;
      shift @res;
      foreach my $item (@res) {
	my ($a,$b) = split /\^/,$item;
	$expansion->{$a} = $b;
      }
    }
  }
  return $expansion;
}

1;
