package System::Enju;

# use Manager::Dialog qw(QueryUser);

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

sub StartEnju {
  my ($self,%args) = @_;
  $self->StartServer(%args);
}

sub StartServer {
  my ($self,%args) = @_;
  my $command = "enju";
  my @parameters;
  $self->MyExpect(Expect->new);
  $self->MyExpect->raw_pty(1);
  $self->MyExpect->spawn($command, @parameters)
    or die "Cannot spawn $command: $!\n";
  print "Waiting for parser to initialize...\n";
  $self->MyExpect->expect(300, [qr/Ready/, sub {print "Initialized.\n"}]);
  $self->MyExpect->clear_accum();
}

sub StopServer {
  my ($self,%args) = @_;
  if ($args{HardRestart}) {
    $self->MyExpect->hard_close();
  } else {
    $self->MyExpect->soft_close();
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
  $self->MyExpect->expect(300, [qr/^$/m, sub {} ]);
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
    if ($args{Type} eq "LogicForm") {
      return [Results => $self->LogicForm
	      (Input => $formalism->{Result})];
    } else {
      my $roots = {};
      my $root;
      foreach my $l (split /\n/, $formalism->{Result}) {
	next if $l =~ /^$/;
	next if $l =~ /^\s*\#/;
	# print $l."\n";
	my @i = split /\s+/,$l;
	$roots->{$i[1]}->{$i[5]} = $i[7];
      }

      my @formula;
      foreach my $key (keys %$roots) {
	my @args = map {$roots->{$key}->{$_}} sort keys %{$roots->{$key}};
	push @formula, "\t($key ".join (" ",@args).")";
      }
      return {Results => \@formula};
    }
  }
}

sub ApplyEnjuToSentence {
  my ($self,%args) = @_;
  my $sentence = $args{Sentence};
  $sentence =~ s/\n/ /g;
  $sentence =~ s/\s+/ /g;
  if (length($sentence) < 150) {
    print $sentence."\n";
    return $self->ProcessFormalism
      (Formalism => $self->ProcessSentence
       (Sentence => $sentence),
       Type => $args{Type});
  } else {
    return {SentenceTooLong => 1};
  }
}

sub ApplyEnjuToText {
  my ($self,%args) = @_;
  my $text = $args{Text};
  print "Getting sentences...\n";
  my $sentences = get_sentences($text);
  print "Done\n";
  my @results;
  foreach my $sentence (@$sentences) {
    push @results, $self->ProcessFormalism
      (Formalism => $self->ProcessSentence
       (Sentence => $sentence),
       Type => $args{Type});
  }
  return \@results;
}


sub ApplyEnjuToFile {
  my ($self,%args) = @_;
  my $f = $args{File};
  if (-f $f) {
    my $text = `cat "$f"`;
    return $self->ApplyEnjuToText
      (Type => $args{Type});
  } else {
    return {FileNotFound => 1};
  }
}

sub ApplyEnjuToQueryUser {
  my ($self,%args) = @_;
  while (1) {
    # my $sentence = QueryUser("Sentence?: ");
  }
}

