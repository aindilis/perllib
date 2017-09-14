#!/usr/bin/perl -w

use Net::Google;
use constant LOCAL_GOOGLE_KEY => "Qte9k4VQFHKgauaxU4FdkjjJwazm3vrg";

my $google = Net::Google->new(key=>LOCAL_GOOGLE_KEY);
my $search = $google->search();
 
# Search interface
 
$search->query(qw(free software artificial intelligence));
$search->lr(qw(en));
$search->starts_at(5);
$search->max_results(15);
 
map { print $_->title()."\n"; } @{$search->results()};
 
# or...
 
foreach my $r (@{$search->response()}) {
  print "Search time :".$r->searchTime()."\n";
 
  # returns an array ref of Result objects
  # the same as the $search->results() method
  map { print $_->URL()."\n"; } @{$r->resultElements()};
}
 
# # Spelling interface
 
# print $google->spelling(phrase=>"muntreal qwebec")->suggest(),"\n";
 
# # Cache interface
 
# my $cache = $google->cache(url=>"http://search.cpan.org/recent");
# print $cache->get();
