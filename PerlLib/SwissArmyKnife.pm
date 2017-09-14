package PerlLib::SwissArmyKnife;

use Manager::Dialog qw(QueryUser QueryUser2 ComplexQueryUser Verify
  Approve Approve2 ApproveStrongly ApproveCommand ApproveCommand2
  Choose Choose2 ChooseSpecial EasyQueryUser PrintList Message
  ApproveCommands ChooseHybrid ChooseOrCreateNew SubsetSelect
  FamilySelect ChooseByProcessor Continue);

use MyFRDCSA qw(ConcatDir);
use PerlLib::Util;

use Data::Dumper;
use FileHandle;
use File::Basename;
use File::DirList;
use File::Slurp;
use File::Stat qw/:stat/;
use File::Temp qw(tempfile tempdir mktemp);
use Path::Iterator::Rule;
use String::ShellQuote;
use Text::Wrap;

BEGIN {
  use File::Which 'which';
  use Carp;
  $SIG{ __DIE__ } = sub { Carp::confess( @_ ) };
}

require Exporter;
@ISA = qw(Exporter);

@EXPORT = qw (QueryUser QueryUser2 ComplexQueryUser Verify Approve
  Approve2 ApproveStrongly ApproveCommand ApproveCommand2 Choose
  Choose2 ChooseSpecial EasyQueryUser PrintList Message
  ApproveCommands ChooseHybrid ChooseOrCreateNew SubsetSelect
  FamilySelect ChooseByProcessor Continue read_file shell_quote
  dirname basename tempfile tempdir Dumper DoCommand LookupSimilar
  Date SaveDataToFile ExistsRecent DeDumper DeDumperFile
  PidsForProcess KillProcesses DumperNoParent read_file_dedumper
  WriteFile write_file_dumper See SeeDeeply Min Max ChooseFirst stat
  GetSignalFromUserToProceed SummarizeData MkDirIfNotExists ConcatDir
  SubtractList RandomizeList GetCommandLineForCurrentProcess
  DateTimeStamp IsMounted SafelyRemove SeeDumper CheckWhich
  GetDateYYYYMMDD NewTempFileName WriteToTempFile NotYetImplemented
  ClearDumper ListUnion MkdirP FixMe PackageInstalled
  PackagesInstalled RemoveLeadingAndTrailingWhitespace
  ListFilesInDirectory ListFilesInDirectoryRecursively
  GetPasswordFromFile PrologDateTimeStamp);

# SortBy

sub DoCommand {
  my $command = shift;
  print $command."\n";
  system $command;
}

sub WriteFile {
  my %args = @_;
  if ($args{Message}) {
    print $args{Message};
  }
  my $res1 = write_file($args{File},$args{Contents});
  if (! $res1 and $args{ErrorMessage}) {
    if (exists $args{ErrorMessage}) {
      print $args{ErrorMessage};
    }
  } else {
    if (exists $args{SuccessMessage}) {
      print $args{SuccessMessage};
    }
  }
}

sub write_file_dumper {
  my %args = @_;
  WriteFile
    (
     File => $args{File},
     Contents => Dumper($args{Data}),
    );
}

sub read_file_dedumper {
  my $file = shift;
  warn "No file <$file>" unless -f $file;
  my $c = read_file($file);
  # print $c."\n";
  return DeDumper($c);
}

sub GetSignalFromUserToProceed {
  my (%args) = @_;
  if ($args{PreMessage}) {
    print $args{PreMessage}."\n";
  }
  my $it = <STDIN>;
  $it = undef;
  if ($args{PostMessage}) {
    print $args{PostMessage}."\n";
  }
}

sub SummarizeData {
  my %args = @_;
  my $item = $args{Item};
  my $ref = ref $item;
  print "<$ref>\n";
  if ($ref eq "ARRAY") {
    my $scalar = scalar @$item;
    # print "Size: $scalar\n";
    foreach my $item2 (@$item) {
      my $ref2 = ref $item2;
      print "\t$ref2\n";
    }
  } elsif ($ref eq "HASH") {
    foreach my $key (keys %$item) {
      print "\t$key\n";
    }
  }
}

