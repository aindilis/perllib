package System::Spark::Procedure;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Name Doc Cue Precondition Body /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Name($args{Name});
  $self->Doc($args{Doc});
  $self->Cue($args{Cue});
  $self->Precondition($args{Precondition});
  $self->Body($args{Body} || []);
}

# sub SPrint {
#   my ($self,%args) = @_;
#   return join
#     ("\n",
#      ("{defprocedure ".$self->Name,
#       "cue: ".$self->Cue->SPrint,
#       "precondition: ".$self->Precondition->SPrint,
#       "body:",
#       $self->Body->SPrint,
#       "}"));
# }

sub SPrint {
  my ($self,%args) = @_;
  return join
    ("\n",
     ("{defprocedure ".$self->Name,
      "doc: \"".$self->Doc."\"",
      "cue: []",
      "precondition: []",
      "body:",
      join ("\n",map {$_} @{$self->Body}),
      "}"));
}

1;
