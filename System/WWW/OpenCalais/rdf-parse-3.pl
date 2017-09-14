#!/usr/bin/perl -w

use RDF::Simple::Parser;

use Data::Dumper;

my $file = "/s1/temp/myfrdcsa/codebases/releases/perllib-0.1/perllib-0.1/System/WWW/OpenCalais/foaf.rdf";
my $uri = 'file://$file';
# my $rdf = LWP::Simple::get($uri);
my $rdf = `cat $file`;
my $parser = RDF::Simple::Parser->new(base => $uri);

my @triples = $parser->parse_rdf($rdf);
# Returns an array of array references which are triples

print Dumper(\@triples);
