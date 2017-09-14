package System::Gate;

use Data::Dumper;
use NLP::Gate;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyAnnotation /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyAnnotation(NLP::GATE::Annotation->new());
}

sub AnnotateText {
  my ($self,%args) = @_;
  my $doc = NLP::GATE::Document->new();
  $doc->setText($args{Text});

}

1;
