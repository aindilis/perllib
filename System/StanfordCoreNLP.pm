package System::StanfordCoreNLP;

# replace this with Lingua-StanfordCoreNLP-0.02

use PerlLib::Sentence;
use PerlLib::SwissArmyKnife;
use Sayer;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyServerManager MySayer MySentence Inits Codes Debug /

  ];

sub init {
  my ($self,%args) = @_;
  $UNIVERSAL::SystemStanfordCoreNLP = $self;
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
	my $self = $UNIVERSAL::SystemStanfordCoreNLP;
	return $self->ProcessText(Text => $args{Text});
      },
     });
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
  my $fh = IO::File->new();
  my $inputfile = "/tmp/stanfordcorenlp.txt";
  system "rm $inputfile";
  $fh->open(">$inputfile") or die "cannot open inputfile $inputfile\n";
  print $fh $args{Text};
  $fh->close();
  # my $command = "cd /var/lib/myfrdcsa/sandbox/stanford-corenlp-20120409/stanford-corenlp-20120409 && java -cp stanford-corenlp-2012-04-09.jar:stanford-corenlp-2012-04-09-models.jar:xom.jar:joda-time.jar -Xmx3g edu.stanford.nlp.pipeline.StanfordCoreNLP -annotators tokenize,ssplit,pos,lemma,ner,parse,dcoref -file $inputfile";
  my $command = "cd /var/lib/myfrdcsa/sandbox/stanford-corenlp-full-20140104/stanford-corenlp-full-20140104 && java -cp stanford-corenlp-3.3.1.jar:stanford-corenlp-3.3.1-models.jar:xom.jar:joda-time.jar:jollyday.jar:ejml-0.23.jar -Xmx3g edu.stanford.nlp.pipeline.StanfordCoreNLP -annotators tokenize,cleanxml,ssplit,pos,lemma,ner,regexner,parse,sentiment,truecase,dcoref -file $inputfile";
  my $res = `$command`;
  return $self->ProcessResults
    (Response => $res);
}

sub ProcessResults {
  my ($self,%args) = @_;
  my $c = $args{Response};

  # rewrite this to be a class that we can inherit from

  # print Dumper($c);
  # $c =~ s/.*Parsing file: (.+?) with (\d+) sentences.\n//s;
  # $c =~ s/\n\nParsed file: (.+?) \[(\d+) sentences\]\..*//s;
  # my @items = split /\n\n/, $c;
  my @res;
  # while (@items) {
  #   my ($tmp,$rel) = (shift @items, shift @items);
  #   if ($tmp =~ /(.+?)$(.+)/sm) {
  #     my $sent = $1;
  #     $tree = $2;
  #     $tree =~ s/^\s+//s;
  #     if ($sent eq "(ROOT") {
  # 	$tree = "$sent\n$tree";
  # 	$sent = "";
  #     }
  #     push @res, {
  # 		  Sent => $sent,
  # 		  Tree => $tree,
  # 		  Rel => [split /\n/, $rel],
  # 		 };

  #   } else {
  #     die "Error\n";
  #   }
  # }
  return \@res;
}

1;
