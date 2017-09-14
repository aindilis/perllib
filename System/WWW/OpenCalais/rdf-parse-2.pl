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
   BaseURI => 'http://xmlns.com/foaf/0.1/',
   Source => 'foaf.rdf',
   SourceType => 'file',
  );

$parser->parse;

# print Dumper($model);

## create a resource for seeAlso and knows triples.
my $seealso = RDF::Core::Resource->new('http://www.w3.org/2000/01/rdf-schema#seeAlso');
my $knows = RDF::Core::Resource->new('http://xmlns.com/foaf/0.1/knows');

## create an enumerator with all the knows triples.
my $knows_enum = $model->getStmts(undef, $knows, undef);

## enumerate over each knows triple.
my $statement = $knows_enum->getFirst;

while (defined $statement) {
  ## get the object of the current triple.
  my $knows_object = $statement->getObject;

  ## look for subject of the enumerator (knows), and predicate of 
  ## seealso
  my $seealso_enum = $model->getStmts($knows_object, $seealso, undef);
  my $seealso_obj = $seealso_enum->getFirst;

  ## if it has a seealso triple, show the value of it.
  if (defined $seealso_obj) {
    print $seealso_obj->getObject->getLabel, "\n";
  }

  ## get the next knows statement. 
  $statement = $knows_enum->getNext;
}
