package PerlLib::Collection2;

use MyFRDCSA;
use Manager::Dialog qw ( Approve Message Choose SubsetSelect );
use Sayer;

use Data::Dumper;
use File::Temp;
use File::stat;

# use strict;
use Carp;

use vars qw/ $VERSION /;
$VERSION = '1.00';
use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / AutoIncrementValue Type Contents StorageMethod StorageFile CollectionName MySayer / ];


sub init {
  my ($self, %args) = @_;
  $self->Type($args{Type});
  $self->StorageMethod($args{StorageMethod} || "file");
  if ($self->StorageMethod eq "file") {
    $self->StorageFile($args{StorageFile} || NewTempFileName());
  } elsif ($self->StorageMethod eq "mysql") {
    $self->CollectionName($args{Collection}) or die "No collection name\n";

  } elsif ($self->StorageMethod eq "sayer") {
    $self->CollectionName($args{Collection}) or die "No collection name\n";
    # need to figure out what goes here
    # $self->MySayer
    #   (Sayer->new
    #    ());
  } elsif ($self->StorageMethod eq "none") {
    # FIXME
  }
}

sub NewTempFileName {
  my ($self,%args) = @_;
  my $rootdir = "/tmp";
  my ($unopened_file, $file);
  do {
    $unopened_file = mktemp( "$rootdir/perllib-collection-XXXXXXXX" );
    # $file = ConcatDir($rootdir,$unopened_file);
    $file = $unopened_file;
  } while (-f $file);
  return $file;
}

sub Add {
  my ($self,%args) = @_;
  while (my ($key,$value) = each %args) {
    $self->Contents->{$key} = $value;
  }
}

sub AddAutoIncrement {
  my ($self,%args) = @_;
  if (! $self->AutoIncrementValue) {
    # obtain the max key value
    my $max = -1;
    foreach my $key ($self->Keys) {
      if ($key =~ /^\d+$/) {
	if ($key > $max) {
	  $max = $key;
	}
      }
    }
    $self->AutoIncrementValue($max+1);
  }
  my $ai = $self->AutoIncrementValue;
  $self->Add($ai => $args{Item});
  $self->AutoIncrementValue($ai+1);
  return $ai;
}

sub Subtract {
  my ($self,%args) = @_;
  while (my ($key,$value) = each %args) {
    delete $self->Contents->{$key};
  }
}

sub SubtractByKey {
  my ($self,@keys) = @_;
  foreach my $key (@keys) {
    delete $self->Contents->{$key};
  }
}

sub SubtractByValue {
  my ($self,@values) = @_;
  foreach my $value (@values) {
    delete $self->Contents->{$key};
  }
}

sub Keys {
  my ($self,%args) = @_;
  return keys %{$self->Contents};
}

sub Values {
  my ($self,%args) = @_;
  return values %{$self->Contents};
}

sub List {
  my ($self,%args) = @_;
  return %{$self->Contents};
}

sub IsEmpty {
  my ($self,%args) = @_;
  if (scalar %{$self->Contents}) {
    return 0;
  } else {
    return 1;
  }
}

sub Count {
  my ($self,%args) = @_;
  return scalar $self->Keys;
}


sub SelectSubset {
  my ($self,%args) = @_;
  return $self->SelectSubsetByValue;
}

sub SelectSubsetByValue {
  my ($self,%args) = @_;
  map {$_,$self->Contents->{$_}} SubsetSelect(Set => [$self->Keys],
					   Selection => {});
}

sub SelectSubsetByKey {
  my ($self,%args) = @_;
  SubsetSelect(Set => [$self->Keys],
	       Selection => {});
}

sub SelectSubsetByKeyValue {
  my ($self,%args) = @_;
  map {+($_, $self->Contents->{$_})} SubsetSelect(Set => [$self->Keys],
						  Selection => {});
}

sub SelectValuesByProcessor {
  my ($self,%args) = @_;
  my @entries = map &{$args{Processor}}, $self->Values;
  my $h1 = {};
  my @res = SubsetSelect
    (Set => \@entries,
     Selection => $args{Selection} || {});
  foreach my $entry (@res) {
    $h1->{$entry} = 1;
  }
  my @matches;
  foreach my $v ($self->Values) {
    my @t = map &{$args{Processor}},($v);
    if (exists $h1->{$t[0]}) {
      push @matches, $v;
    }
  }
  return \@matches;
}

