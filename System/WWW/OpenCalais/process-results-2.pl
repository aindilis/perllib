#!/usr/bin/perl -w

## Extract a list of seeAlso triples from a FOAF file
## Robert Price - http://www.robertprice.co.uk/

use strict;

use Data::Dumper;
use RDF::Core::Model;
use RDF::Core::Storage::Memory;
use RDF::Core::Model::Parser;
use RDF::Core::Resource;

## create our model and storage for triples.

my $store = RDF::Core::Storage::Memory->new;
my $model = RDF::Core::Model->new(Storage => $store);
## create our parse and parse the Source file.
my $parser = RDF::Core::Model::Parser->new
  (
   Model => $model,
   BaseURI => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
   Source => $ARGV[0],
   SourceType => 'file',
  );

$parser->parse;

## create a resource for seeAlso and knows triples.
my $document = RDF::Core::Resource->new('http://s.opencalais.com/1/pred/document');

my $text = GetAllTriples(undef,$document,undef)->[0]->getObject->{_value};
$text =~ s/\\\'/\'/g;

# print Dumper(GetAllTriples(undef,undef,undef));
# print ;
# <c:subject rdf:resource="http://d.opencalais.com/genericHasher-1/9d7dc33f-e6bd-3dfa-8008-cb39ad48abe6"/>
# http://d.opencalais.com/dochash-1/44dee71d-3f27-3bb4-b7fe-9e6ecd25ae1d/Instance/22


my $detection = RDF::Core::Resource->new('http://s.opencalais.com/1/pred/detection');
my $offset = RDF::Core::Resource->new("http://s.opencalais.com/1/pred/offset");
my $length = RDF::Core::Resource->new("http://s.opencalais.com/1/pred/length");
my $exact = RDF::Core::Resource->new("http://s.opencalais.com/1/pred/exact");

my @list;
my $extracted = {};
foreach my $statement (@{GetAllTriples(undef,$detection,undef)}) {
  my $subject = $statement->getSubject;
  $extracted->{GetAllTriples($subject,$exact,undef)->[0]->getObject->{_value}} = 1;
}

sub GetAllTriples {
  my $enum = $model->getStmts(@_);
  my @res;

  ## enumerate over each knows triple.
  my $statement = $enum->getFirst;
  while (defined $statement) {
    push @res, $statement;
    $statement = $enum->getNext;
  }
  return \@res;
}

print Dumper($extracted);
