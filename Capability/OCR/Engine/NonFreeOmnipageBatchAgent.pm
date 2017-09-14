package Capability::OCR::Engine::NonFreeOmnipageBatchAgent;

use Manager::Dialog qw(ApproveCommands);

use Data::Dumper;
use File::Stat;
use String::ShellQuote;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Origin Destination OCRFolderWatch OCRFolderWatchOutput Rewrite Debug AutoApprove /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Origin($args{Origin});
  $self->Destination($args{Destination});
  $self->OCRFolderWatch($args{OCRFolderWatch});
  $self->OCRFolderWatchOutput($args{OCRFolderWatchOutput});
  $self->Rewrite($args{Rewrite});
  $self->Debug($args{Debug} || 0);
  $self->AutoApprove($args{AutoApprove} || 1);
}

sub StartServer {
  my ($self,%args) = @_;
  # just verify that the virtualmachine is running
  # /usr/lib/virtualbox/VirtualBox --comment Windows XP (personal copy of OI)
}

sub StartClient {
  my ($self,%args) = @_;
}

sub OCR {
  my ($self,%args) = @_;

}

sub MakeSearchablePDF {
  my ($self,%args) = @_;
  my $inputfile = $args{InputFile};
  if ($self->Debug) {
    ApproveCommands(
		    Method => "parallel",
		    Commands => ["xpdf ".shell_quote($inputfile)],
		    AutoApprove => $self->AutoApprove,
		   );
  }
  my $sourcedir = $self->OCRFolderWatch;
  my $targetdir = $self->OCRFolderWatchOutput;

  my $finaldestination;
  if (defined $args{Base}) {
    $finaldestination = $self->Destination."/".$args{Base};
  } else {
    $finaldestination = $self->Destination;
  }

  my $newhead = $self->Rewrite->(Head => $args{Head});
  my $searchablepdffile = $finaldestination."/".$newhead;
  if (-f $searchablepdffile) {
    print "ALREADY COMPLETED FILE <<<".$searchablepdffile.">>>\n";
    return;
  }

  if (! -d $finaldestination) {
    my $command0 = "mkdir -p ".shell_quote($finaldestination);
    ApproveCommands(
		    Method => "parallel",
		    Commands => [$command0],
		    AutoApprove => $self->AutoApprove,
		   );
  }

  # just copy it on over if it is already searchable
  if ($self->SearchableP(InputFile => $inputfile)) {
    my $command1 = join(" ","cp",shell_quote($inputfile),shell_quote($finaldestination));
    ApproveCommands(
		    Method => "parallel",
		    Commands => [$command1],
		    AutoApprove => $self->AutoApprove,
		   );
  } else {
    # first convert the file, blah blah, don't do this now
    # "cp $inputfile $sourcedir";
    my $command1 = join(" ","cp",shell_quote($inputfile),shell_quote($sourcedir));
    ApproveCommands(
		    Method => "parallel",
		    Commands => [$command1],
		    AutoApprove => $self->AutoApprove,
		   );

    my $omnipageinputfile = "$sourcedir/$newhead";
    my $omnipageoutputfile = "$targetdir/$newhead";

    my $res = $self->WaitForFileToFinish
      (
       OmnipageOutputFile => $omnipageoutputfile,
      );

    if ($res->{Success}) {
      # I guess we're supposed to return the contents, or at least move it to the appropriate place
      # "mv $omnipageoutputfile $destination";
      my $command2 = join(" ","mv",shell_quote($omnipageoutputfile),shell_quote($finaldestination));
      my $command3 = join(" ","rm",shell_quote($omnipageinputfile));
      ApproveCommands(
		      Method => "parallel",
		      Commands => [$command2,$command3],
		      AutoApprove => $self->AutoApprove,
		     );
    } else {
      print Dumper({"HUGE ERROR" => \%args});
    }
  }
}

sub SearchablePdfP {
  my ($self,%args) = @_;
  my $inputfile = shell_quote($args{InputFile});
  my @words = split /\W+/, `pdftotext $inputfile - -f 1 -l 5`;
  if ((scalar @words) > 10) {
    # assume it's a real document
    return 1;
  } else {
    return 0;
  }
}

sub WaitForFileToFinish {
  my ($self,%args) = @_;
  # check on the existence of this file, check on its size
  print "Waiting on <<<".$args{OmnipageOutputFile}.">>>...\n";
  while (! -e $args{OmnipageOutputFile}) {
    sleep 5;
  }
  my $stat;
  my $count = 0;
  my $lastsize = 0;
  do {
    $stat = File::Stat->new($args{OmnipageOutputFile});
    my $size = $stat->size;
    if (($size > 0) and ($size == $lastsize)) {
      ++$count;
      print "Looking good...\n";
    } else {
      if ($count) {
	print "Oops, still more...\n";
      }
      $count = 0;
    }
    $lastsize = $size;
    sleep 5;
  } while ($count < 5);
  print "Done waiting on <<<".$args{OmnipageOutputFile}.">>>\n";
  return {
	  Success => 1,
	 };
}

