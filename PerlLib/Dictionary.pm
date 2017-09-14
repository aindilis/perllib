package PerlLib::Dictionary;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyDictionary DictFiles CaseSensitive Verbose /

  ];

sub init {
  my ($self,%args) = @_;
  print "PerlLib::Dictionary initializating...\n" if $args{Verbose};
  $self->MyDictionary({});
  $self->CaseSensitive($args{CaseSensitive});
  $self->Verbose($args{Verbose});
  my @dictfiles;
  print "Searching for dictionary files\n" if $args{Verbose};
  if (! $args{DictFiles}) {
    my @potentials = qw(american-english-insane american-english-huge american-english-large american-english);
    while (@potentials) {
      my $potential = shift @potentials;
      if (-f "/usr/share/dict/$potential") {
	push @dictfiles, "/usr/share/dict/$potential";
	@potentials = ();
      }
    }
  } else {
    @dictfiles = @{$args{DictFiles}};
  }
  if (! scalar @dictfiles) {
    die "ERROR: No dictionaries found\n";
  }
  $self->DictFiles(\@dictfiles);
  foreach my $dictfile (@{$self->DictFiles}) {
    print "Loading dictionary file <$dictfile>\n" if $args{Verbose};
    my $c = `cat "$dictfile"`;
    if (! $self->CaseSensitive) {
      foreach my $w (split /\n/,$c) {
	$self->MyDictionary->{lc($w)}++;
      }
    } else {
      foreach my $w (split /\n/,$c) {
	$self->MyDictionary->{$w}++;
      }
    }
  }
  print "PerlLib::Dictionary initialization complete\n" if $args{Verbose};
}

sub Lookup {
  my ($self,%args) = @_;
  if ($self->MyDictionary->{$args{Word}} or
      (! $self->CaseSensitive and $self->MyDictionary->{lc($args{Word})})) {
    return 1;
  }
  return 0;
}

sub IsMisspelledP {
  my ($self,%args) = @_;
}

sub GetWordsHavingProperties {
  my ($self,%args) = @_;
  my $regex = $args{Regex};
  my @res;
  foreach my $phrase (sort keys %{$self->MyDictionary}) {
    if ($phrase =~ /$regex/) {
      push @res, $phrase;
    }
  }
  return {
	  Success => 1,
	  Result => \@res,
	 };
}

1;
