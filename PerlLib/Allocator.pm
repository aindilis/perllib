package PerlLib::Allocator;

# there  are  numerous systems  now,  broker,  study, fieldgoal,  that
# require solving the cost/value knapsack problem.  we must therefore
# write this library to solve this problem

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / /

  ];

sub init {
  my ($self,%args) = @_;
}

1;
