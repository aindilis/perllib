package PerlLib::URIExtractor;

use Data::Dumper;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw ( ExtractURIs );

my $regex = '((https?|ftp|gopher|telnet|file|notes|ms-help):((//)|(\\\\))+[\w\d:#@%/;$()~_?\+-=\\\.&]*)';

sub ExtractURIs {
  my $contents = shift;
  return [] unless $contents;
  my @urls;
  if ($contents =~ /$regex/i) {
    my @res = $contents =~ /(.*?)$regex(.*?)/sgi;
    # print Dumper(\@res);
    while (@res) {
      shift @res;
      push @urls, shift @res;
      shift @res;
      shift @res;
      shift @res;
      shift @res;
      shift @res;
    }
  }
  return \@urls;
}

1;
