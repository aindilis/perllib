#!/usr/bin/perl -w

use System::Cyc;

my $cyc = System::Cyc->new();
$cyc->Connect();
while (my $line = <STDIN>) {
  $cyc->Send(Command => $line);
  my $res = $cyc->Receive();
  print $res;
}
