package System::Spark::Action;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Name Doc Vars Imp /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Name($args{Name});
  $self->Doc($args{Doc});
  $self->Vars($args{Vars} || []);
  $self->Imp($args{Imp});
}

# sub SPrint {
#   my ($self,%args) = @_;
#   return join
#     ("\n",
#      ("{defaction (".join(" ",($self->Name,@{$self->Vars})).")",
#       "imp: ".$self->Imp->Sprint,
#       "}"));

# }

sub SPrint {
  my ($self,%args) = @_;
  return join
    ("\n",
     ("{defaction (".join(" ",($self->Name,@{$self->Vars})).")",
      "doc: \"".$self->Doc."\"",
      "}"));

}

1;
