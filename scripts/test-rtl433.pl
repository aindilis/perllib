#!/usr/bin/perl -w

use System::Sensor::RTL433;

use PerlLib::SwissArmyKnife;

my $sensor = System::Sensor::RTL433->new();

$sensor->StartServer;
while (1) {
  $sensor->ListenForTransmissions();
}
