#!/usr/bin/perl -w

use System::APE;

use Data::Dumper;

my $ape = System::APE->new
  ();

$ape->StartServer;
$ape->StartClient();

print "Accepting...\n";
while (<STDIN>) {
  chomp;
  print Dumper({Input => $_});
  print Dumper
    ($ape->Parse
     (Text => $_));
}
