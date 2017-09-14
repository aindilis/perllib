package System::WWW::OpenCalais::TextSimpleParser;

use Data::Dumper;

use XML::Simple;

use Class::MethodMaker
  new_with_init => 'new',
  get_set =>
  [
   qw / MyStore MyModel MyParser /
  ];

sub init {
  my ($self,%args) = @_;
}

sub Parse {
  my ($self,%args) = @_;
  # print Dumper({Contents => $args{Contents}});
  return unless defined $args{Contents};
  my $ref = XMLin($args{Contents});
  # print Dumper($ref);
  return $ref;
}

1;
