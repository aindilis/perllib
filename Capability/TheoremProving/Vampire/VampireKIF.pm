package Capability::TheoremProving::Vampire::VampireKIF;

use base qw(Capability::TheoremProving::Vampire);

use KBS2::Util;
use KBS2::Util::SZSProblemStatusOntology;
use PerlLib::Util;

use Data::Dumper;
use IO::File;
use File::Temp qw( tempfile );;
use XML::Smart;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyProblemOntology Debug /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Debug($args{Debug});
  $self->MyProblemOntology
    (KBS2::Util::SZSProblemStatusOntology->new());
}

sub StartServer {
  my ($self,%args) = @_;
  my $process = "/usr/bin/perl /var/lib/myfrdcsa/codebases/internal/freekbs2/data/theorem-provers/vampire/Vampire1/Bin/server.pl";
  if ($args{Restart}) {
    print "Server already running, but instructed to restart it.\n";
    # FIXME: make this so that it gets it by the exact pid
    KillProcesses
      (
       Process => $process,
       AutoApprove => 1,
      );
    $self->StartServerActual;
  } else {
    my $pids = PidsForProcess
      (
       Process => $process,
      );
    if (! scalar @$pids) {
      $self->StartServerActual;
    } else {
      print "Server already running.\n";
    }
  }
}

sub StartServerActual {
  my ($self,%args) = @_;
  print "Starting server.\n";
  system "/var/lib/myfrdcsa/codebases/internal/freekbs2/data/theorem-provers/vampire/Vampire1/Bin/server.pl > /dev/null 2> /dev/null &";
  sleep 5;
  return {
	  Success => 1,
	 };
}

sub QueryVampire {
  my ($self,%args) = @_;
  my ($fh,$filename) = tempfile();
  print $fh $args{Query}."\n<bye/>\n";
  my $response = `/var/lib/myfrdcsa/codebases/internal/freekbs2/data/theorem-provers/vampire/Vampire1/Bin/client.pl < $filename`;
  print "query vampire\n" if $self->Debug;
  return $self->ProcessResponse
    (
     Formula => $args{Formula},
     Query => $args{Query},
     Response => $response,
     Attributes => $args{Attributes},
    );
}

sub ProcessResponse {
  my ($self,%args) = @_;
  my @results;
  print "1\n" if $self->Debug;
  my $query = XML::Smart->new("<query>\n".$args{Query}."\n</query>");
  print Dumper({Query => $query}) if $self->Debug;
  my @queries;
  my $contents1 = {};
  my @queryitems = $query->{query}->order();
  if (! scalar @queryitems) {
    if (exists $query->{query}{query}) {
      my ($xmltext,$tmp) = $query->{query}{query}->data_pointer();
      push @queries, $self->Clean(XML => $xmltext);
    }
  } else {
    foreach my $item (@queryitems) {
      print "3\n" if $self->Debug;
      my ($xmltext,$tmp) = $query->{query}{$item}->[$contents1->{$item}++]->data_pointer();
      push @queries, $self->Clean(XML => $xmltext);
    }
  }
  print "1\n" if $self->Debug;
  my $response = XML::Smart->new("<response>\n".$args{Response}."\n</response>");
  print Dumper({Response => $response}) if $self->Debug;
  my @responses;
  my $contents2 = {};
  my @responseitems = $response->{response}->order();
  if (! scalar @responseitems) {
    if (exists $response->{response}{queryResponse}) {
      my ($xmltext,$tmp) = $response->{response}{queryResponse}->data_pointer();
      push @responses, $self->Clean(XML => $xmltext);
    }
  }
  foreach my $item (@responseitems) {
    print "2\n" if $self->Debug;
    my ($xmltext,$tmp) = $response->{response}{$item}->[$contents2->{$item}++]->data_pointer();
    push @responses, $self->Clean(XML => $xmltext);
  }

  print Dumper([\@queries,\@responses]) if $self->Debug;

  my $sizeofqueries = scalar @queries;
  my $sizeofresponses = scalar @responses;
  if ($sizeofqueries != $sizeofresponses) {
    return {
	    Success => 0,
	    Error => "List sizes don't match",
	    DebugInfo => {
			  Queries => \@queries,
			  Responses => \@responses,
			  QueriesCount => $sizeofqueries,
			  ResponsesCount => $sizeofresponses,
			 },
	   };
  } else {
    print "WTF\n" if $self->Debug;
    print $sizeofqueries."\t".$sizeofresponses."\n" if $self->Debug;
    my $i = 0;
    while (scalar @queries and scalar @responses) {
      my ($query,$response) = (shift @queries, shift @responses);
      my %attributes = ();
      foreach my $key (keys %{$args{Attributes}}) {
	if ($key eq "Models") {
	  if ($i >= $args{Attributes}->{LoadSize}) {
	    $attributes{Models} = $args{Attributes}->{Models};
	  }
	} else {
	  $attributes{$key} = $args{Attributes}->{$key};
	}
      }
      my %additionalargs = $self->MapResponseToSZS
	(
	 Formula => $args{Formula},
	 Query => $query,
	 Response => $response,
	 Attributes => \%attributes,
	);
      push @results, {
		      Query => $query,
		      Response => $response,
		      %additionalargs,
		     };
      ++$i;
    }
  }
  return {
	  Results => \@results,
	 };
}

