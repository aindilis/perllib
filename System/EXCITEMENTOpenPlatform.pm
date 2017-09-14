package System::EXCITEMENTOpenPlatform;

use Lingua::EN::Sentence;
use PerlLib::SwissArmyKnife;

use Time::HiRes qw(usleep);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / /

  ];

sub init {
  my ($self,%args) = @_;
}

sub StartServer {
  my ($self,%args) = @_;
}

sub StartClient {
  my ($self,%args) = @_;
}

sub RTE {
  my ($self,%args) = @_;
  my @results;
  foreach my $pair (@{$args{Pairs}}) {
    # print Dumper($pair => $pair);
    my $res1 = $self->ProcessPair(Pair => $pair);
    push @results, {
		    T => $pair->{T},
		    H => $pair->{H},
		    Expected => $pair->{Entailment},
		    Got => $res1,
		   };
    print "\n\n\n";
  }
  return
    {
     Success => 1,
     Result => \@results,
    };
}

sub ProcessPair {
  my ($self,%args) = @_;

  my $dir = "/var/lib/myfrdcsa/sandbox/nutcracker-1.0/nutcracker-1.0/candc";

  if (-d ConcatDir($dir,"working/tmp/")) {
    system "mv --backup=numbered ".shell_quote(ConcatDir($dir,"working/tmp"))." ".shell_quote(ConcatDir($dir,"working/backups"));
  }
  MkDirIfNotExists(Directory => ConcatDir($dir,"working/tmp"));

  my $t = $args{Pair}->{T};
  my $h = $args{Pair}->{H};

  WriteFile
    (
     File => ConcatDir($dir,'working/tmp/t'),
     Contents => $t."\n",
    );
  WriteFile
    (
     File => ConcatDir($dir,'working/tmp/h'),
     Contents => $h."\n",
    );
  WriteFile
    (
     File => ConcatDir($dir,'working/tmp/t.met'),
     Contents => "<META>rte\n".$t."\n",
    );
  WriteFile
    (
     File => ConcatDir($dir,'working/tmp/h.met'),
     Contents => "<META>rte\n".$t."\n".$h."\n",
    );

  ApproveCommands
    (
     Commands =>
     [
      'cd '.shell_quote($dir).' && bin/candc --input working/tmp/t.met --output working/tmp/t.ccg --models models/boxer --candc-printer boxer',
      'cd '.shell_quote($dir).' && bin/candc --input working/tmp/h.met --output working/tmp/h.ccg --models models/boxer --candc-printer boxer',
      'cd '.shell_quote($dir).' && bin/boxer --input working/tmp/t.ccg --output working/tmp/t.drs --resolve --vpe --box',
      'cd '.shell_quote($dir).' &&  bin/boxer --input working/tmp/h.ccg --output working/tmp/h.drs --resolve --vpe --box',
      'mkdir -p '.ConcatDir($dir,'working/tmp/hide'),
      'cp -ar '.ConcatDir($dir,'working/tmp').'/* '.ConcatDir($dir,'working/tmp/hide'),
      'rm '.ConcatDir($dir,'working/tmp').'/*',
      'cp '.ConcatDir($dir,'working/tmp/hide/t').' '.ConcatDir($dir,'working/tmp'),
      'cp '.ConcatDir($dir,'working/tmp/hide/h').' '.ConcatDir($dir,'working/tmp'),
      'cd '.shell_quote($dir).' && bin/nc &',
      # # # make a watchdog that kills everything in nutcracker if its
      # # # taking too long and just gives a timeout result or something,
      # # # maybe with state.
     ],
     Method => 'serial',
     AutoApprove => 1,
    );

  my $extensions = [qw(met drs ccg)];
  my $items = [qw(t h)];
  my $count = 0;
  my $seen = {};
  do {
    foreach my $item (@$items) {
      foreach my $extension (@$extensions) {
	if (! $seen->{"$item.$extension"}) {
	  if (-f ConcatDir($dir,"working/tmp/$item.$extension")) {
	    my $c = 'cp '.ConcatDir($dir,"working/tmp/hide/$item.$extension").' '.ConcatDir($dir,"working/tmp");
	    print "$c\n";
	    system $c;
	    ++$count;
	    $seen->{"$item.$extension"} = 1;
	  }
	}
      }
    }
  } while ($count < 6);

  # now read the result and send it
  my $predictionfile = "/var/lib/myfrdcsa/sandbox/nutcracker-1.0/nutcracker-1.0/candc/working/tmp/prediction.txt";
  my $processes = 100;
  do {
    $processes = $self->GetNumberOfProcesses(Regex => 'bin/nc');
    if ($processes) {
      usleep(500);
    }
  } while ($processes and ! -f $predictionfile);

  my $prediction = "Failed";
  if (-f $predictionfile) {
     $prediction = read_file($predictionfile);
  }

  system 'mv --backup=numbered '.shell_quote(ConcatDir($dir,"working/tmp")).' '.shell_quote(ConcatDir($dir,"working/processed"));
  chomp $prediction;
  return
    {
     Prediction => $prediction,
    };
}

sub GetNumberOfProcesses {
  my ($self,%args) = @_;
  my $regex = $args{Regex};
  my $result = `ps auxwww | grep -E '$regex' | grep -vE '(grep|auxwww)'`;
  chomp $result;
  my @lines = split /\n/, $result;
  return scalar @lines;
}

1;
