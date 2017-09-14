package PerlLib::SourceManager;

use Manager::Dialog qw(Message SubsetSelect);
use PerlLib::Collection;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw { ListOfSources MySources System Type Conf }

  ];

sub init {
  my ($self,%args) = @_;
  $self->System($args{System});
  print Dumper($self->System);
  $self->Conf($args{Conf});
  $self->Type($args{Type});
  my $system = $self->System;
  my $system2 = $system;
  $system2 =~ s/::/\//g;
  Message(Message => "Initializing sources...");
  my $dir = "$UNIVERSAL::systemdir/$system2/Source";
  my @names = sort map {$_ =~ s/.pm$//; $_} grep(/\.pm$/,split /\n/,`ls $dir`);
  # my @names = qw(AptCache);
  $self->ListOfSources(\@names);
  $self->MySources
    (PerlLib::Collection->new
     (Type => "PerlLib::SourceTemplate"));
  $self->MySources->Contents({});
  foreach my $name (@{$self->ListOfSources}) {
    Message(Message => "Initializing $system2/Source/$name.pm...");
    require "$dir/$name.pm";
    my $s = "${system}::Source::$name"->new();
    $self->MySources->Add
      ($name => $s);
  }
}

sub UpdateSources {
  my ($self,%args) = @_;
  Message(Message => "Updating sources...");
  my @keys;
  if (defined $args{Sources} and ref $args{Sources} eq "ARRAY") {
    @keys = @{$args{Sources}};
  }
  if (!@keys) {
    @keys = $self->MySources->Keys;
  }
  foreach my $key (@keys) {
    Message(Message => "Updating $key...");
    $self->MySources->Contents->{$key}->UpdateSource;
  }
}

sub LoadSources {
  my ($self,%args) = @_;
  Message(Message => "Loading sources...");
  my @keys;
  if (defined $args{Sources} and ref $args{Sources} eq "ARRAY") {
    @keys = @{$args{Sources}};
  }
  if (!@keys) {
    @keys = $self->MySources->Keys;
  }
  foreach my $key (@keys) {
    Message(Message => "Loading $key...");
    $self->MySources->Contents->{$key}->LoadSource;
  }
}

sub Search {
  my ($self,%args) = @_;
  my @ret;
  foreach my $pos (sort @{$self->SearchSources
			    (Criteria => ($args{Criteria} or
			     $args{Search} ? {Any => $args{Search}} : $self->GetSearchCriteria),
			     Search => $args{Search},
			     Sources => $args{Sources})}) {
    push @ret, $pos;
  }
  @ret = sort {$a->ID cmp $b->ID} @ret;
  return \@ret;
}

sub Choose {
  my ($self,%args) = @_;
  $positionmapping = {};
  foreach my $pos
    (sort @{$self->SearchSources
	      (Criteria => $self->GetSearchCriteria,
	       Sources => $args{Sources})}) {
      $positionmapping->{$pos->SPrint} = $pos;
    }
  my @chosen = SubsetSelect
    (Set => \@set,
     Selection => {});
  my @ret;
  foreach my $name (@chosen) {
    push @ret, $positionmapping->{$name};
  }
  return \@ret;
}

sub SearchSources {
  my ($self,%args) = @_;
  Message(Message => "Searching sources...");
  my @keys;
  if (defined $args{Sources} and ref $args{Sources} eq "ARRAY") {
    @keys = @{$args{Sources}};
  }
  if (!@keys) {
    @keys = $self->MySources->Keys;
  }
  my @matches;
  my $type = $self->Type;
  my $attribute = "My${type}s";
  foreach my $key (@keys) {
    my $source = $self->MySources->Contents->{$key};
    if (! $source->Loaded) {
      Message(Message => "Loading $key...");
      $source->$attribute->Load;
      Message(Message => "Loaded ".$source->$attribute->Count." ${type}s.");
      $source->Loaded(1);
    }
    if (! $source->$attribute->IsEmpty) {
      Message(Message => "Searching $key...");
      foreach my $x ($source->$attribute->Values) {
	if ($x->Matches(Criteria => $args{Criteria})) {
	  push @matches, $x;
	}
      }
    }
  }
  return \@matches;
}

sub GetSearchCriteria {
  my ($self,%args) = @_;
  my %criteria;
  my $conf = $self->Conf;
  if (exists $conf->{-a}) {
    $criteria{Any} = $conf->{-a};
  }
  if (exists $conf->{-n}) {
    $criteria{ID} = $conf->{-n};
  }
  if (exists $conf->{-d}) {
    $criteria{Description} = $conf->{-d};
  }
  if (exists $args{Search}) {
    $criteria{ID} = $args{Search};
  }
  if (! %criteria) {
    foreach my $field
      (qw (ID Description)) {
	Message(Message => "$field?: ");
	my $res = <STDIN>;
	chomp $res;
	if ($res) {
	  $criteria{$field} = $res;
	}
      }
  }
  return \%criteria;
}

sub GetEntries {
  my ($self,%args) = @_;
  Message(Message => "Searching sources...");
  my @keys;
  if (defined $args{Sources} and ref $args{Sources} eq "ARRAY") {
    @keys = @{$args{Sources}};
  }
  if (!@keys) {
    @keys = $self->MySources->Keys;
  }
  my @entries;
  my $type = $self->Type;
  my $attribute = "My${type}s";
  foreach my $key (@keys) {
    my $source = $self->MySources->Contents->{$key};
    if (! $source->Loaded) {
      Message(Message => "Loading $key...");
      $source->$attribute->Load;
      Message(Message => "Loaded ".$source->$attribute->Count." ${type}s.");
      $source->Loaded(1);
    }
    if (! $source->$attribute->IsEmpty) {
      Message(Message => "Searching $key...");
      foreach my $x ($source->$attribute->Values) {
	push @entries, $x;
      }
    }
  }
  return \@entries;
}

1;