sub Clean {
  my ($self,%args) = @_;
  # print Dumper({CleanArgs => \%args});
  return "" unless $args{XML};
  my @l = split /\n/, $args{XML};
  shift @l;
  shift @l;
  return join("\n",@l);
}

sub MapResponseToSZS {
  my ($self,%args) = @_;
  my %additionalargs;
  my $response = XML::Smart->new($args{Response});

  my $contents1 = {};
  my @answers;
  my @answeritems = $response->{queryResponse}->order();
  if (! scalar @answeritems) {
    if (exists $response->{queryResponse}{answer}) {
      my ($xmltext,$tmp) = $response->{queryResponse}{answer}->data_pointer();
      push @answers, $self->Clean(XML => $xmltext);
    }
  } else {
    foreach my $item (@answeritems) {
      if ($item eq "answer") {
	my ($xmltext,$tmp) = $response->{queryResponse}{$item}->[$contents1->{$item}++]->data_pointer();
	push @answers, $self->Clean(XML => $xmltext);
      }
    }
  }

  my @modelslist;
  foreach my $answer (@answers) {
    my $item = XML::Smart->new($answer);
    if (exists $item->{answer}{result}) {
      my $value = $item->{answer}{result}->content;
      # if value is yes, this means what?
      if ($value eq "yes") {
	my $proof = $self->Clean
	  (XML => $item->{answer}{proof}->data_pointer());
	$additionalargs{Result} = {
				   Type => "Theorem",
				   Attributes => $args{Attributes},
				   Output => {
					      "Assurance" => "None given at this time",
					      "Proof of C from Ax" => $proof,
					      "Refutation of Ax U {~C}" => "None given at this time",
					      "Refutation of CNF(Ax U {~C})" => "None given at this time",
					     },
				  };
	# print Dumper({UniqueArgs => \%args});
	if (exists $args{Attributes}->{Models}) {
	  #     <bindingSet type="definite">
	  #       <binding>
	  #         <var name="?X" value="?X0"/>
	  #       </binding>
	  #     </bindingSet>
	  my $bindingSet = $item->{answer}{bindingSet};
	  my @bindingset;
	  foreach my $binding (@{$bindingSet->{binding}}) {
	    my $bindings = {};
	    foreach my $var (@{$binding->{var}}) {
	      $bindings->{$var->{name}->content} = $var->{value}->content,
	    }
	    push @bindingset, $bindings,
	  }
	  print Dumper({BindingSet => \@bindingset}) if $self->Debug;
	  my $models = {
			Type => $bindingSet->{type}->content,
			BindingSet => \@bindingset,
		       };
	  if (1) {
	    my @formulae;
	    if ($models->{Type} eq "definite") {
	      foreach my $bindings (@{$models->{BindingSet}}) {
		# generate a formula for this
		push @formulae, $self->SubstituteBindings
		  (
		   Item => $args{Formula},
		   Bindings => $bindings,
		  );
	      }
	    }
	    $models->{Formulae} = \@formulae;
	  } else {
	    print Dumper({Query => $query});
	  }
	  push @modelslist, $models;
	}
      } elsif ($value eq "no") {
	# FIX ME by looking at vampire code....

	# what the hell is this supposed to mean?  It could mean that it
	# is independent, (possibly unknown), or contradictory?  shit.
	# If it is independent, it may be asserted, if it is possibly
	# unknown, depending on the assertion strategy, it can be
	# asserted, and if it is contradictory, it cannot be asserted.
	$additionalargs{Result} = {
				   Type => "Unknown",
				   Attributes => $args{Attributes},
				   Output => {
					     },
				  };
      } else {
	print "Unknown queryResponse answer result: <<<$value>>>\n";
      }
    }
  }
  # print Dumper({Models => \@modelslist});
  if ($args{Attributes}->{Models}) {
    $additionalargs{Models} = \@modelslist;
  }
  return %additionalargs;
}

sub SubstituteBindings {
  my ($self,%args) = @_;
  my $item = $args{Item};
  my $ref = ref $item;
  if ($ref eq "ARRAY") {
    my @list;
    foreach my $arg (@$item) {
      push @list, $self->SubstituteBindings
	(
	 Item => $arg,
	 Bindings => $args{Bindings},
	);
    }
    return \@list;
  } elsif ($ref eq "HASH") {
    my %hash;
    foreach my $key (keys %$item) {
      my $key2 = $key;
      $hash{$key2} = $self->SubstituteBindings
	(
	 Item => $item->{$key},
	 Bindings => $args{Bindings},
	);
    }
    return \%hash;
  } else {
    my $item2 = $item;
    if (exists $args{Bindings}->{$item2}) {
      return $args{Bindings}->{$item2};
    }
    # now we must subsitute variables here
    return $item2;
  }
}

1;
