#!/usr/bin/perl -w

use strict;

use Data::Dumper;
use SOAP::Lite;
use XML::Simple;

my $key = '<REDACTED>';
my $contents = "This is a test of the functionality of the classifier of the OpenCalais SOAP API.";
my $contents = `cat artificialintelligence.txt`;
my $params = '<c:params xmlns:c="http://s.opencalais.com/1/pred/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<c:processingDirectives c:contentType="text/txt" c:outputFormat="xml/rdf">
</c:processingDirectives>
<c:userDirectives c:allowDistribution="true" c:allowSearch="true" c:externalID="testing" c:submitter="FRDCSA">
</c:userDirectives>
<c:externalMetadata>
</c:externalMetadata>
</c:params>';

my $client = SOAP::Lite->new
  (proxy => "http://api.opencalais.com/enlighten/calais.asmx");

# make the call
$client->default_ns("http://clearforest.com/");
$client->on_action( sub { join '', @_ } );

# $client->service('http://api.opencalais.com/enlighten/?wsdl');
# $client->service('file:///var/lib/myfrdcsa/codebases/internal/perllib/System/WWW/OpenCalais/opencalais.wsdl');

my $result = $client->Enlighten
  (
   SOAP::Data->type('string')->name('licenseID')->value($key),
   SOAP::Data->type('string')->name('content')->value($contents),
   SOAP::Data->type('string')->name('paramsXML')->value($params),
  );

# print Dumper($result);

# check for error
unless ($result->fault) {
  print XMLout(XMLin($result->result()))."\n";

} else {
  print join ', ',
    $result->faultcode,
      $result->faultstring,
	$result->faultdetail."\n";
}
