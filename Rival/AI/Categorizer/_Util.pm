package Rival::AI::Categorizer::_Util;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw (DoCmd);

my $debug = 0;

sub DoCmd {
  my $command = shift;
  print $command."\n" if $debug;
  system $command;
}

1;
