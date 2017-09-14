package Rival::PPI::_Util;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw ( ProcessVariables JoinWithCarriageReturns Util StringParse GetCopy NodeSerialize InsertChildren );

use Data::Dumper;

sub Util {
  # $dumper->print;
  # my $res = $module->normalized;
  # print $res->{Document}->serialize."\n";
  # print Dumper([keys %$res]);
  # print $res->serialize;
  print $module->serialize;
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

sub StringParse {
  my (%args) = @_;
  my $string = $args{String};
  my $doc = PPI::Document->new(\$string);
  return $doc;
}

sub ProcessVariables {
  my %args = @_;
  # print Dumper($args{Node});
  # print Dumper(\%args);
  # extract out the lhs and rhs
  # get the variables
  my @lhss;
  # my @lhss = $args{Node}->variables;
  # my $cnt = scalar @lhss;
  # now for the symbols
  my $cnt = 1;
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
  } else {
    push @rhss, $tmp[0];
  }
  return {
	  Success => 1,
	  Result => {
		     RHSs => \@rhss,
		     LHSs => \@lhss,
		    },
	 };
}

sub NodeSerialize {
  my (%args) = @_;
  my $doc = PPI::Document->new();
  $doc->add_element(GetCopy(Node => $args{Node}));
  return $doc->serialize;
}

sub GetCopy {
  my (%args) = @_;
  my $VAR1 = undef;
  eval Dumper($args{Node});
  return $VAR1;
}

# (hi,ho,he)
#   0  1  2
# insertchildren(node,1,[howdy])
# (hi,howdy,ho,he)

sub InsertChildren {
  my (%args) = @_;
  # array bounds checking
  my $node = $args{Node};
  my $children = $args{Children};
  my $position = $args{Position};
  if ($node->isa("PPI::Node")) {
    # now we have to remove the subnodes from the occuring including and
    # after the position, then add the children, then readd the subnodes
    my @children = $node->children;
    my @end = splice @children, $position;
    my @newlist = (@children,@$children,@end);
    $node->{children} = \@newlist;
  } else {
    print "ERROR, not a PPI::Node\n";
  }
}

1;
