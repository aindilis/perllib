package PerlLib::TFIDF;

use Data::Dumper;
use Lingua::EN::Tagger;
# use TextMine::Tokens qw(tokens);
use Rival::String::Tokenizer;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Entries Files CheckedFiles MyTokenizer MyTagger Doc TF X
   FirstSeen TFIDF Prerequisite Half Rank List PrerequisiteFile TotalCount Hash /

  ];

sub init {
  my ($self,%args) = @_;
  $self->PrerequisiteFile($args{PrerequisiteFile} || "/tmp/prerequisites");
  $self->Entries($args{Entries} || {});
  if ($args{Files}) {
    $self->Files($args{Files} || []);
    $self->LoadFiles;
  }
  $self->MyTokenizer($args{Tokenizer} || Rival::String::Tokenizer->new());
  $self->MyTagger(Lingua::EN::Tagger->new);
  $self->Doc({});
  $self->TF({});
  $self->X({});
  $self->FirstSeen({});
  $self->TFIDF({});
  $self->TotalCount({});
}

sub LoadFiles {
  my ($self,%args) = @_;
  print "loading files\n";
  my @f;
  foreach my $file (@{$self->Files}) {
    if (-e $file and ! -d $file) {
      push @f, $file;
    }
  }
  $self->CheckedFiles(\@f);
  foreach my $file (@f) {
    my $c = `cat "$file"`;
    $self->Entries->{$file} = $c;
  }
}

sub ComputeTFIDF {
  my ($self,%args) = @_;
  # now for each text file, analyze its contents using TFIDF
  print "analyzing contents\n";
  my $i = 0;
  foreach my $key (sort keys %{$self->Entries}) {
    if (!($i % 500)) {
      print "$key\n";
    }
    ++$i;
    my $entry = $self->Entries->{$key};
    if (1) {
      $self->MyTokenizer->tokenize($entry);
      my $cnt = 0;
      foreach my $t ($self->MyTokenizer->getTokens()) {
	# print ".";
	if (! exists $self->FirstSeen->{$key}->{$t}) {
	  $self->FirstSeen->{$key}->{$t} = $cnt;
	}
	++$self->TF->{$t};
	if (! exists $self->Doc->{$key}->{$t}) {
	  ++$self->X->{$t};
	}
	++$self->Doc->{$key}->{$t};
	++$cnt;
      }
      $self->TotalCount->{$key} = $cnt;
      # print "\n";
    } else {
      # don't do tokens, do lowercased noun phrases
      my %word_list = $self->MyTagger->get_words( $entry );
      foreach my $t (keys %word_list) {
	$self->TF->{$t} += $word_list{$t};
	if (! exists $self->Doc->{$key}->{$t}) {
	  $self->X->{$t} += $word_list{$t};
	}
	$self->Doc->{$key}->{$t} += $word_list{$t};
      }
    }
  }

  print "\n";
  print "determine key words per document\n";
  # now determine key words per document using TFIDF
  my $n = scalar keys %{$self->Doc};
  if (1) {
    my $i;
    $self->TFIDF({});
    foreach my $d (sort keys %{$self->Doc}) {
      if (!($i % 500)) {
	print "$d\n";
      }
      ++$i;
#       foreach my $t (keys %{$self->X}) {
# 	# print ".";
# 	if ($self->X->{$t} > 0 and $self->TF->{$t} > 0) {
# 	  $self->TFIDF->{$d}->{$t} = log($self->TF->{$t}) * log($n / $self->X->{$t});
# 	} else {
# 	  $self->TFIDF->{$d}->{$t} = 0;
# 	}
#       }
      foreach my $t (keys %{$self->Doc->{$d}}) {
	# print ".";
	if ($self->X->{$t} > 0 and $self->Doc->{$d}->{$t} > 0) {
	  $self->TFIDF->{$d}->{$t} = log($self->Doc->{$d}->{$t} + 1) * log($n / $self->X->{$t});
	} else {
	  $self->TFIDF->{$d}->{$t} = 0;
	}
      }
      # print "\n";
      if (0) {
	foreach my $t (sort {$self->TFIDF->{$d}->{$b} <=> $self->TFIDF->{$d}->{$a}} keys %{$self->TFIDF->{$d}}) {
	  if ($t =~ /^[\w\s]+$/) {
	    print sprintf("%10f\t%s\n",$self->TFIDF->{$d}->{$t},$t);
	  }
	}
      }
    }
  }
  if (1) {
    print "\n";
    print "saving results\n";
    # now save these results
    my $OUT;
    open (OUT,">tfidf") or die "ouch!\n";
    print OUT Dumper($self->TFIDF);
    close (OUT);
    print "done\n";
  }

  print "\n";
  print "compute per document hash of useful stuff\n";
  $self->Half({});
  $self->Rank({});
  $self->List({});
  $i = 0;
  foreach my $d (sort keys %{$self->Doc}) {
    if (!($i % 500)) {
      print "$d\n";
    }
    ++$i;
    foreach my $t (keys %{$self->Doc->{$d}}) {
      $self->Half->{$d}->{$t} = 2 * $self->Doc->{$d}->{$t} / $self->TF->{$t};
      $self->Rank->{$d}->{$t} = 1 - abs(1 - $self->Half->{$d}->{$t});
    }
    my @list = sort {$self->Rank->{$d}->{$b} <=> $self->Rank->{$d}->{$a}} keys %{$self->Doc->{$d}};
    $self->List->{$d} = [splice (@list,0,1000)];
  }
}

