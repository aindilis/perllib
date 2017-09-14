package System::WWW::DBPedia;

use RDF::Query::Parser::SPARQL;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set =>
  [
   qw / MyParser /
  ];

sub init {
  my ($self,%args) = @_;

}

sub SearchForPhrase {
  my ($self,%args) = @_;
  my $query = "select (<sql:s_sum_page> (<sql:vector_agg> (<bif:vector> (?c1, ?sm)), <bif:vector> ('$search')))  as ?res where { { select (<SHORT_OR_LONG::>(?s1)) as ?c1,  (<sql:S_SUM> ( <SHORT_OR_LONG::IRI_RANK> (?s1), <SHORT_OR_LONG::>(?s1textp), <SHORT_OR_LONG::>(?o1), ?sc ) ) as ?sm  where { ?s1 ?s1textp ?o1 . ?o1 bif:contains  '\"$search\"'  option (score ?sc)  . }order by desc (<sql:sum_rank> ((<sql:S_SUM> ( <SHORT_OR_LONG::IRI_RANK> (?s1), <SHORT_OR_LONG::>(?s1textp), <SHORT_OR_LONG::>(?o1), ?sc ) ) ) ) limit 20  offset 0 }}";
  # my $parser     = RDF::Query::Parse::SPARQL->new();
  # my $iterator = $parser->parse( $query, $base_uri );

  my $query = new RDF::Query ( $rdql, undef, undef, 'rdql' );
  my @rows = $query->execute( $model );

  my $query = new RDF::Query ( $sparql );
  my $iterator = $query->execute( $model );
  while (my $row = $iterator->next) {
    print $row->{ var }->as_string;
  }
}

sub Process {
  my ($self,%args) = @_;
  return unless $args{Contents};
  my $result = $self->Client->Enlighten
    (
     SOAP::Data->type('string')->name('licenseID')->value($self->licenseID),
     SOAP::Data->type('string')->name('content')->value($args{Contents}),
     SOAP::Data->type('string')->name('paramsXML')->value($self->paramsXML),
    );

  # check for error
  unless ($result->fault) {
    return $result->result();
  } else {
    print join ', ',
      $result->faultcode,
	$result->faultstring,
	  $result->faultdetail."\n";
  }
}

sub ProcessAndParse {
  my ($self,%args) = @_;
  return $self->MyParser->Parse
    (Contents => $self->Process
     (Contents => $args{Contents}));
}

1;
