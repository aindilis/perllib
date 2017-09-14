package System::Rhyme;

# use Manager::Dialog qw(QueryUser);

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Rhymes /

  ];

sub init {
  my ($s,%a) = @_;
  $s->Rhymes({});
}

sub GetRhymes {
  my ($s,%a) = @_;
  my $word = $a{Word};
  if (! exists $s->Rhymes->{$word}) {
    my $res = `rhyme "$word"`;
    my @lines = split /\n/, $res;
    shift @lines;
    my $numsyl = 1;
    while (@lines) {
      my $line = shift @lines;
      if ($line =~ /^(\d+): (.+)$/) {
	$numsyl = $1;
	unshift @lines, $2;
      } else {
	foreach my $w2 (split /, /, $line) {
	  $w2 =~ s/^\s*//;
	  $w2 =~ s/\s*$//;
	  $s->Rhymes->{$word}->{$w2} = $numsyl;
	}
      }
    }
  }
  return $s->Rhymes->{$word};
}

1;
