package PerlLib::Reviewer;

use Manager::Dialog qw(Approve Choose ChooseByProcessor Message QueryUser SubsetSelect);

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Entries PreviousEntries Properties Handlers KeyProcessor
   PrintProcessor Classes MyEntry /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Entries
    ($args{Entries} || []);
  $self->PreviousEntries
    ($args{PreviousEntries} || []);
  $self->Properties
    ($args{Properties} || {});
  $self->Handlers
    ($args{Handlers});
  $self->KeyProcessor
    ($args{KeyProcessor} || sub {shift @_});
  $self->PrintProcessor
    ($args{PrintProcessor} || sub {shift @_});
}

sub Review {
  my ($self,%args) = @_;
  my @commands = qw|ignore correct next_entry previous_entry
    next_untouched_entry|;
  my %sizes;
  $self->Classes([sort keys %{$self->Handlers}]);
  $self->PreviousEntries([]);
  $self->MyEntry(shift @{$self->Entries});
  while (@{$self->Entries}) {
    # clear screen
    system "clear";
    $size{commands} = scalar @commands;
    $size{classes} = scalar @{$self->Classes};
    my @menu = @commands;
    push @menu, @{$self->Classes};
    $self->PrintEntry
      (Entry => $self->MyEntry);
    my $key = $self->KeyProcessor->($self->MyEntry);
    my $choice = UIChoose(@menu);
    if ($choice >= 0) {
      if ($choice < $size{commands}) {
	my $command = $commands[$choice];
	if ($command eq "next_entry") {
	  $self->Advance;
	} elsif ($command eq "next_untouched_entry") {
	  do {
	    $self->Advance;
	  } while ((exists $self->Properties->{$key}) and
		   ((scalar keys %{$self->Properties->{$key}})));
	} elsif ($command eq "ignore") {
	  $self->Properties->{$key}->{"ignore"} = ! $self->Properties->{$key}->{"ignore"};
	  $self->Advance;
	} elsif ($command eq "correct") {
	  $self->Properties->{$key}->{"correct"} = ! $self->Properties->{$key}->{"correct"};
	  $self->Advance;
	} elsif ($command eq "previous_entry") {
	  $self->Recede;
	}
      } elsif ($choice < $size{commands} + $size{classes}) {
	my $class = $self->Classes->[$choice-$size{commands}];
	print Dumper($class);
	if (defined ($self->Properties->{$key}->{$class})) {
	  delete $self->Properties->{$key}->{$class};
	} else {
	  $self->Properties->{$key}->{$class} = 1;
	}
      }
    }
  }
}

sub UIChoose {
  my @list = @_;
  my $i = 0;
  if (!@list) {
    return;
  } elsif (@list == 1) {
    print "<Chose:".$list[0].">\n";
    return $list[0];
  } else {
    foreach my $item (@list) {
      print "$i) $item\n";
      ++$i;
    }
    my $response;
    while (defined ($response = <STDIN>) and ($response !~ /^\d+$/)) {
    }
    chomp $response;
    return $response;
  }
}

sub PrintEntry {
  my ($self,%args) = (shift,@_);
  print "#" x 80;
  print "\n";
  my $contents = $self->PrintProcessor->($args{Entry});
  print "<<<".$contents.">>>\n";
  my $key = $self->KeyProcessor->($args{Entry});
  print Dumper($self->Properties->{$key});
  print "\n";
}

sub Advance {
  my $self = shift;
  # print "$class\n";
  # &{$self->Handlers->{$class}}($entry);

  if (scalar @{$self->Entries}) {
    push @{$self->PreviousEntries}, $self->MyEntry;
    $self->MyEntry(shift @{$self->Entries});
  } else {
    print "Entries empty\n";
  }
}

sub Recede {
  my $self = shift;
  if (scalar @{$self->PreviousEntries}) {
    unshift @{$self->Entries},$self->MyEntry;
    $self->MyEntry(pop @{$self->PreviousEntries});
  } else {
    print "Previous entries empty\n";
  }
}

sub HasProperties {
  my ($self,%args) = (shift,@_);
  if ((exists $self->Properties->{$args{Entry}->ID}) and
	(scalar keys %{$self->Properties->{$args{Entry}->ID}})) {
    return 1;
  } else {
    return 0;
  }
}

1;
