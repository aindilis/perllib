package Capability::LogicForm;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Name Engine /

  ];

sub init {
  my ($self,%args) = @_;
  my $name = $args{EngineName} || "FreeLogicForm"; # "CAndC";
  $self->Name($name);
  require "Capability/LogicForm/Engine/$name.pm";
  $self->Engine("Capability::LogicForm::Engine::$name"->new
		(
		 Fast => $args{Fast},
		));
}

sub StartServer {
  my ($self,%args) = @_;
  $self->Engine->StartServer
    (%args);
}

sub StartClient {
  my ($self,%args) = @_;
  $self->Engine->StartClient;
}

sub LogicForm {
  my ($self,%args) = @_;
  return $self->Engine->LogicForm
    (
     Text => $args{Text},
     Type => $args{Type},
     WSD => $args{WSD},
    );
}

1;
