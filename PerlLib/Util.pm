package PerlLib::Util;

use Manager::Dialog qw (ApproveStrongly SubsetSelect QueryUser ApproveCommands );

use Data::Dumper;
use Error qw(:try);
use File::Slurp;
use File::Stat;
use Proc::ProcessTable;
use String::Similarity;

require Exporter;
@ISA = qw(Exporter);

@EXPORT = qw ( LookupSimilar Date SaveDataToFile ExistsRecent DeDumper
DeDumperFile PidsForProcess KillProcesses DumperNoParent
ExtractSlidingWindow MessageStart MessageFinish See SeeDeeply Min Max
ChooseFirst TestPids RandomizeList GetCommandLineForCurrentProcess
SeeDumper );

sub LookupSimilar {
  my (%args) = (@_);
  my ($limit,$similarity,@matches) = (0,0,());
  my $depth = $args{Depth} || 15;

  if (0) {
    foreach my $key (keys %args){
      print "<$key $args{$key}>\n";
    }
  }

  if ($args{Function}) {
    foreach my $item (@{$args{Candidates}}) {
      $candidate =  &{$args{Function}}($item);
      $similarity = similarity($args{Query},$candidate,0);
      push @matches, [$candidate, sprintf("%0.5f",$similarity)];
    }
  } else {
    foreach my $candidate (@{$args{Candidates}}) {
      $similarity = similarity($args{Query},$candidate,0);
      push @matches, [$candidate, sprintf("%0.5f",$similarity)];
    }
  }

  my @tmp = sort {$b->[1] <=> $a->[1]} @matches;
  my @sorted = splice(@tmp,0,$depth);
  my @items = map {"<<<" . $_->[1] . ">\t<" . $_->[0] . ">>>"} @sorted;
  my @ans = SubsetSelect(Set => \@items,
			 Selection => {},
			 Type => "int");
  foreach my $ans (@ans) {
    return $sorted[$ans]->[0];
  }
}

sub Date {
  my (%args) = @_;
  my $date = `date "+%Y%m%d%H%M%S"`;
  chomp $date;
  return $date;
}

sub SaveDataToFile {
  my %args = @_;
  my $f = $args{File};
  my $ok = 0;
  if (-e $f) {
    if (ApproveStrongly("Overwrite file <$f>?")) {
      $ok = 1;
    }
  } else {
    $ok = 1;
  }
  if ($ok) {
    my $OUT;
    if ($args{Append}) {
      open(OUT,">>$f") or die "Cannot open file $f\n";
    } else {
      open(OUT,">$f")  or die "Cannot open file $f\n";
    }
    print OUT $args{Data};
    close(OUT);
  }
}

sub ExistsRecent {
  my %args = @_;
  my $f = $args{File};
  my $r = {};
  if (-f $f) {
    $r->{Exists} = 1;
    my $stat = File::Stat->new($f);
    my $diff = time - $stat->mtime;
    if ($diff) {
      if ($diff < $args{Within}) {
	$r->{Recent} = 1;
      } else {
	$r->{Recent} = 0;
      }
    }
  } else {
    $r->{Exists} = 0;
  }
  return $r;
}

