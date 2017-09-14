#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;
use System::Xvfb;

my $xvfb = System::Xvfb->new();

sub Test1 {
  my (%args) = @_;
  my $display = ':1';

  $xvfb->StartXvfb
    (
     Simulate => $args{Simulate},
     Display => $display,
     StartX11vnc => 1,
     StartXvncViewer => 1,
    );

  print Dumper($xvfb->Commands);
  sleep 10;

  $xvfb->StopAll
    (
     Simulate => $args{Simulate},
     Display => ':1',
    );
}

sub Test2 {
  my (%args) = @_;

  my $display = ':1';

  # $xvfb->StartXvfb
  #   (
  #    Display => $display,
  #   );
  # $xvfb->StopXvfb
  #   (
  #    Display => $display,
  #   );

  # $xvfb->StartXvfb
  #   (
  #    Display => $display,
  #    StartX11vnc => 1,
  #   );
  # $xvfb->StopXvfb
  #   (
  #    Display => $display,
  #   );

  # $xvfb->StartXvfb
  #   (
  #    Display => $display,
  #    StartX11vnc => 1,
  #    StartXvncViewer => 1,
  #   );
  # sleep 30;
  # $xvfb->StopXvfb
  #   (
  #    Display => $display,
  #   );

  # $xvfb->StartXvfb
  #   (
  #    Display => $display,
  #    StartX11vnc => 1,
  #    StartXvncViewer => 1,
  #   );
  # $xvfb->RunCommandAsynchonous
  #   (
  #    Display => $display,
  #    Command => 'xeyes',
  #   );
  # sleep 30;
  # $xvfb->StopAll
  #   (
  #    Display => $display,
  #   );
}

# Test1(Simulate => 1);
# Test1(Simulate => 0);

Test2();

$xvfb->ListRunningComponents();