sub MatchValuesByProcessor {
  my ($self,%args) = @_;
  my @matches;
  foreach my $v ($self->Values) {
    if ($args{Processor}->($v)) {
      push @matches, $v;
    }
  }
  return \@matches;
}

sub PrintKeys {
  my ($self,%args) = @_;
  foreach my $item ($self->Keys) {
    print "$item\n";
  }
}

sub PrintValues {
  my ($self,%args) = @_;
  foreach my $item ($self->Values) {
    $item->Print;
  }
}

sub SPrintValues {
  my ($self,%args) = @_;
  foreach my $item ($self->Values) {
    $item->SPrint;
  }
}

sub SPrintSortedValues {
  my ($self,%args) = @_;
  my $retval;
  foreach my $item (@{$self->GetSortedValues}) {
    $retval .= $item->SPrint."\n";
  }
  return $retval;
}

sub Behead {
  my ($file) = (shift);
  if ($file =~ /^(.*)\/([^\/]+)$/) {
    return ($2,$1);
  }
}

sub Save {
  my ($self,%args) = @_;
  if ($self->StorageMethod eq "file") {
    my $file = $self->StorageFile;
    my $OUT;
    if (! -f $file) {
      my ($head,$body) = Behead($file);
      if (-d $body) {
	$file = "$body/$head";
      } else {
	$file = "/tmp/$head";
      }
    }
    open(OUT,">$file");
    print OUT Dumper($self->Contents);
    close(OUT);
  } elsif ($self->StorageMethod eq "mysql") {
    # FIXME
  } elsif ($self->StorageMethod eq "none") {
    # FIXME
  }
}

sub Load {
  my ($self,%args) = @_;
  if ($self->StorageMethod eq "file") {
    if (-f $self->StorageFile.".tmp" ) {
      # here is our previous version of it, so lets copy it over
      if (-f $self->StorageFile) {
	# only if we should
	my $i1 = stat($self->StorageFile.".tmp");
	my $i2 = stat($self->StorageFile);
	if ($i1->size >= $i2->size) {
	  system "cp ".$self->StorageFile.".tmp ".$self->StorageFile;
	}
      } else {
	system "cp ".$self->StorageFile.".tmp ".$self->StorageFile;
      }
    }
    if (-f $self->StorageFile) {
      # read it in with data dumper
      my $file = $self->StorageFile;
      my $query = "cat $file";
      my $contents = `$query`;
      my $VAR1 = eval $contents;
      # print Dumper($VAR1);
      $self->Contents($VAR1);
      my $type = ref $self->Contents;
      if ($type ne "HASH") {
	print Dumper($self->Contents);
	print "Type: <$type>\n";
	print "Corrupted file: <$file>\n";
	$self->Contents({});
	if (Approve("Remove file?")) {
	  system "rm $file";
	}
      }
    } else {
      $self->Contents({});
    }
  } elsif ($self->StorageMethod eq "mysql") {
    # FIXME
  } elsif ($self->StorageMethod eq "none") {
    # FIXME
    $self->Contents({});
  }
}

sub ChooseValuesByProcessor {
  my ($self,%args) = @_;
  my @entries = ("_Cancel");
  push @entries, map &{$args{Processor}}, $self->Values;
  my $entry = Choose(@entries);
  my @matches;
  foreach my $v ($self->Values) {
    my @t = map &{$args{Processor}},($v);
    if ($t[0] eq $entry) {
      push @matches, $v;
    }
  }
  return \@matches;
}

sub Merge {
  my ($self,%args) = @_;
  # should we have a collection of collections to merge? hehe,
  # actually kind of makes sense, although scary
  foreach my $col (@{$args{Collections}}) {
    # don't worry about checking types for now, we don't know how to
    # program with exceptions anyway
    while (my ($key,$value) = each %{$col->Contents}) {
      $self->Add($key => $value);
    }
  }
}

sub GetSortedValues {
  my ($self,%args) = @_;
  my @keys = sort $self->Keys;
  my @values;
  foreach my $key (@keys) {
    push @values, $self->Contents->{$key};
  }
  return \@values;
}

sub HasValue {
  my ($self,%args) = @_;
  my $matches = $self->MatchValuesByProcessor
      (
       Processor => sub { $_[0] eq $args{Value} }
      );
  return ! ! scalar @$matches;
}

1;
