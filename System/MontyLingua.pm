package System::MontyLingua;

use Manager::Dialog qw(QueryUser);

use Data::Dumper;
use Expect;
use Lingua::EN::Sentence qw(get_sentences);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyExpect /

  ];

sub init {
  my ($self,%args) = @_;

}

sub StartServer {
  my ($self,%args) = @_;
  my $command = "cd /var/lib/myfrdcsa/sandbox/montylingua-2.1/montylingua-2.1/python && python MontyLingua.py";
  my @parameters;
  $self->MyExpect(Expect->new);
  $self->MyExpect->log_stdout(0);
  $self->MyExpect->raw_pty(1);
  $self->MyExpect->spawn($command, @parameters)
    or die "Cannot spawn $command: $!\n";

  print "Waiting for parser to initialize...\n";
  # $self->MyExpect->expect(300, [qr/^>/, sub {print "Initialized.\n"}]);
  $self->MyExpect->expect(300, [qr/Loading Morph Dictionary/, sub {print "Initialized.\n"}]);
  $self->MyExpect->clear_accum();
}

sub StopServer {
  my ($self,%args) = @_;
  if ($args{HardRestart}) {
    $exp->hard_close();
  } else {
    $exp->soft_close();
  }
}

sub RestartServer {
  my ($self,%args) = @_;
  $self->StopServer
    (HardRestart => 1);
  $self->StartServer;
}

sub ProcessSentence {
  my ($self,%args) = @_;
  my $sentence = $args{Sentence};
  $self->MyExpect->print("$sentence\n");
  $self->MyExpect->expect(300, [qr/./, sub {} ]);
  my $res = $self->MyExpect->match();
  $self->MyExpect->expect(300, [qr/^>/m, sub {} ]);
  $res .= $self->MyExpect->before();
  if (! $res) {
    # timed out, restart server
    $self->RestartServer;
    return {Fail => 1};
  } else {
    $self->MyExpect->clear_accum();
    return {Result => $res};
  }
}

sub ProcessFormalism {
  my ($self,%args) = @_;
  my $formalism = $args{Formalism};
  if ($formalism->{Fail}) {
    return $formalism;
  } else {
    my $att = {};
    my $flag = 0;
    foreach my $line (split /\n/,$formalism->{Result}) {
      if ($flag) {
	$att->{generated_summary} = $line;
	$flag = 0;
      } elsif ($line =~ /^\s*([\w_]+): (\[.*)$/) {
	$att->{$1} = $2;
      } elsif ($line =~ /^\[\[/) {
	$att->{relations} = $line;
	$att->{eval_relations} = eval "\$VAR1 = $line;";
      } elsif ($line =~ /^GENERATED SUMMARY:/) {
	$flag = 1;
      } elsif ($line =~ /-- monty took ([\d\.]+) seconds\. --/) {
	$att->{run_time} = $1;
      }
    }
    return {Results => $att};
  }
}

sub ApplyMontyLinguaToSentence {
  my ($self,%args) = @_;
  my $sentence = $args{Sentence};
  $sentence =~ s/\n/ /g;
  $sentence =~ s/\s+/ /g;
  if (length($sentence) < 150) {
    print $sentence."\n";
    return $self->ProcessFormalism
      (Formalism => $self->ProcessSentence
       (Sentence => $sentence));
  } else {
    return {SentenceTooLong => 1};
  }
}

sub ApplyMontyLinguaToText {
  my ($self,%args) = @_;
  my $text = $args{Text};
  print "Getting sentences...\n";
  my $sentences = get_sentences($text);
  print "Done\n";
  my @results;
  foreach my $sentence (@$sentences) {
    $sentence =~ s/\s+/ /g;
    $sentence =~ s/  / /g;
    push @results, $self->ProcessFormalism
      (Formalism => $self->ProcessSentence
       (Sentence => $sentence));
  }
  return \@results;
}


sub ApplyMontyLinguaToFile {
  my ($self,%args) = @_;
  my $f = $args{File};
  if (-f $f) {
    my $text = `cat "$f"`;
    return $self->ApplyMontyLinguaToText;
  } else {
    return {FileNotFound => 1};
  }
}

sub ApplyMontyLinguaToQueryUser {
  my ($self,%args) = @_;
  while (1) {
    my $sentence = QueryUser("Sentence?: ");
  }
}

1;