sub OCRExtract {
  my ($self,%args) = @_;

}

sub OCRFile {
  my ($self,%args) = @_;

  # here is the type

  # 1.htm
  # 1_Dir

  my $inputfile = $args{InputFile};
  if ($self->Debug) {
    # # figure out a universal file viewer
    #     ApproveCommands(
    # 		    Method => "parallel",
    # 		    Commands => ["xpdf ".shell_quote($inputfile)],
    # 		    AutoApprove => $self->AutoApprove,
    # 		   );
  }

  my $sourcedir = $self->OCRFolderWatch;
  my $targetdir = $self->OCRFolderWatchOutput;

  my $finaldestination;
  if (defined $args{Base}) {
    $finaldestination = $self->Destination."/".$args{Base};
  } else {
    $finaldestination = $self->Destination;
  }

  my $newheads = $self->Rewrite->
    (
     Head => $args{Head},
    );

  my @outputfiles;
  foreach my $newhead (@$newheads) {
    push @outputfiles, $finaldestination."/".$newhead;
  }

  my $cnt = 0;
  foreach my $outputfile (@outputfiles) {
    if (-f $outputfile) {
      ++$cnt;
    }
  }
  if ($cnt == (scalar @outputfiles)) {
    print "ALREADY COMPLETED OUTPUTFILES\n";
    print Dumper(\@outputfiles);
    return;
  }

  if (! -d $finaldestination) {
    my $command0 = "mkdir -p ".shell_quote($finaldestination);
    ApproveCommands(
		    Method => "parallel",
		    Commands => [$command0],
		    AutoApprove => $self->AutoApprove,
		   );
  }

  my $command1 = join(" ","cp",shell_quote($inputfile),shell_quote($sourcedir));
  ApproveCommands(
		  Method => "parallel",
		  Commands => [$command1],
		  AutoApprove => $self->AutoApprove,
		 );

  foreach my $newhead (@$newheads) {
    my $omnipageinputfile = "$sourcedir/$newhead";
    my $omnipageoutputfile = "$targetdir/$newhead";
    my $res = $self->WaitForFileToFinish
      (
       OmnipageOutputFile => $omnipageoutputfile,
      );

    if ($res->{Success}) {
      # I guess we're supposed to return the contents, or at least move it to the appropriate place
      # "mv $omnipageoutputfile $destination";
      my $command2 = join(" ","mv",shell_quote($omnipageoutputfile),shell_quote($finaldestination));
      my $command3 = join(" ","rm",shell_quote($omnipageinputfile));
      ApproveCommands(
		      Method => "parallel",
		      Commands => [$command2,$command3],
		      AutoApprove => $self->AutoApprove,
		     );
    } else {
      print Dumper({"HUGE ERROR" => \%args});
    }
  }
}

1;

# {
#     my $sourcedir = $self->OCRFolderWatch;
#     my $targetdir = $self->OCRFolderWatchOutput;
# 
#     # first convert the file, blah blah, don't do this now
#     # "cp $inputfile $sourcedir";
#     my $command1 = join(" ","cp",shell_quote($inputfile),shell_quote($sourcedir));
#     print "$command1\n";
# 
#     my $newhead = $self->Rewrite->(Head => $args{Head});
#     my $omnipageinputfile = "$sourcedir/$newhead";
#     my $omnipageoutputfile = "$targetdir/$newhead";
#     my $res = $self->WaitForFileToFinish
#       (
#        OmnipageOutputFile => $omnipageoutputfile,
#       );
# 
#     if ($res->{Success}) {
#       # I guess we're supposed to return the contents, or at least move it to the appropriate place
#       # "mv $omnipageoutputfile $destination";
#       my $finaldestination;
#       if (defined $args{Base}) {
# 	$finaldestination = $self->Destination."/".$args{Base};
#       } else {
# 	$finaldestination = $self->Destination;
#       }
#       if (-d $finaldestination) {
# 	my $command1a = "mkdir ".shell_quote($finaldestination);
# 	print "$command1a\n";
#       }
#       my $command2 = join(" ","mv",shell_quote($omnipageoutputfile),shell_quote($finaldestination));
#       print "$command2\n";
#       my $command3 = join(" ","rm",shell_quote($omnipageinputfile));
#       print "$command3\n";
#     } else {
#       print Dumper({"HUGE ERROR" => \%args});
#     }
#   }
