package System::EasyCCG;

use BOSS::Config;
use Capability::Tokenize;
use Manager::Misc::Light;
use PerlLib::SwissArmyKnife;

use Lingua::EN::Sentence qw(get_sentences);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Config Conf MyLight /

  ];

sub init {
  my ($self,%args) = @_;
  $specification = q(
	-t <text>		Text to parse
	-f <file>		File containing text to parse

	-n <n>			N-best
);

  $self->Config
    (BOSS::Config->new
     (Spec => $specification));
  my $conf = $self->Config->CLIConfig;
  # $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";
  $self->Conf($conf);
}

sub StartServer {
  my ($self,%args) = @_;
  $self->MyLight(Manager::Misc::Light->new());

  # I have to start the Expect server
}

sub StartClient {
  my ($self,%args) = @_;
}

sub GetCCG {
  my ($self,%args) = @_;
  my $conf = $self->Conf;

  my $nbest = '';
  if (exists $conf->{'-n'} or $args{N}) {
    $nbest = '--nbest '.($conf->{'-n'} || $args{N});
  }

  my $command_normal_style = "java -jar easyccg.jar --model model";
  my $command_prolog_style = "candc/bin/pos --model candc_models/pos | candc/bin/ner -model candc_models/ner -ofmt \"\%w|\%p|\%n \\n\" | java -jar easyccg.jar --model model -i POSandNERtagged -o prolog -r 'S[dcl]'";

  my @texts;
  if (exists $conf->{'-t'}) {
    my $text = $conf->{'-t'};
    chomp $text;
    push @texts, $text;
  }
  if (exists $conf->{'-f'}) {
    if (-f $conf->{'-f'}) {
      push @texts, read_file($conf->{'-f'});
    } else {
      print STDERR "ERROR: No such file: <".$conf->{'-f'}.">!\n";
    }
  }
  if ($args{Text}) {
    push @texts, $args{Text};
  }
  if (! scalar @texts) {
    print STDERR "ERROR: No text given, use -t or -f\n";
    push @texts, "read articles about michael iltis and his father, send condolensces";
  }

  if ($batchmode) {
    # require Expect;
  }

  my @results;
  my $chdir = "cd /var/lib/myfrdcsa/sandbox/easyccg-0.2/easyccg-0.2";
  foreach my $text (@texts) {
    my $sentences = get_sentences($text);
    foreach my $sentence (@{$sentences}) {
      $sentence =~ s/[^[:ascii:]]/ /sg;
      $sentence =~ s/^\s*//sg;
      $sentence =~ s/\s*$//sg;
      $sentence =~ s/\s+/ /sg;
      my $tokenizedsentence = tokenize_treebank($sentence);
      chomp $tokenizedsentence;
      my $c;
      if ($batchmode) {
	if ($prologstyleoutput) {
	  # $expect->print("$chdir \&\& $command_prolog_style $nbest");
	  # $expect->wait_for(//,$x);
	} else {
	  # $expect->print("$chdir \&\& $command_normal_style $nbest");
	  # $expect->wait_for(//,$x);
	}
      } else {
	my $prefix = "echo ".shell_quote($tokenizedsentence);
	if ($prologstyleoutput) {
	  my $command = "$chdir \&\& $prefix | $command_prolog_style $nbest";
	  print "$command\n";
	  $c = `$command`;
	} else {
	  my $command =	"$chdir \&\& $prefix | $command_normal_style $nbest";
	  print "$command\n";
	  $c = `$command`;
	}
      }
      push @results,
	{
	 Sentence => $sentence,
	 Parse => $self->GetParses(C => $c),
	};
    }
  }
  return \@results;
}

sub GetParses {
  my ($self,%args) = @_;
  if (! $args{C}) {
    return
      {
       Success => 0,
       Reason => 'command returned no result',
      };
  }

  my @lines = split /\n/, $args{C};
  my @results;
  foreach my $line (@lines) {
    if ($line =~ /^ID=\d+$/) {
      next;
    } else {
      my $domain = $self->MyLight->Parse(Contents => $line);
      push @results, $self->Parse(C => "Output:\n".join("\n", @{Fix(Domain => $self->ParseEasyCCG(Domain => $domain)->[0], Indent => 0)})."\n[success] ");
      @res = ();
    }
  }
  return \@results;
}

sub ParseEasyCCG {
  my ($self,%args) = @_;
  my @accumulator;
  my @res;
  my $i = 0;
  foreach my $subdomain (@{$args{Domain}}) {
    ++$i;
    my $ref = ref($subdomain);
    if ($ref eq 'ARRAY') {
      if ($args{Domain}[0] eq '<L') {
	if ($i == 6) {
	  # if ($args{Domain}[4] eq 'POS') {
	  #   push @res, $accumulator[5];
	  # } else {
	  #   push @res, $accumulator[4];
	  # }
	  @accumulator = ();
	}
      } else {
	push @res, $self->ParseEasyCCG(Domain => $subdomain);
      }
    } else {
      push @accumulator, $subdomain;
    }
  }
  if (scalar @accumulator > 4) {
    if ($accumulator[3] eq 'POS') {
      push @res, $accumulator[4];
    } else {
      push @res, $accumulator[3];
    }
  }
  if (scalar @res == 1 and ! ref($res[0])) {
    return $res[0];
  } else {
    return \@res;
  }
}

sub Fix {
  my (%args) = @_;
  my $ref = ref($args{Domain});
  if ($ref eq 'ARRAY') {
    foreach my $subdomain (@{$args{Domain}}) {
      Fix(Domain => $subdomain, Indent => $args{Indent} + 1);
    }
  } else {
    push @res, ('  'x$args{Indent}).$args{Domain};
  }
  return \@res;
}

sub Parse {
  my ($self,%args) = @_;
  my $result;
  my $start = 0;
  my $lastlength = 0;
  foreach my $line (split /\n/, $args{C}) {
    if ($start == 1) {
      if ($line =~ /^\[success\]/) {
	$start = 2;
      } else {
	if ($line =~ /^(\s+)(\S+)$/) {
	  my $space = $1;
	  my $word = $2;
	  my $length = $self->getLength(Space => $space);
	  if ($lastlength != $length) {
	    if ($lastlength < $length) {
	      foreach my $i (1 .. ($length - $lastlength)) {
		$result .= "(";
	      }
	    } else {
	      foreach my $i (1 .. (($lastlength - $length) + 1)) {
		$result .= ")";
	      }
	      $result .= "(";
	    }
	  } else {
	    $result .= ")(";
	  }
	  $lastlength = $length;
	  $result .= $word;
	}
      }
    }
    if ($line =~ /^Output:/) {
      $start = 1;
    }
  }
  $result .= ")" x $lastlength;
  $result =~ s/^\(//;
  $result =~ s/\)$//;
  return $result;
}


sub getLength {
  my ($self,%args) = @_;
  my $length = 0;
  foreach my $char (split //, $args{Space}) {
    if ($char eq "\t") {
      $length = $length + 4;
    } else {
      $length++;
    }
  }
  return $length / 2;
}

1;
