package Capability::LogicForm::Engine::CAndC;

use System::CAndC;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyCAndC  /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyCAndC(System::CAndC->new);
}

sub StartServer {
  my ($self,%args) = @_;
  $self->MyCAndC->StartServer;
}

sub StartClient {
  my ($self,%args) = @_;

}

sub LogicForm {
  my ($self,%args) = @_;
  return $self->MyCAndC->LogicForm
    (Text => $args{Text});
}

1;
