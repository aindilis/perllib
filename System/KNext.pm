package System::KNext;

use BOSS::Config;
use Formalize2::UniLang::Client;
use KBS2::ImportExport;
use PerlLib::Sentence;
use PerlLib::ServerManager;
use PerlLib::SwissArmyKnife;
use Sayer;
use System::StanfordParser;

use IO::File;
use Lingua::EN::Sentence qw(get_sentences);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Config Conf MyServerManager Regex MyFormalize MyStanfordParser
	Debug MyImportExport MySayer Inits Codes HasBeenInitialized
	MySentence Overwrite Configuration /

  ];

sub init {
  my ($self,%args) = @_;
  $UNIVERSAL::knext = $self;
  my $specification = q(
	-f <file>	Filename
	-c		Clear the Sayer Cache
	-d		Debug
	-s <method>	Split by method ("section","every few sentences")
	-o		Overwrite the cached results for this
	-w		Write to smaller files, rather than one big file

	-e <engines>	Formalize2 engines to use if any

	--skip <processes>...	Skip listed processes (formalize, cyc, etc)

	--no-formalize	Skip Formalize2 step
);
  $self->Config
    (BOSS::Config->new
     (Spec => $specification));
  $self->Conf($self->Config->CLIConfig);
  my $conf = $self->Conf;
  my $data =
    {
     Skip => $conf->{'--skip'},
     FormalizeEngines => $conf->{'-e'},
    };
  if ($args{DontUseCommandLine}) {
    $self->Configuration
      ({
	DontFormalize => $args{DontFormalize},
	Data => $args{Data} || $data,
	Overwrite => $args{Overwrite},
	ClearSayerCache => $args{ClearSayerCache},
	Debug => $args{Debug},
	SplitBy => $args{SplitBy},
	File => $args{File},
	WriteToSmallerFiles => $args{WriteToSmallerFiles},
       });
  } else {
    $self->Configuration
      ({
	DontFormalize => $args{DontFormalize} || $self->Conf->{'--no-formalize'},
	Data => $args{Data} || $data,
	Overwrite => $args{Overwrite} || $self->Conf->{'-o'},
	ClearSayerCache => $args{ClearSayerCache} || $self->Conf->{'-c'},
	Debug => $args{Debug} || $self->Conf->{'-d'},
	SplitBy => $args{SplitBy} || $self->Conf->{'-s'} || "every few sentences",
	File => $args{File} || $self->Conf->{'-f'},
	WriteToSmallerFiles => $args{WriteToSmallerFiles} || $self->Conf->{'-w'},
       });
    if (exists $self->Conf->{'--skip'}) {
      foreach my $skip (@{$self->Conf->{'--skip'}}) {
	if ($skip eq 'Formalize') {
	  $self->Configuration->{DontFormalize} = 1;
	}
      }
    }
  }
  # print Dumper($self->Configuration);
  # $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/free-knext";
  $self->Debug($self->Configuration->{'Debug'});
  $self->HasBeenInitialized({});
  $self->Regex
    (qr/^\[\d+\]> /sm);
  $self->MySayer
    ($args{Sayer} ||
     Sayer->new
     (
      DBName => "sayer_generic",
      Debug => $self->Debug,
     ));
  $self->Inits
    ({
      ProcessTreebank => sub {
	my $self = shift;
	system "killall lisp.run";
	$self->MyServerManager
	  (
	   PerlLib::ServerManager->new
	   (
	    Command => "cd /var/lib/myfrdcsa/codebases/minor/free-knext/actual-knext && clisp",
	    Initialized => $self->Regex,
	    Debug => $self->Debug,
	   )
	  );
	$self->MyServerManager->MyExpect->print
	  ("(load \"extract-patterns.lisp\")\n");
	$self->MyServerManager->MyExpect->expect
	  (15,[$self->Regex, sub {print "Loaded KNext.\n"}]);
      },
     });
  $self->Codes
    ({
      ProcessTreebank => sub {
	my %args = %{$_[0]};
	my $self = $UNIVERSAL::knext;
	return $self->ProcessTreebank
	  (
	   Treebank => $args{Treebank},
	   OriginalSentence => $args{OriginalSentence},
	   Data => $args{Data},
	  );
      },
     });
  $self->MyFormalize
    (Formalize2::UniLang::Client->new) unless $self->Configuration->{'DontFormalize'};
  $self->MyStanfordParser
    (System::StanfordParser->new
     (
      Debug => $self->Debug,
      Sayer => $self->MySayer,
     ));
  $self->MyImportExport
    (KBS2::ImportExport->new);
  if (exists $self->Configuration->{'Overwrite'}) {
    $self->Overwrite(1);
  } else {
    $self->Overwrite(0);
  }
}