sub ComputePrerequisites {
  my ($self,%args) = @_;
  print "\n";
  print "compute prerequisites\n";

  $self->Prerequisite({});
  foreach my $a (sort keys %{$self->Doc}) {
    print "$a\n";
    foreach my $b (sort keys %{$self->Doc}) {
      print ".";
      if (! exists $self->Prerequisite->{$a}->{$b}) {
	if ($a eq $b) {
	  # i.e. to  start reading this you  must have read  this is about
	  # half and half, if integrated through
	  $self->Prerequisite->{$a}->{$b} = 0;
	  $self->Prerequisite->{$b}->{$a} = -$self->Prerequisite->{$a}->{$b};
	} else {
	  my $scorea = 0;
	  my $scoreb = 0;
	  my $cnt = 0;
	  # $self->Hash($self->ListImportantSharedTokens($a,$b));
	  $self->Hash($self->QuickListImportantSharedTokens($a,$b));
	  my @array = $self->SortHash(Hash => $self->Hash);
	  foreach my $t (@array) {
	    if ($self->Hash->{$t} > 0.1) {
	      $scorea += $self->TotalCount->{$a} ? $self->FirstSeen->{$a}->{$t} / $self->TotalCount->{$a} : 0;
	      $scoreb += $self->TotalCount->{$b} ? $self->FirstSeen->{$b}->{$t} / $self->TotalCount->{$b} : 0;
	      $cnt++;
	    }
	  }
	  # print "$scorea\t$scoreb\n";

	  # now compute a measure

	  # if B  is a prerequisite of  A, then terms  should first appear
	  # sooner in A than in B.

	  $self->Prerequisite->{$a}->{$b} = $cnt ? ($scoreb - $scorea) / $cnt : 0;
	  $self->Prerequisite->{$b}->{$a} = -$self->Prerequisite->{$a}->{$b};
	}
      }
    }
    print "\n";
  }

  print "\n";
  print "saving results...\n";
  open (OUT,">".$self->PrerequisiteFile) or die "ouch!\n";
  print OUT Dumper($self->Prerequisite);
  close (OUT);
  print "done\n";

  # from  this now compute  a prerequisite  ordering that  maximizes the
  # prerequisite sum.  In other words, solve for a partial ordering that
  # maximizes cumulative prerequisite while minimizing reading, or any other method
}


sub ListImportantSharedTokens {
  my ($self, $a, $b) = (shift,shift,shift);
  # important shared tokens  would be tokens found in  these two texts
  # and found less often elsewhere
  my $shared = {};
  if (scalar %{$self->Doc->{$a}} > scalar %{$self->Doc->{$b}}) {
    my $c = $a;
    $a = $b;
    $b = $c;
  }
  foreach my $t (keys %{$self->Doc->{$a}}) {
    if (exists $self->Doc->{$b}->{$t}) {
      $shared->{$t} = 4 * ($self->Doc->{$a}->{$t} * $self->Doc->{$b}->{$t}) / ($self->TF->{$t} * $self->TF->{$t});
    }
  }
  return $shared;
}


sub QuickListImportantSharedTokens {
  my ($self, $a, $b) = (shift,shift,shift);
  # important shared tokens  would be tokens found in  these two texts
  # and found less often elsewhere
  my $shared = {};
  if (scalar @{$self->List->{$a}} > scalar @{$self->List->{$b}}) {
    my $c = $a;
    $a = $b;
    $b = $c;
  }
  foreach my $t (@{$self->List->{$a}}) {
    if (exists $self->Doc->{$b}->{$t}) {
      $shared->{$t} = $self->Half->{$a}->{$t} * $self->Half->{$b}->{$t};
    }
  }
  return $shared;
}

sub SortHash {
  my ($self,%args) = @_;
  return sort {$args{Hash}->{$b} <=> $args{Hash}->{$a}} keys %{$args{Hash}};
}

sub ComputeDocumentSimilarity {
  my ($self, $a, $b) = (shift,shift,shift);
  # important shared tokens  would be tokens found in  these two texts
  # and found less often elsewhere
  my $shared = $self->ListImportantSharedTokens($a,$b);
  my $score = 0;
  my $cnt = 0;
  foreach my $t (keys %$shared) {
    $score += $shared->{$t};
    ++$cnt;
  }
  # print "$score\n";
  return $score / ($cnt or 1);
}

1;
