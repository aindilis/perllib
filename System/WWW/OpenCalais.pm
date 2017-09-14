package System::WWW::OpenCalais;

use strict;

use System::WWW::OpenCalais::RDFParser;
use System::WWW::OpenCalais::TextSimpleParser;

use Data::Dumper;
use SOAP::Lite;

use Class::MethodMaker
  new_with_init => 'new',
  get_set =>
  [
   qw / licenseID content paramsXML Client MyParser Type /
  ];

sub init {
  my ($self,%args) = @_;
  $self->Type($args{Type} || "Text/Simple");
  my $type = $self->Type;
  $self->licenseID($args{licenseID} || 'dyx2xwdcssbgm3bk7jsbj3au');
  $self->paramsXML($args{paramsXML} || '<c:params xmlns:c="http://s.opencalais.com/1/pred/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<c:processingDirectives c:contentType="TEXT/TXT" c:outputFormat="'.$type.'">
</c:processingDirectives>
<c:userDirectives c:allowDistribution="true" c:allowSearch="true" c:externalID="testing" c:submitter="FRDCSA">
</c:userDirectives>
<c:externalMetadata>
</c:externalMetadata>
</c:params>');
  $self->Client
    (SOAP::Lite
     ->proxy("http://api.opencalais.com/enlighten/calais.asmx")
     ->default_ns("http://clearforest.com/")
     ->on_action( sub { join '', @_ } ));
  if ($self->Type =~ /text\/simple/i) {
    $self->MyParser(System::WWW::OpenCalais::TextSimpleParser->new);
  } else {
    $self->MyParser(System::WWW::OpenCalais::RDFParser->new);
  }
}

sub Process {
  my ($self,%args) = @_;
  return unless $args{Contents};
  my $result;
  eval {
    $result = $self->Client->Enlighten
      (
       SOAP::Data->type('string')->name('licenseID')->value($self->licenseID),
       SOAP::Data->type('string')->name('content')->value($args{Contents}),
       SOAP::Data->type('string')->name('paramsXML')->value($self->paramsXML),
      );
  };
  # check for error
  if (defined $result) {
    unless ($result->fault) {
      return $result->result();
    } else {
      print join ', ',
	$result->faultcode,
	  $result->faultstring,
	    $result->faultdetail."\n";
    }
  }
}

sub ProcessAndParse {
  my ($self,%args) = @_;
  my $contents = $self->Process
    (Contents => $args{Contents});
  if (defined $contents and $contents =~ /\S/s) {
    print $contents."\n";
    return $self->MyParser->Parse
      (Contents => $contents);
  } else {
    print "Contents not defined\n";
  }
}

1;
