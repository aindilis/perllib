package PerlLib::Util::Misc;

use PerlLib::SwissArmyKnife;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(IsRunningP HasProcess Killall MyDoCommand
	     MyDoCommandAsync);

sub IsRunningP {
  my (%args) = @_;
  return HasProcess
    (
     Search => $args{Search},
     Command => $args{Command},
    );
}

sub HasProcess {
  my (%args) = @_;
  my $search = $args{Search};
  my $qsearch = shell_quote($search);
  my $command = $args{Command} || "ps auxwww | grep -E $qsearch | grep -v grep | wc -l";
  $count = `$command`;
  chomp $count;
  print "Command: $command\n";
  print "Count: $count\n";
  my $res = ($count > 0);
  return $res;
}

sub Killall {
  my (%args) = @_;
  if ($args{Pattern}) {
    my $qpattern = shell_quote($args{Pattern});
    my $search = "ps auxwww | grep -E $qpattern | grep -v grep | awk '{print \$2}'";
    my $res1 = `$search`;
    my @pids = split /\n/, $res1;
    if (@pids) {
      my $command = 'sudo kill -9 '.join(' ',@pids);
      print $command."\n";
      MyDoCommand
	(
	 Simulate => $args{Simulate},
	 Command => $command,
	);
    }
  }
}

sub MyDoCommand {
  my (%args) = @_;
  if (! $args{Simulate}) {
    ApproveCommands
      (
       Commands => [$args{Command}],
       AutoApprove => 1,
      );
  } else {
    print 'Command: '.$args{Command}."\n";
  }
}

sub MyDoCommandAsync {
  my (%args) = @_;
  MyDoCommand
    (
     Simulate => $args{Simulate},
     Command => $args{Command}.' &',
    );
}

1;
