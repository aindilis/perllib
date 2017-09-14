#!/usr/bin/perl -w

use Data::Dumper;
use RDF::Core::Storage::Memory;
use RDF::Core::Model;
use RDF::Core::Model::Parser;

my $store = RDF::Core::Storage::Memory->new;

my $model = RDF::Core::Model->new
  (
   Storage => $store,
  );

my $parser = RDF::Core::Model::Parser->new
  (
   Model => $model,
   BaseURI => 'http://xmlns.com/foaf/0.1/',
   Source => './foaf.rdf',
   SourceType => 'file',
  );

$parser->parse;

my $seealso = RDF::Core::Resource->new('http://www.w3.org/2000/01/rdf-schema#seeAlso');

my $knows = RDF::Core::Resource->new('http://xmlns.com/foaf/0.1/knows');

my $knows_enum = $model->getStmts(undef, $knows, undef);

my $statement = $knows_enum->getFirst;
print Dumper($statement);
while (defined $statement) {
  my $knows_object = $statement->getObject; 
  ## code to handle each statement goes here 
  my $seealso_enum = $model->getStmts($knows_object, $seealso, undef);
  my $seealso_object = $seealso_enum->getFirst;
  if (defined $seealso_object) { 
    print $seealso_object->getObject->getLabel, "\n";
  }
  $statement = $knows_enum->getNext; 
}

