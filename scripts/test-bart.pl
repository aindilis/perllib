#!/usr/bin/perl -w

use System::BART;

use Data::Dumper;

my $bart = System::BART->new;

my $string = "BART internally works with a standoff-based
representation based on the format of MMAX2 (an annotation tool for
coreference and other discourse annotation). The easiest way of
getting text into BART and coreference chains out is the REST-based
web service that is part of BART and allows you to easily import raw
text, process it, and export the result as inline XML.";

$bart->StartServer;
print Dumper
  ($bart->CoreferenceResolution
   (
    Text => $string,
   ));
# bart->StopServer;