sub MkDirIfNotExists {
  my %args = @_;
  my $d = $args{Directory};
  # first make sure it is well formed
  # skip for now

  # make sure a file or directory does not already exist
  if (-f $d) {
    return {
	    Success => 0,
	    Error => "File already exists",
	   };
  }
  if (-d $d) {
    return {
	    Success => 1,
	    # Error => "Directory already exists",
	   };
  }

  # try to make it
  system "mkdir -p ".shell_quote($d);

  # test if it is there and return result
  if (-d $d) {
    return {
	    Success => 1,
	   };
  }
  return {
	  Success => 0,
	 };
}

sub SubtractList {
  my %args = @_;
  my ($A,$B) = ($args{A},$args{B});
  my %C;
  my @list;
  foreach my $a (@$A) {
    $C{$a} = 1;
  }
  foreach my $b (@$B) {
    $C{$b} = 2;
  }
  foreach my $c (keys %C) {
    if ($C{$c} == 1) {
      push @list, $c;
    }
  }
  return @list;
}

sub GetDateYYYYMMDD {
  my (%args) = @_;
  my $date = `date "+%Y%m%d"`;
  $date =~ s/^\s*//;
  $date =~ s/\s*$//;
  return $date;
}

sub DateTimeStamp {
  my %args = @_;
  my $datetimestamp = `date "+%Y%m%d%H%M%S"`;
  chomp $datetimestamp;
  return $datetimestamp;
}

sub IsMounted {
  my %args = @_;
  my $command = "mount | grep ".shell_quote($args{Item});
  my $result = `$command`;
  if ($result =~ /./) {
    return 1;
  }
  return 0;
}

sub SafelyRemove {
  my %args = @_;
  my $items = $args{Items};
  my @files;
  my @dirs;
  foreach my $item (@$items) {
    if (-f $item) {
      push @files, $item;
    } elsif (-d $item) {
      push @dirs, $item;
    } else {
      print "Item not found, cannot remove <$item>\n";
    }
  }
  if (scalar @files or scalar @dirs) {
    print Dumper({Files => \@files, Dirs => \@dirs});
    if ($args{AutoApprove} || Approve("Delete these items?")) {
      if (scalar @files) {
	my $command = "rm ".join(" ",map {shell_quote($_)} @files);
	print "$command\n";
	system $command;
      }
      foreach my $dir (@dirs) {
	if ($dir !~ /\/\.\.$/) {
	  $command = "rm -rf ".shell_quote($dir);
	  print "$command\n";
	  system $command;
	}
      }
    }
  } else {
    print "Nothing to remove\n";
  }
}

sub CheckWhich {
  my %args = @_;
  my $WHICH = which($args{Name});
  $WHICH or die("Is $args{Name} installed? Cannot find bin path to $args{Name}.");
}

sub NewTempFileName {
  my (%args) = @_;
  my $rootdir = "/tmp";
  my ($unopened_file, $file);
  do {
    $unopened_file = mktemp( $args{Pattern} || "$rootdir/tmp-XXXXXXXX" );
    # $file = ConcatDir($rootdir,$unopened_file);
    $file = $unopened_file;
  } while (-f $file);
  return $file;
}

sub WriteToTempFile {
  my (%args) = @_;
  my $file = NewTempFileName( Pattern => $args{Pattern} );
  my $fh = IO::File->new();
  $fh->open(">$file") or
    warn "Cannot open <$file> for writing.\n";
  print $fh $args{Contents};
  $fh->close();
  return $file;
}

sub NotYetImplemented {
  my (%args) = @_;
  warn SeeDumper("Not yet implemented");
  # FIXME: maybe throw an error?
}

sub ClearDumper {
  my (@args) = @_;
  my $previoususeqq = $Data::Dumper::Useqq;
  my $previouspurity = $Data::Dumper::Purity;
  my $previousdeepcopy = $Data::Dumper::Deepcopy;
  $Data::Dumper::Useqq = 1;
  $Data::Dumper::Purity = 1;
  $Data::Dumper::Deepcopy = 1;
  my $string = Dumper(@args);
  Data::Dumper->Useqq($previoususeqq);
  Data::Dumper->Purity($previouspurity);
  Data::Dumper->Deepcopy($previousdeepcopy);
  return $string;
}

