package PerlLib::URIExtractor2;

use Data::Dumper;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw ( ExtractURIs );

my $regex = '((https?|ftp|gopher|telnet|file|notes|ms-help):((//)|(\\\\))+[\w\d:#@%/;$()~_?\+-=\\\.&]*)';

sub ExtractURIs {
  my $contents = shift;
  return [] unless $contents;
  my @urls;
  foreach my $content (split /[^\w\d:\#\@\%\/;\$\(\)~_?\+\-=\\\.\&]+/, $contents) {
    if ($content =~ /$regex/i) {
      my @res = $content =~ /(.*?)$regex(.*?)/sgi;
      # print Dumper(\@res);
      while (@res) {
	shift @res;
	my $item = shift @res;
	$item =~ s/\.$//;
	push @urls, $item;
	shift @res;
	shift @res;
	shift @res;
	shift @res;
	shift @res;
      }
    }
  }
  return \@urls;
}

1;
