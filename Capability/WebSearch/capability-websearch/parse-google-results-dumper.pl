#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

use HTML::TreeBuilder;
use HTML::PrettyPrinter;

my $c = read_file('/var/lib/myfrdcsa/codebases/minor/auto-builder/scripts/res-google-dumper.html');

print Dumper(ParseGoogleResults(Text => $c));

sub ParseGoogleResults {
  my (%args) = @_;
  my $c = $args{Text};
  print $c."\n";
  # if ($c =~ /<div data-nir=(.*?)<\/div><\/div><\/div>/s) {
  #   print $1."\n";
  # }

  # my @res1 = $c =~ /<div data-nir=(.*?)<\/div><\/div><\/div>/sg;
  # # print Dumper(\@res1);
  # foreach my $res2 (@res1) {
  #   print $res2."\n\n\n";
  #   my $hash = {};
  #   if ($res2 =~ /\<a href=\\\"([^"]+?)\\\" rel/sm) {
  #     $hash->{url} = $1;
  #   }
  #   if ($res2 =~ /class=\\\"result__a\\\">(.+?)<\/a>/sm) {
  #     $hash->{title} = $1;
  #   }
  #   if ($res2 =~ /<div class=\\\"result__snippet\\\">(.+?)<\/div>/sm) {
  #     $hash->{content} = $1;
  #   }
  #   push @results, $hash;
  # }
  # return \@results;
}


