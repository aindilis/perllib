package System::LTH_SRL;

use Lingua::EN::Sentence qw(get_sentences);
use PerlLib::Lingua::Util;
use PerlLib::Sentence;
use PerlLib::SwissArmyKnife;
use Sayer;
use String::ShellQuote;

use XML::Simple;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyServerManager MySayer MySentence Inits Codes Debug /

  ];

sub init {
  my ($self,%args) = @_;
  $UNIVERSAL::SystemShalmaneser = $self;
  $self->Debug($args{Debug} || 0);
  $self->MySentence(PerlLib::Sentence->new);
  $self->MySayer
    ($args{Sayer} ||
     Sayer->new
     (
      DBName => "sayer_generic",
      Debug => $self->Debug,
     ));
  $self->Inits
    ({
      Parse => sub {

      },
     });
  $self->Codes
    ({
      Parse => sub {
	my %args = %{$_[0]};
	my $self = $UNIVERSAL::SystemShalmaneser;
	return $self->ProcessText(Text => $args{Text});
      },
     });
}

sub StartServer {
  my ($self,%args) = @_;
}

sub StopServer {
  my ($self,%args) = @_;
}

sub RestartServer {
  my ($self,%args) = @_;
}

sub Parse {
  my ($self,%args) = @_;
  my @result = $self->MySayer->ExecuteCodeOnData
    (
     CodeRef => $self->Codes->{Parse},
     Data => [{
	       Text => $args{Text},
	      }],
    );
  return $result[0];
}

sub BatchParse {
  my ($self,%args) = @_;
  # split the text into individual sentences, figure out which ones
  # have been cached, retrieve those, bunch the rest together, get
  # their result, split and cache
  my $resulthash = {};
  my @batchparsing;
  foreach my $sentence
    (@{$self->MySentence->GetSentences
	 (
	  Clean => 1,
	  Text => $args{Text},
	 )}) {
    if (! $args{Overwrite} and $self->MySayer->ExecuteCodeOnData
	(
	 HasResult => 1,
	 CodeRef => $self->Codes->{Parse},
	 Data => [{
		   Text => $sentence,
		  }],
	)) {
      my @result = $self->MySayer->ExecuteCodeOnData
	(
	 CodeRef => $self->Codes->{Parse},
	 Data => [{
		   Text => $sentence,
		  }],
	);
      $resulthash->{$sentence} = $result[0];
    } else {
      push @batchparsing, $sentence;
    }
  }

  print Dumper({
		ResultHash => $resulthash,
		Batch => \@batchparsing,
	       }) if $self->Debug;

  # now parse what hasn't already been parsed
  if (scalar @batchparsing) {
    my $res = $self->ProcessText(Text => join("\n",@batchparsing));
    if ((scalar @$res) != (scalar @batchparsing)) {
      return {
	      Success => 0,
	      Error => {
			Processed => $res,
			Batch => \@batchparsing,
		       }
	     };
    }

    # now pair these and cache the result
    while (scalar @batchparsing) {
      my ($input,$result) = (shift @batchparsing, shift @$res);
      See({RESULTRESULT => $result}) if $self->Debug;
      $resulthash->{$input} = $result;
      $self->MySayer->ExecuteCodeOnData
	(
	 CodeRef => $self->Codes->{Parse},
	 Data => [{
		   Text => $input,
		  }],
	 Result => [$result],
	);
    }
  }
  # now return everything, in the right order

  my @result;
  foreach my $sentence
    (@{$self->MySentence->GetSentences
     (
      Clean => 1,
      Text => $args{Text},
     )}) {
    push @result, $resulthash->{$sentence};
  }
  my $retval = {
	  Success => 1,
	  Result => \@result,
	 };
  return $retval;
}

sub ProcessText {
  my ($self,%args) = @_;
  # get the sentences
  my $sentences = GetSentences(Text => $args{Text});
  print Dumper($sentences);
  my $fh = IO::File->new;
  my $inputfile = "/tmp/shal.input";
  my $outputfile = "/tmp/shal.output";
  SafelyRemove(Items => [$outputfile]);
  my $quotedinputfile = shell_quote($inputfile);
  my $quotedoutputfile = shell_quote($outputfile);
  my $res = [];
  if ($fh->open(">$inputfile")) {
    print $fh join("\n",@$sentences);

    # sh scripts/preprocess.sh < test.txt > test.tokens
    # sh scripts/run.sh < test.tokens > test.output

    my $command = "cd /var/lib/myfrdcsa/sandbox/shalmaneser-1.1.160307/shalmaneser-1.1.160307/shal_1.1_160307/shalmaneser1.1/program/ && ".
      "./shalmaneser.sh -i $quotedinputfile -o $quotedoutputfile -l en -p collins";
    print $command."\n";
    system $command;
    $fh->close;
    my $result = read_file($outputfile);
    $res = $self->ProcessResults
      (
       Result => $result,
      );
  }
  return $res;
}

sub ProcessResults {
  my ($self,%args) = @_;
  my $c = $args{Result};
  my $xs = XML::Simple->new();
  my $ref = $xs->XMLin($c);
  my @res;
  foreach my $sentence (keys %{$ref->{body}->{s}}) {
    my $terminals = $ref->{body}->{s}->{$sentence}->{graph}->{terminals}->{t};
    my $nonterminals = $ref->{body}->{s}->{$sentence}->{graph}->{nonterminals}->{nt};
    my $frames = $ref->{body}->{s}->{$sentence}->{sem}->{frames}->{frame};
    my $result = {
		  Terminals => $terminals,
		  Nonterminals => $nonterminals,
		  Frames => $frames,
		 };
    push @res, $result;
  }
  return \@res;
}

1;
