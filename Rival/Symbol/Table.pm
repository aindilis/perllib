package Rival::Symbol::Table;

use Rival::Symbol::Table::Package;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [
   qw / Root /
  ];

sub init {
  my ($self,%args) = @_;
  my $a = Rival::Symbol::Table::Package->new
    (
     Name => "main::",
     Package => undef,
    );
  $self->Root($a);
  # print Dumper($a);
}

1;
