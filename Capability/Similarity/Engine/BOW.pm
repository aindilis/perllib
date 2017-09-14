package Capability::Similarity::Engine::BOW;

use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw/ Entries /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Entries($args{Entries});
}

sub Similarity {
  my ($self,%args) = @_;
  my $search = $args{Search};
  my $searchtokens = {};
  my $scores = {};
  foreach my $token (split /\W/, lc($search)) {
    $searchtokens->{$token} = 1;
  }

  foreach my $entry (keys %{$self->Entries}) {
    $scores->{$entry} = 0;
    foreach my $token (split /\W/, lc($entry)) {
      if (exists $searchtokens->{$token}) {
	$scores->{$entry}++;
      }
    }
  }
  return
    {
     Success => 1,
     Results => $scores,
    };
}

sub GetSortedScores {
  my ($self,%args) = @_;
  my $scores = $args{Scores};
  my @scores = sort {$scores->{$b} <=> $scores->{$a}} keys %{$self->Entries};
  return
    {
     Success => 1,
     Results => \@scores,
    };
}

sub PrintSortedScores {
  my ($self,%args) = @_;
  my $scores = $args{Scores};
  my $res1 = $self->GetSortedScores();
  if ($res1->{Success}) {
    foreach my $entry (@{$res1->{Results}}) {
      print $scores->{$entry}.' '.$entry."\n";
    }
  }
}


1;
