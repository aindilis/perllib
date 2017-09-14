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
   Source => 'opencalais-result.rdf',
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

my @list;
foreach my $statement (@{GetAllTriples(undef,$detection,undef)}) {
  my $subject = $statement->getSubject;
  push @list, [
	       GetAllTriples($subject,$offset,undef)->[0]->getObject->{_value},
	       GetAllTriples($subject,$length,undef)->[0]->getObject->{_value},
	      ];
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

sub ExtractMarkups {
  my %args = @_;
  my $chars1 = [split //, $args{Text}];
  my $chars2 = [];
  foreach my $pair (@{$args{List}}) {
    my $a = $pair->[0];
    my $b = $pair->[0] + $pair->[1];

    if (! defined $chars2->[$a]) {
      $chars2->[$a] = [];
    }
    push @{$chars2->[$a]}, "<tag>";

    if (! defined $chars2->[$b]) {
      $chars2->[$b] = [];
    }
    push @{$chars2->[$b]}, "</tag>";
  }
  my @result;
  foreach my $i (0..$#$chars1) {
    if (defined $chars2->[$i]) {
      push @result, @{$chars2->[$i]};
    }
    push @result, $chars1->[$i];
  }
  return join("",@result);
}

print ExtractMarkups
  (
   Text => $text,
   List => \@list,
  );

