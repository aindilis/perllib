#!/usr/bin/perl -w

use System::OpenEphyra;

use Data::Dumper;

my $oe = System::OpenEphyra->new;

$oe->StartOpenEphyra;

sleep 1;

# foreach my $item (1..10) {
  # my $q = "What does $item mean?";

while (1) {
  print "Input:::\n";
  my $q = <STDIN>;
  print "$q\n";
  sleep 1;
  print Dumper($oe->AskQuestion(Question => $q));
}

$oe->StopServer;