sub LogicForm {
  my ($self,%args) = @_;
  my $itemtable = [qw{orig stemmed origpos stemmedpos id}];
  my $itembase = {};
  my $vars = {};
  my $rels = {};
  my $mods = {};
  foreach my $item (split /\n/, $args{Input}) {
    if ($item =~ /\s/) {
      my $res = [];
      my @c = split /\s+/, $item;
      my @a = splice @c,0,5;
      $res->[0] = shift @c;
      my $i = 0;
      foreach my $record (@a) {
	$res->[1]->{$itemtable->[$i++]} = $record;
      }
      $i = 0;
      foreach my $record (@c) {
	$res->[2]->{$itemtable->[$i++]} = $record;
      }
      my $r = $res;

      # $rels->{$r->[0]}->{$r->[1]->{id}}->{$r->[2]->{id}} = 1;
      if ($r->[0] =~ /^ARG(\d+)$/) {
	$rels->{$r->[1]->{id}}->{$1} = $r->[2]->{id};
      } elsif ($r->[0] =~ /^MOD$/) {
	# we probably want to collapse these items
	$mods->{$r->[1]->{id}} = $r->[2]->{id};
      }
      for (my $i = 1; $i <= 2; ++$i) {
	# create the index of items for future reference
	$itembase->{$r->[$i]->{id}} = $r->[$i];
	if ($r->[$i]->{stemmedpos} =~ /^(VB)$/) {
	  $vars->{$r->[$i]->{id}} = {
				     "Type" => "event",
				     "Modifier" => "v_",
				    };
	} elsif ($r->[$i]->{stemmedpos} =~ /^(RB)$/) {
	  $vars->{$r->[$i]->{id}} = {
				     "Type" => "event",
				     "Modifier" => "r_",
				    };
	} elsif ($r->[$i]->{stemmedpos} =~ /^(TO|IN|CC)$/) {
	  $vars->{$r->[$i]->{id}} = {
				     "Type" => "event",
				    };
	} elsif ($r->[$i]->{stemmedpos} =~ /^(DT|-COMMA-)$/) {
	} elsif ($r->[$i]->{stemmedpos} =~ /^(NNP|NN|NNS)$/) {
	  $vars->{$r->[$i]->{id}} = {
				     Type => "item",
				     Modifier => "n_",
				    };
	} elsif ($r->[$i]->{stemmedpos} =~ /^(JJ)$/) {
	  $vars->{$r->[$i]->{id}} = {
				     Type => "item",
				     Modifier => "a_",
				    };
	} elsif ($r->[$i]->{stemmedpos} =~ /^(PRP)$/) {
	  $vars->{$r->[$i]->{id}} = {
				     Type => "item",
				    };
	}
      }
      # now populate the relation data
    }
  }
  # print Dumper([$itembase,$vars]);
  # generate the predicates
  my @res;
  my ($items, $events) = ({},{});
  my $i = 1;
  my $iitems = {};
  foreach my $id (sort {$a <=> $b} keys %$itembase) {
    if (exists $vars->{$id} and $vars->{$id}->{Type} eq "item") {
      $items->{$i} = {
		      ID => $id,
		      Place => $i,
		      Content => $itembase->{$id}->{orig}.
		      (defined $vars->{$id}->{Modifier} ? ":".$vars->{$id}->{Modifier} : ""),
		     };
      $iitems->{$id} = $i;
      ++$i;
    }
  }
  my $ievents = {};
  foreach my $id (sort {$a <=> $b} keys %$itembase) {
    if (exists $vars->{$id} and $vars->{$id}->{Type} eq "event") {
      $events->{$i} = {
		       ID => $id,
		       Place => $i,
		       Content => $itembase->{$id}->{stemmed}.
		       (defined $vars->{$id}->{Modifier} ? ":".$vars->{$id}->{Modifier} : ""),
		      };
      $ievents->{$id} = $i;
      ++$i;
    }
  }
  # now generate the logic form of this
  # the items
  foreach my $i (sort {$a <=> $b} keys %$items) {
    push @res, $items->{$i}->{Content}." (x".$i.")";
  }

  # now the forms
  foreach my $i (sort {$a <=> $b} keys %$events) {
    # these are relations
    # extract the relation and put the various
    my $string = $events->{$i}->{Content}." (e".$i;
    # now compute the args for this event and their item number
    # iterate over the arguments for this event
    my $j = 1;
    while (exists $rels->{$events->{$i}->{ID}}->{$j}) {
      my $num = $rels->{$events->{$i}->{ID}}->{$j};
      if (exists $iitems->{$num}) {
	$string .= ", x".$iitems->{$num};
      } elsif (exists $ievents->{$num}) {
	$string .= ", e".$ievents->{$num};
      }
      ++$j;
    }
    push @res, $string.")";
  }
  return \@res;
}

1;
