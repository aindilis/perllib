package PerlLib::ParallelDownload;

use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / /

  ];

sub init {
  my ($self,%args) = @_;

}

sub Download {
  my ($self,%args) = @_;
  my @downloads = @{$args{Downloads}};
  my $actualcount = scalar @downloads;
  my @pids;
  my $timeout = 8;
  foreach my $i (0..$#downloads) {
    my $amchild = 1;
    # now what do we want here
    defined($pids[$i] = fork()) or die "Cannot fork()!\n";
    # now what do we want here
    $amchild = ! $pids[$i];
    if ($amchild) {
      my $download = $downloads[$i];
      print Dumper({Download => $download});
      my $url = $download->{Source};
      my $location = $download->{Target};
      my $command = "wget -T 6 \"".shell_quote($url)."\" -O ".shell_quote($location)." >/dev/null 2>/dev/null";
      print $command."\n";
      system $command;
      exit(0);
    }
  }
  my $time = time;
  my $size;
  my $continue = 1;
  do {
    $size = 0;
    foreach my $item (@downloads) {
      if (-f $item->{Target}) {
	++$size;
      }
    }
    if ($size != $actualcount) {
      print "<$size><$actualcount>\n";
      sleep 1;

    }
    $continue = ((time - $time) < ($timeout * 1.5));
  } while ($size < $actualcount and $continue);

  # okay supposedly we are done
  if (! $continue) {
    return {
	    Success => 0,
	    Reason => "Timeout!\n",
	   };
  } else {
    return {
	    Success => 1,
	   };
  }
}

1;
