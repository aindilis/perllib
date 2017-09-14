my $sub_nodes = $module->find
  (
   sub { $_[1]->isa('PPI::Statement::Sub') and $_[1]->name }
  );

sub ProcessVariables {
  my %args = @_;
  # print Dumper(\%args);
  # extract out the lhs and rhs
  # get the variables
  my @lhss = $args{Node}->variables;
  my $cnt = scalar @lhss;
  # now for the symbols
  my @tmp;
  my @rhss;
  my $inrhs = 0;
  foreach my $subnode ($args{Node}->children) {
    if ($inrhs) {
      push @tmp, $subnode;
    }
    if ($subnode->isa('PPI::Token::Operator') and $subnode->content eq "=") {
      $inrhs = 1;
    }
  }
  if ($tmp[0]->isa('PPI::Token::Whitespace')) {
    shift @tmp;
  }
  if ($tmp[-1]->isa('PPI::Token::Structure') and $tmp[-1]->content eq ";") {
    pop @tmp;
  }
  if ($tmp[-1]->isa('PPI::Token::Whitespace')) {
    pop @tmp;
  }
  # go ahead and get this
  if ((scalar @tmp) != 1) {
    push @rhss, \@tmp;
  }
  if ($tmp[0]->isa('PPI::Structure::List')) {
    if ([$tmp[0]->children]->[0]->isa('PPI::Statement')) {
      my @list;
      my $i = 1;
      foreach my $subnode ([$tmp[0]->children]->[0]->children) {
	if ($subnode->isa('PPI::Token::Whitespace')) {

	} elsif ($subnode->isa('PPI::Token::Operator') and $subnode->content eq ',') {
	  my @copy = @list;
	  push @rhss, \@copy;
	  @list = ();
	} elsif ($subnode->isa('PPI::Token::Magic') and $subnode->content eq '@_') {
	  for my $i (1..($cnt - $i)) {
	    push @rhss,  bless( { 'content' => 'shift' }, 'PPI::Token::Symbol' );
	  }
	  push @rhss,  bless( { 'content' => '@_' }, 'PPI::Token::Magic' );
	} else {
	  push @list, $subnode;
	}
	++$i;
      }
      if (scalar @list) {
	push @rhss, \@list;
      }
    }
  } elsif ($tmp[0]->isa('PPI::Token::Magic') and $tmp[0]->content eq '@_') {
    for my $i (1..($cnt - 1)) {
      push @rhss,  bless( { 'content' => 'shift' }, 'PPI::Token::Symbol' );
    }
    push @rhss,  bless( { 'content' => '@_' }, 'PPI::Token::Magic' );
  }
  return {
	  Success => 1,
	  Result => {
		     RHSs => \@rhss,
		     LHSs => \@lhss,
		    },
	 };
}

sub JoinWithCarriageReturns {
  my %args = @_;
  my @list;
  foreach my $node (@{$args{Nodes}}) {
    push @list, bless( { 'content' => $args{Separator} }, 'PPI::Token::Whitespace' ) if scalar @list;
    my $ref = ref $node;
    if ($ref eq "ARRAY") {
      push @list, @$node;
    } else {
      push @list, $node;
    }
  }
  return @list;
}

sub NodeSerialize {
  my (%args) = @_;
  my $doc = PPI::Document->new();
  $doc->add_element(GetCopy(Node => $args{Node}));
  return $doc->serialize;
}

sub StringParse {
  my (%args) = @_;
  my $string = $args{String};
  my $doc = PPI::Document->new(\$string);
  return $doc;
}

sub GetCopy {
  my (%args) = @_;
  my $VAR1 = undef;
  eval Dumper($args{Node});
  return $VAR1;
}

sub Util {
  # $dumper->print;
  # my $res = $module->normalized;
  # print $res->{Document}->serialize."\n";
  # print Dumper([keys %$res]);
  # print $res->serialize;
  print $module->serialize;
}