sub ListUnion {
  my (@args) = @_;
  my $seen = {};
  foreach my $list (@args) {
    foreach my $item (@$list) {
      $seen->{ClearDumper($item)} = $item;
    }
  }
  return [values %$seen];
}

sub MkdirP {
  my @dirs = @_;
  my $command1 = 'mkdir -p '.join(' ',map {shell_quote($_)} @dirs);
  print $command1."\n";
  system $command1;
}

sub FixMe {
  my ($message) = @_;
  print "FIXME: $message\n";
  # in the future do more than this
}

sub PackageInstalled {
  my (%args) = @_;
  my $package = $args{Package};
  # print Dumper({Package => $package});
  if ($args{DpkgOutput} =~ /^ii\s+$package\s/m) {
    # print "Package installed: $package\n";
    return 1;
  } else {
    # print "Package not installed: $package\n";
    return 0;
  }
}

sub PackagesInstalled {
  my (%args) = @_;
  if (scalar @{$args{Packages}}) {
    my $dpkgoutput = `dpkg -l`;
    my $allinstalled = 1;
    foreach my $package (@{$args{Packages}}) {
      unless (PackageInstalled(
			       DpkgOutput => $dpkgoutput,
			       Package => $package,
			      )) {
	# print "Package not installed: $package\n";
	$allinstalled = 0;
      }
    }
    return {
	    Success => 1,
	    Result => $allinstalled,
	   };
  } else {
    return {
	    Success => 0,
	    Reason => "No packages given",
	   };
  }
}

sub RemoveLeadingAndTrailingWhitespace {
  my (%args) = @_;
  my $text = $args{Text};
  $text =~ s/^\s*//sg;
  $text =~ s/\s*$//sg;
  return $text;
}

sub ListFilesInDirectory {
  my (%args) = @_;
  my $directory = $args{Directory};
  my @matches;
  if (-d $directory) {
    my $results = File::DirList::list($directory,'n',0,0,0);
    foreach my $entry (@$results) {
      my $filename = $entry->[13];
      if ($args{NoSubdirectories}) {
	if ($entry->[14] == 0) {
	  push @matches, $filename;
	}
      } elsif ($args{OnlySubdirectories}) {
	if ($entry->[14] == 1) {
	  push @matches, $filename;
	}
      } else {
	push @matches, $filename;
      }
    }
    if ($args{ResultType} eq 'hash') {
      my $hash;
      foreach my $file (@matches) {
	$hash->{$file} = 1;
      }
      return
	{
	 Success => 1,
	 Results => $hash,
	};

    } else {
      return
	{
	 Success => 1,
	 Results => \@matches,
	};
    }
  } else {
    FixMe("throw error about directory not existing.");
  }
}

sub GetPasswordFromFile {
  my (%args) = @_;
  my $qfilename = shell_quote($args{Filename});
  my $result = `cat $qfilename`;
  chomp $result;
  return $result;
}

sub PrologDateTimeStamp {
  my (%args) = @_;
  my $prologtext = `date "+[['-',['-',%Y,%m],%d],[':',[':',%H,%M],%S]]"`;
  $prologtext =~ s/\b0+//sg;

  chomp $prologtext;
  my $result;
  my $toeval = '$result = '.$prologtext.';';
  # print $toeval."\n";
  eval $toeval;
  eval $toeval;
  # my $tmp1 = [['-',['-',2017,04],14],[':',[':',22,18],55]];
  print Dumper({
		ToEval => $toeval,
		Result => $result,
		Tmp1 => $tmp1,
	       }) if 0;
  return $result;
}

sub MyHasProcess {
  my ($self,%args) = @_;
  my $search = $args{Search};
  my $command = $args{Command} || "ps auxwww | grep '$search' | grep -v grep | wc -l";
  $count = `$command`;
  chomp $count;
  my $res = ($count > 0);
  return $res;
}

sub ListFilesInDirectoryRecursively {
  my (%args) = @_;
  my $rule = Path::Iterator::Rule->new;
  # $rule->file->size(">10k");
  my $next = $rule->iter( @{$args{Dirs}} );
  my @results;
  while ( defined( my $file = $next->() ) ) {
    push @results, $file;
  }
  return \@results;
}

1;
