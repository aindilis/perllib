package System::Liferea::Feed;

use Data::Dumper;
# use XML::Xerces;
use XML::Simple;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Filename Contents Parsed /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Filename($args{Filename});
  $self->Contents($args{Contents});
}

sub Parse {
  my ($self,%args) = @_;  
  my $ref = XMLin($self->Contents);
  $self->Parsed($ref);
}

1;