sub Execute {
  my ($self,%args) = @_;
  $self->Process
    (
     Data => $args{Data} || $self->Configuration->{Data},
    );
}

sub Process {
  my ($self,%args) = @_;
  if ($self->Configuration->{'ClearSayerCache'}) {
    $self->MyStanfordParser->MySayer->ClearCache();
  }
  if (exists $self->Configuration->{'File'} or exists $args{Contents}) {
    my @allresults;
    my $c = $args{Contents};
    $c = read_file($self->Configuration->{'File'}) unless defined $c;
    if (defined $self->Configuration->{'SplitBy'}) {
      if ($self->Configuration->{'SplitBy'} eq "section") {
	foreach my $section (split /\n\n/, $c) {
	  $section = $self->CleanText(Text => $section);
	  my $res = $UNIVERSAL::knext->ProcessText
	    (
	     Text => $section,
	     Data => $args{Data},
	    );
	  push @allresults, @$res;
	}
      } elsif ($self->Configuration->{'SplitBy'} eq "every few sentences") {
	if (! defined $self->MySentence) {
	  $self->MySentence
	    (PerlLib::Sentence->new);
	}
	my @few;
	foreach my $sentence 
	  (@{$self->MySentence->GetSentences
	     (
	      Text => $c,
	      Clean => 1,
	     )}) {
	  # See({Sentence => $sentence});
	  # fix up the sentence here
	  $sentence = $self->CleanText(Text => $sentence);
	  push @few, $sentence;
	  if ((scalar @few) == 3) {
	    my $res = $UNIVERSAL::knext->ProcessText
	      (
	       Sentences => \@few,
	       Data => $args{Data},
	      );
	    push @allresults, @$res;
	    @few = ();
	  }
	}
	if (scalar @few) {
	  my $res = $UNIVERSAL::knext->ProcessText
	    (
	     Sentences => \@few,
	     Data => $args{Data},
	    );
	  push @allresults, @$res;
	  @few = ();
	}
      }
    } else {
      my $res = $UNIVERSAL::knext->ProcessText
	(
	 Text => $c,
	 Data => $args{Data},
	);
      push @allresults, @$res;
    }
    my $display = $self->DisplayResult(Result => \@allresults);
    if ($self->Configuration->{File}) {
      my $fh1 = IO::File->new;
      $fh1->open(">".$self->Configuration->{'File'}.".knext.kbs");
      print $fh1 $display;
      $fh1->close();

      my $fh2 = IO::File->new;
      $fh2->open(">".$self->Configuration->{'File'}.".knext.dat");
      print $fh2 ClearDumper(\@allresults);
      $fh2->close();
    } else {
      return {
	      Success => 1,
	      Results => \@allresults,
	     };
    }
  }
}

