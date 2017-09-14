package PerlLib::Lisp;

use Data::Dumper;

require Exporter;
@ISA = qw(Exporter);

@EXPORT = qw (StringStructure LispStringToLispStructure
LispStructureToLispString);

sub StringStructure {
  my (%args) = @_;
  if ($args{Structure}) {
    return {String => LispStructureToLispString
	    (LispStructure => $args{Structure}),
	    Structure => $args{Structure}};
  } elsif ($args{String}) {
    return {String => $args{String},
	    Structure => LispStringToLispStructure
	    (LispString => $args{String})};
  }
}

sub LispStringToLispStructure {
  my (%args) = @_;
  my $c = $args{LispString};
  $c =~ s/;.*//mg;
  my $tokens = [split //,$c];
  my $cnt = 0;
  my $stack = [];
  my $symbol = "";
  do {
    $char = shift @$tokens;
    if ($char =~ /\(/) {
      ++$cnt;
      $stack->[$cnt] = [];
      $symbol = "";
    } elsif ($char =~ /[\s\n]/) {
      if (length $symbol) {
	push @{$stack->[$cnt]},$symbol;
	$symbol = "";
      }
    } elsif ($char =~ /\)/) {
      # now $stack->[$cnt] holds all of  our objects, and so just have
      # to move those into the right place
      if (length $symbol) {
	push @{$stack->[$cnt]},$symbol;
	$symbol = "";
      }
      my @a = @{$stack->[$cnt]};
      $stack->[$cnt] = undef;
      --$cnt;
      push @{$stack->[$cnt]}, \@a;
    } else {
      if ($char !~ /\s/) {
	$symbol .= $char;
      }
    }
  } while (@$tokens);
  $domain = $stack->[0]->[0];
  return $domain;
}

sub LispStructureToLispString {
  my (%args) = @_;
  my $structure = $args{LispStructure};
  if (ref $structure eq "ARRAY") {
    $args{Indent} = $args{Indent} || 0;
    my $indentation = (" " x $args{Indent});
    my $retval = "$indentation(";
    my $total = scalar @$structure;
    my $cnt = 0;
    my $l = 0;
    foreach my $x (@$structure) {
      ++$cnt;
      if (ref $x eq "ARRAY") {
	if ($args{Depth} and $args{Depth} > 1) {
	  my $c = LispStructureToLispString
	    (LispStructure => $x,
	     Indent => 0,
	     Depth => $args{Depth} ? $args{Depth} + 1 : 1);
	  $retval .= "$c";
	} else {
	  my $c = LispStructureToLispString
	    (LispStructure => $x,
	     Indent => $args{Indent} + 1,
	     Depth => $args{Depth} ? $args{Depth} + 1 : 1);
	  $retval .= "\n$c";
	}
	$l = 1;
	# $retval .= "\n" unless $cnt == $total;
      } else {
	if ($l == 1) {
	  $retval .= " ";
	  $l = 0;
	}
	if ($x =~ /^:/) {
	  # do a return thing
	  $retval .= "\n$indentation";
	}
	$retval .= "$x";
	$retval .= " " unless $cnt == $total;
      }
    }
    $retval .= ")";
    return $retval;
  } else {
    return $structure;
  }
}

sub LispStructureToLispStringOld {
  my (%args) = @_;
  my $structure = $args{LispStructure};
  if (ref $structure eq "ARRAY") {
    $args{Indent} = $args{Indent} || 0;
    my $indentation = (" " x $args{Indent});
    my $retval = "$indentation(";
    my $total = scalar @$structure;
    my $cnt = 0;
    my $l = 0;
    foreach my $x (@$structure) {
      ++$cnt;
      if (ref $x eq "ARRAY") {
	my $c = LispStructureToLispString
	  (LispStructure => $x,
	   Indent => $args{Indent} + 1);
	$retval .= "\n$c";
	$l = 1;
	# $retval .= "\n" unless $cnt == $total;
      } else {
	if ($l == 1) {
	  $retval .= " ";
	  $l = 0;
	}
	$retval .= "$x";
	$retval .= " " unless $cnt == $total;
      }
    }
    $retval .= ")";
    return $retval;
  } else {
    return $structure;
  }
}

1;
