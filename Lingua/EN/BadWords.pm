package Lingua::EN::BadWords;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Words /

  ];

sub init {
  my ($self,%args) = @_;
}

sub Load {
  my ($self,%args) = @_;
  $self->Words({});
  my $f = "/var/lib/myfrdcsa/datasets/badwords/badwords/badwords.txt";
  foreach my $word (split /\n/, `cat "$f"`) {
    $self->Words->{lc($word)} = 1;
  }
}

1;

# If only we had EAT (Edinburgh Association Thesaurus) working, we
# could also ocmpute how related words were to these ones.