sub ProcessText {
  my ($self,%args) = @_;
  if (defined $args{Sentences}) {
    $args{Text} = join("\n",@{$args{Sentences}});
  }
  my @results;
  my @sentences;
  my @treebankoutputs;
  if (defined $args{TreebankOutputs}) {
    push @treebankoutputs, @{$args{TreebankOutputs}};
  }
  if (defined $args{Text}) {
    my $res = $self->MyStanfordParser->BatchParse
      (
       Text => $args{Text},
       Overwrite => $self->Overwrite,
      );
    # See({RESRES => $res});
    my @items;
    if ($res->{Success}) {
      @items = @{$res->{Result}};
      @sentences = @{$res->{Sentences}};
    } else {
      @items = @{$res->{Error}{Processed}};
      # FIXME: @sentences = @{$res->???}
    }
    if (! scalar @sentences) {
      if (! defined $self->MySentence) {
	$self->MySentence
	  (PerlLib::Sentence->new);
      }
      @sentences = @{$self->MySentence->GetSentences
		       (
			Text => $args{Text},
			Clean => 1,
		       )};
    }

    # print Dumper({Sentences => \@sentences}) if $self->Debug;

    foreach my $entry (@items) {
      # print Dumper($entry);
      my $tree = $entry->{Tree};
      if ($tree !~ /^SENTENCE_SKIPPED_OR_UNPARSABLE/) {
	# FAULTY

	# $tree =~ s/\(\. \.\).+$//s;
	# $tree =~ s/^\(ROOT\s*//s;
	# $tree =~ s/\s*$//s;
	# $tree = "($tree))";
	# $tree =~ s/,/COMMA/sg;
	# $tree =~ s/\'/SINGLEQUOTE/sg;

	$tree =~ s/\(\. \.\).+$//s;
	$tree =~ s/^\(ROOT\s*//s;
	$tree =~ s/\s*$//s;
	$tree = "($tree))";
	# idea from lispify-parser-output.lisp
	$tree =~ s/([\,\#\`\'\:\;\,\.\\\|])/\\$1/sg;
      }
      print Dumper({Tree => $tree}) if $self->Debug;
      push @treebankoutputs, $tree;
    }
  }
  foreach my $treebankoutput (@treebankoutputs) {
    my $originalsentence = shift @sentences;
    # print Dumper({OrigSent => $originalsentence}) if $self->Debug;
    if ($treebankoutput !~ /^SENTENCE_SKIPPED_OR_UNPARSABLE/) {
      if (! exists $self->HasBeenInitialized->{ProcessTreebank}) {
	print "Initializing $key\n";
	if (exists $self->Inits->{ProcessTreebank}) {
	  &{$self->Inits->{ProcessTreebank}}($self);
	}
	$self->HasBeenInitialized->{ProcessTreebank} = 1;
      }
      my @result = $self->MySayer->ExecuteCodeOnData
	(
	 Overwrite => $self->Overwrite,
	 CodeRef => $self->Codes->{ProcessTreebank},
	 Data => [{
		   Treebank => $treebankoutput,
		   OriginalSentence => $originalsentence,
		   Data => $args{Data},
		  }],
	);
      my $res = shift @result;
      if ($res->{Success}) {
	push @results, $res->{Result};
      }
    }
  }
  return \@results;
}

sub ProcessTreebank {
  my ($self,%args) = @_;
  See({TheseArgs => \%args}) if $self->Debug;
  my $treebankoutput = $args{Treebank};
  my $command = "(e '$treebankoutput)\n";
  print Dumper({Command => $command}) if $self->Debug;
  $self->MyServerManager->MyExpect->print
    ($command);
  print "Submitting expect\n" if $self->Debug;
  $System::KNext::gotResult = 0;
  $self->MyServerManager->MyExpect->expect
    (5, [qr/.*^(Break \d+ )?\[\d+\]>/sm, sub {$System::KNext::gotResult = 1; print "Got result\n";} ]);
  my $res = $self->MyServerManager->MyExpect->match();
  if (! $System::KNext::gotResult or $res =~ /The following restarts are available:/) {
    $self->MyServerManager->MyExpect->hard_close();
    if (exists $self->Inits->{ProcessTreebank}) {
      &{$self->Inits->{ProcessTreebank}}($self);
    }
  }
  return $self->ProcessResults
    (
     Result => $res,
     OriginalSentence => $args{OriginalSentence},
     Data => $args{Data},
    );
}

sub ProcessResults {
  my ($self,%args) = @_;
  if ($args{Result} =~ /\n\n\n/) {
    return {
	    Success => 0,
	   };
  }
  print Dumper({ProcessResults => $args{Result}}) if $self->Debug;
  my $originalsentencedata =
    {
     Sentence => $args{OriginalSentence},
    };
  unless ($self->Configuration->{'DontFormalize'} or $self->Configuration->{'DontFormalizeFullSentences'}) {
    $self->DoFormalize
      (
       Statement => $args{OriginalSentence},
       FormalizeResult => $originalsentencedata,
       Data => $args{Data},
      );
  }
  print ClearDumper({OrigSentData => $originalsentencedata}) if $self->Debug;
  my @entries = split /\n\n/sm, $args{Result};
  my $sentence = $entries[0];
  $sentence =~ s/^\s*//s;
  $sentence =~ s/\s*$//s;
  my @knowledge;
  foreach my $statement (split /\n/, $entries[1]) {
    $statement =~ s/^\s*//s;
    $statement =~ s/\s*$//s;
    $statement =~ s/^\'//s;
    $statement =~ s/\'$//s;
    # codify this into logic using formalize
    my $res = {
	       Sentence => $statement,
	       Overwrite => $self->Overwrite,
	      };
    unless ($self->Configuration->{'DontFormalize'}) {
      $self->DoFormalize
	(
	 UseLowerCase => 1,
	 Statement => $statement,
	 FormalizeResult => $res,
	 Data => $args{Data},
	);
    }
    push @knowledge, $res;
  }
  my $formalism = $entries[2];	# could probably clean this up
  $formalism =~ s/_{20,}//s;
  $formalism =~ s/\[\d+\]>$//s;
  $formalism =~ s/\s*$//s;

  my $result =
    {
     OriginalSentence => $originalsentencedata,
     Sentence => $sentence,
     Formalism => $formalism,
     ExtractedKnowledge => \@knowledge,
    };
  print Dumper({AllResult => $result}) if $UNIVERSAL::debug;
  return {
	  Success => 1,
	  Result => $result,
	 };
}

sub DisplayResult {
  my ($self,%args) = @_;
  my @display;
  foreach my $entry (@{$args{Result}}) {
    push @display, ";; ".$entry->{Sentence}."\n";
    push @display, ";; E\n" if $self->Debug;
    foreach my $knowledge (@{$entry->{ExtractedKnowledge}}) {
      push @display, ";;  K\n" if $self->Debug;
      push @display, "\t;; ".$knowledge->{Sentence}."\n";
      my $ref = ref($knowledge->{Formalism}->{Results});
      foreach my $formula (@{$knowledge->{Formalism}->{Results}}) {
	push @display, ";;   F\n" if $self->Debug;
	my $res = $self->MyImportExport->Convert
	  (
	   Input => $formula->{Output},
	   InputType => "Interlingua",
	   OutputType => "KIF String",
	  );
	if ($res->{Success}) {
	  push @display, ";;    S\n" if $self->Debug;
	  push @display, "\t\t".$res->{Output}."\n";
	}
      }
    }
  }
  return join("\n", @display);
}

sub CleanText {
  my ($self,%args) = @_;
  my $text = $args{Text};
  return $text;
  $text =~ s/[^A-Za-z0-9\s\',\.;:-]/ /g;
  $text =~ s/^\s*//;
  $text =~ s/\s*$//;
  $text =~ s/\s+/ /g;
  return $text;
}

sub HasElement {
  my ($self,%args) = @_;
  foreach my $element (@{$args{List}}) {
    if ($element eq $args{Element}) {
      return 1;
    }
  }
}

sub DoFormalize {
  my ($self,%args) = @_;
  See({DoFormalizeArgs => \%args}) if $UNIVERSAL::debug;
  my $res = $args{FormalizeResult};
  my $statement = exists $args{UseLowerCase} ? lc($args{Statement}) : $args{Statement};
  my $engines = [];
  if (exists $args{Data} and
      exists $args{Data}{FormalizeEngines} and
      defined $args{Data}{FormalizeEngines}) {
    $engines = $args{Data}{FormalizeEngines};
  } else {
    $engines = ['ResearchCyc1_0'];
  }
  my @engines;
  foreach my $engine (@$engines) {
    if (! $self->HasElement(List => $args{Data}{Skip}, Element => $engine)) {
      push @engines, $engine;
    }
  }
  print ClearDumper({Engines => \@engines}) if $UNIVERSAL::debug;
  my @results;
  my $results = $self->FormalizeWrapper
    (
     Text => $statement,
     Engines => \@engines,
     # EngineArgs => {
     # 		ResearchCyc1_0 => {
     # 				  },
     # 	       },
    );
  print ClearDumper({Results => $results}); # if $UNIVERSAL::debug;
  $args{FormalizeResult}->{FormalizeResults} = $results;
}

sub FormalizeWrapper {
  my ($self,%args) = @_;
  my $res;
  my %results;
  if (scalar @{$args{Engines}}) {
    $res = $self->MyFormalize->FormalizeText
      (
       Text => $args{Text},
       Engines => $args{Engines},
       EngineArgs => $args{EngineArgs} || {},
      );
    foreach my $engine (@{$args{Engines}}) {
      my $output = $res->{Results}{$engine}[0];
      my $fallback = 0;
      if ($engine eq 'ResearchCyc1_0') {
	if (! $self->HasElement(List => $args{Engines}, Element => 'Default')) {
	  if ($output eq 'NIL') {
	    my $res2 = $self->MyFormalize->FormalizeText
	      (
	       Text => $args{Text},
	      );
	    $results{Default} = $res2->{Results}[0];
	    $fallback = 1;
	  }
	}
      }
      unless ($fallback) {
	$results{$engine} = {
			     Success => 1,
			     Output => $output,
			    };
      }
    }
  } else {
    $res = $self->MyFormalize->FormalizeText
      (
       Text => $args{Text},
      );
    $results{Default} = $res->{Results}[0];
  }
  return \%results;
}

1;
