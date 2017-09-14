package System::WWW::OpenCalais::RDFParser;

use strict;

use Data::Dumper;
use File::Temp;
use IO::File;
use RDF::Core::Model;
use RDF::Core::Storage::Memory;
use RDF::Core::Model::Parser;
use RDF::Core::Resource;

use Class::MethodMaker
  new_with_init => 'new',
  get_set =>
  [
   qw / MyStore MyModel MyParser /
  ];

sub init {
  my ($self,%args) = @_;
  $self->MyStore(RDF::Core::Storage::Memory->new);
  $self->MyModel(RDF::Core::Model->new(Storage => $self->MyStore));
}

sub Parse {
  my ($self,%args) = @_;
  my $fh = File::Temp->new;
  my $filename = $fh->filename;
  print $fh $args{Contents};
  $fh->close;

  ## create our parse and parse the Source file.
  my $parser = RDF::Core::Model::Parser->new
     (
      Model => $self->MyModel,
      BaseURI => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
      Source => $filename,
      SourceType => 'file',
     );

  $parser->parse;

  ## create a resource for seeAlso and knows triples.
  my $document = RDF::Core::Resource->new('http://s.opencalais.com/1/pred/document');

  my $text = $self->GetAllTriples(undef,$document,undef)->[0]->getObject->{_value};
  $text =~ s/\\\'/\'/g;

  # print Dumper($self->GetAllTriples(undef,undef,undef));
  # print ;
  # <c:subject rdf:resource="http://d.opencalais.com/genericHasher-1/9d7dc33f-e6bd-3dfa-8008-cb39ad48abe6"/>
  # http://d.opencalais.com/dochash-1/44dee71d-3f27-3bb4-b7fe-9e6ecd25ae1d/Instance/22


  my $detection = RDF::Core::Resource->new('http://s.opencalais.com/1/pred/detection');
  my $offset = RDF::Core::Resource->new("http://s.opencalais.com/1/pred/offset");
  my $length = RDF::Core::Resource->new("http://s.opencalais.com/1/pred/length");
  my $exact = RDF::Core::Resource->new("http://s.opencalais.com/1/pred/exact");

  my @list;
  my $extracted = {};
  foreach my $statement (@{$self->GetAllTriples(undef,$detection,undef)}) {
    my $subject = $statement->getSubject;
    $extracted->{$self->GetAllTriples($subject,$exact,undef)->[0]->getObject->{_value}} = 1;
  }

  # now remove all the statements for this
  $self->ClearModel;
  return $extracted;
}

sub GetAllTriples {
  my $self = shift;
  my $enum = $self->MyModel->getStmts(@_);
  my @res;

  ## enumerate over each knows triple.
  my $statement = $enum->getFirst;
  while (defined $statement) {
    push @res, $statement;
    $statement = $enum->getNext;
  }
  return \@res;
}

sub ClearModel {
  my ($self,%args) = @_;
  foreach my $statement (@{$self->GetAllTriples(undef,undef,undef)}) {
    $self->MyModel->removeStmt($statement);
  }
}

1;