sub RandomizeList {
  my @m = @_;
  my @l;
  while (@m) {
    my $i = int(rand(scalar @m));
    push @l, $m[$i];
    $m[$i] = $m[$#m];
    pop @m;
  }
  return @l;
}

sub DeDumperFile {
  my $filename = shift;
  my $c = read_file($filename);
  return DeDumper($c);
}

sub DeDumper {
  my $item = shift;
  my $it;
  try {
    $VAR1 = undef;
    # print Dumper($item);
    eval $item;

    # FIXME: it seems for some applications that they rely on this
    # being only evaled once, I am guying CycL stuff, whereas others
    # depend on two evals, figure out the difference, perhaps make an
    # argument and separate all instances

    # FIXME: it just occurred to me that maybe some depend on n evals.

    eval $item;
    # print Dumper($VAR1);
    $it = $VAR1;
    $VAR1 = undef;
  }
    catch Error with {
      print Dumper({Problem => (shift)});
    };
  return $it;
}

sub DeDumperOld {
  my $item = shift;
  $VAR1 = undef;
  # print Dumper($item);
  eval $item;
  eval $item;
  my $it = $VAR1;
  $VAR1 = undef;
  return $it;
}

sub PidsForProcessOld {
  my %args = @_;
  my @pids;
  # fix this

  my $sample1 = "andrewdo 11701  0.2 27.7 1505288 1071032 pts/8 Sl+  01:07   1:47 ";
  my $length1 = length($sample1);
  foreach my $line (split /\n/, `ps aux --cols=10000`) {
    my $process = $line;
    $process =~ s/^.{$length1}//;
    print Dumper({
		  Process1 => $process,
		  Process2 => $args{Process},
		 }) if 0;
    if ($process eq $args{Process}) {
      # print $line."\n";
      if (1) {
	my @list = split /\s+/, $line;
	push @pids, $list[1];
      } else {
	my $sample2 = "andrewdo  ";
	my $length2 = length($sample2);
	my $pid = $line;
	$pid =~ s/^.{$length2}//;
	# print Dumper($pid);
	if ($pid =~ /^(\d+)/) {
	  push @pids, $1;
	}
      }
    }
  }
  return \@pids;
}

sub PidsForProcess {
  my %args = @_;
  my $table = new Proc::ProcessTable( 'cache_ttys' => 1 );
  my @pids;
  foreach my $entry (@{$table->table}) {
    if ($entry->cmndline eq $args{Process}) {
      push @pids, $entry->pid;
    }
  }
  return \@pids;
}

sub KillProcesses {
  my %args = @_;
  my $pids = PidsForProcess
    (
     Process => $args{Process},
     Verbose => 1,
    );
  if (scalar @$pids) {
    ApproveCommands
      (
       Commands => [
		    "kill -9 ".join(" ",@$pids),
		   ],
       Method => "parallel",
       AutoApprove => $args{AutoApprove},
      );
  } else {
    print "No processes found\n";
  }
}

sub DumperNoParent {
  my (%args) = @_;
  my $item = $args{Item};
  my $ref = ref $item;
  if ($ref eq "ARRAY") {
    my $array = [];
    foreach my $subitem (@$item) {
      push @$array, DumperNoParent
	(
	 Item => $subitem,
	 Allowed => $args{Allowed},
	);
    }
    return $array;
  } elsif ($ref eq "HASH") {
    my $hash = {};
    foreach my $key (keys %$item) {
      $hash->{$key} = DumperNoParent
	(
	 Item => $item->{$key},
	 Allowed => $args{Allowed},
	);
    }
    return $hash;
  } else {
    foreach my $allowed (@{$args{Allowed}}) {
      if ($ref eq $allowed) {
	my $hash = {};
	foreach my $key (keys %$item) {
	  $hash->{$key} = DumperNoParent
	    (
	     Item => $item->{$key},
	     Allowed => $args{Allowed},
	    );
	}
	return $hash;
      }
    }
    if ($ref =~ /./) {
      # return the class name
      return "<<<$ref>>>";
    } else {
      # return the item
      return $item;
    }
  }
}

sub ExtractSlidingWindow {
  my %args = @_;
  my $items = $args{Items};
  my $min = $args{Min};
  my $max = $args{Max};
  my @windows;
  my $start = 0;
  my @window;
  while (@$items or scalar @window >= $min) {
    if (scalar @$items) {
      push @window, shift @$items;
    }
    my $size = scalar @window;
    if ($size < $min) {
      if (scalar @$items) {
	next;
      } else {
	exit(0);
      }
    }

    if (! $start) {
      if (($size == $max) or ! @$items) {
	$start = 1;
      }
    }
    if ($start) {
      # print join(" ",map {"<$_>"} @window)."\n";
      my $size2 = scalar @window;
      foreach my $i ($min .. $max) {
	if ($i <= $size2) {
	  my @copy = @window;
	  my @subwindow = splice @copy, 0, $i;
	  # print join(" ",map {"<$_>"} @subwindow)."\n";
	  push @windows, \@subwindow;
	}
      }
    }

    if ($size >= $max or ! @$items) {
      shift @window;
    }
  }
  return \@windows;
}

sub MessageStart {
  my $item = shift;
  if (! defined $UNIVERSAL::_message_stack) {
    $UNIVERSAL::_message_stack = [];
  }
  push @{$UNIVERSAL::_message_stack}, $item;
  print "$item...\n";
}

sub MessageFinish {
  my $item = shift;
  if (! defined $UNIVERSAL::_message_stack) {
    print "ERROR: no Start info (UNIVERSAL::_message_stack not defined)\n";
  } else {
    my $item = pop @{$UNIVERSAL::_message_stack};
    print "Done $item.\n";
  }
}

# sub SeeEcho {
#   print Dumper(\@_);
#   return @_;
# }

sub See {
  my @args = @_;
  my @result = caller(1);
  print Dumper
    ({
      Item => \@args,
      Caller => $result[3],
      File => $result[1],
     });
}

sub SeeDeeply {
  my @args = @_;
  my $tmp = $Data::Dumper::Deepcopy;
  $Data::Dumper::Deepcopy = 1;
  my $res = See(\@args);
  $Data::Dumper::Deepcopy = $tmp;
  return $res;
}

sub SeeDumper {
  my @args = @_;
  my @result = caller(1);
  my $existingsortkeys;
  if (defined $PerlLib::Util::SortKeys) {
    $existingsortkeys = $Data::Dumper::Sortkeys;
    $Data::Dumper::Sortkeys = $PerlLib::Util::SortKeys;
  }
  my $dumper = Dumper
    ({
      Item => \@args,
      Caller => $result[3],
      File => $result[1],
     });
  if (exists $args{SortKeys}) {
    $Data::Dumper::Sortkeys = $existingsortkeys;
  }
  return $dumper;
}

sub Min {
  my %args = @_;
  my $min;
  foreach my $item (@{$args{Items}}) {
    if (! defined $min or $item < $min) {
      $min = $item;
    }
  }
  return $min;
}

sub Max {
  my %args = @_;
  my $max;
  foreach my $item (@{$args{Items}}) {
    if (! defined $max or $item > $max) {
      $max = $item;
    }
  }
  return $max;
}

sub ChooseFirst {
  my (%args) = @_;
  while (my $dir = shift @{$args{Items}}) {
    if (-d $dir or -f $dir) {
      return $dir;
    }
  }
}

sub GetCommandLineForCurrentProcess {
  my (%args) = @_;
  my $t = new Proc::ProcessTable( 'cache_ttys' => 1 );
  foreach $p (@{$t->table}) {
    if ($p->{pid} == $$) {
      return $p->{cmndline};
    }
  }
}

1;
