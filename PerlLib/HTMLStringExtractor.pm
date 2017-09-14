package PerlLib::HTMLStringExtractor;

use HTML::TreeBuilder;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw( RejectRegexes )

  ];

sub init {
  my ($self,%args) = (shift,@_);
  $self->RejectRegexes($args{RejectRegexes} || []);
  #   my $rejectregexes = [
  # 		       qr/^\s*Date: /,
  # 		       qr/^\s*Location: /,
  # 		       qr/^\s*.+\@\w+\.(com|org|net)\s*$/,
  # 		       qr/^\s*Need cleaning/,
  # 		       qr/^.*craigslist\s*$/,
  # 		       qr/\bcity of\b/,
  # 		       qr/PostingID:/,
  # 		       qr/^[^\w]+$/,
  # 		      ];
}

sub ProcessItems {
  my ($self,%args) = @_;
  my $res = $self->ExtractStrings
    (
     Files => $args{Files},
     Items => $args{Items},
     SkipBlocking => 1,
     EntryCount => 100,
    );
  if ($res->{Success}) {
    my $res2 = $self->CleanEntries
      (
       Entries => $res->{Result},
      );
    if ($res2->{Success}) {
      my $block = $res2->{Result};
      my $res3 = $self->ExtractStrings
	(
	 Files => $args{Files},
	 Items => $args{Items},
	 Block => $block,
	 ShowProgress => 1,
	);
    }
  }
}

sub ExtractStrings {
  my ($self,%args) = @_;
  my @entries;
  if (exists $args{Files}) {
    foreach my $file (@{$args{Files}}) {
      if (-f $file and $file =~ /\.html?$/i) {
	my $tree = HTML::TreeBuilder->new;
	# print "<$file>\n";
	# now extract out all the items in between markings
	$tree->parse_file("$file");
	my $res = $self->ProcessTree
	  (Tree => $tree);
	if ($res->{Success}) {
	  push @entries, @{$res->{Result}};
	}
      }
    }
  }
  if (exists $args{Items}) {
    foreach my $item (@{$args{Items}}) {
      my $tree = HTML::TreeBuilder->new;
      $tree->parse($item);
      my $res = $self->ProcessTree
	(Tree => $tree);
      if ($res->{Success}) {
	push @entries, @{$res->{Result}};
      }
    }
  }
  return {
	  Success => 1,
	  Result => \@entries,
	 };
}

sub ProcessTree {
  my ($self,%args) = @_;
  my @entries;
  my $tree = $args{Tree};
  $tree->elementify;
  my $res = $self->ExtractStringsFromTree
    (Element => $tree);
  my $i = 0;
  if ($res->{Success}) {
    my @accepted;
    my @strings = @{$res->{Result}};
    foreach my $string (@strings) {
      if (! $args{SkipBlocking}) {
	my $block = 0;
	if ($args{Block} and exists $args{Block}->{$string}) {
	  $block = 1;
	} else {
	  foreach my $regex (@{$self->RejectRegexes}) {
	    if ($string =~ /$regex/) {
	      $block = 1;
	    }
	  }
	}
	if (! $block) {
	  push @accepted, $string;
	}
      } else {
	push @accepted, $string;
      }
    }
    push @entries, \@accepted;
    if ($args{ShowProgress}) {
      print Dumper(\@accepted);
    }
    # now we clean it out
    ++$i;
    if (defined $args{EntryCount} and $i > $args{EntryCount}) {
      last;
    }
  }
  return {
	  Success => 1,
	  Result => \@entries,
	 };
}

sub CleanEntries {
  my ($self,%args) = @_;
  my $count = 0;
  my $seen = {};
  foreach my $entry (@{$args{Entries}}) {
    my $seen2 = {};
    foreach my $item (@$entry) {
      $seen2->{$item}++;
    }
    foreach my $key (keys %$seen2) {
      $seen->{$key}++;
    }
    ++$count;
  }
  my $block = {};
  foreach my $key (keys %$seen) {
    if ($seen->{$key} > ($count / 3)) {
      $block->{$key} = 1;
    }
  }
  return {
	  Success => 1,
	  Result => $block,
	 };
}

sub ExtractStringsFromTree {
  my ($self,%args) = @_;
  my $element = $args{Element};
  my $ref = ref $element;
  my @strings;
  if ($ref eq "HTML::Element") {
    foreach my $arg (@{$element->{_content}}) {
      my $res = $self->ExtractStringsFromTree
	(Element => $arg);
      if ($res->{Success}) {
	push @strings, @{$res->{Result}};
      }
    }
  } elsif ($ref eq "") {
    push @strings, $element;
  } else {
    print Dumper
      ({
	Ref => $ref,
	Element => $element,
       });
  }
  return {
	  Success => 1,
	  Result => \@strings,
	 };
}

1;
