package System::MinorThird::Entry;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / ID StorageFile Contents Results / ];

sub init {
  my ($self,%args) = @_;
  $self->ID($args{ID});
  $self->StorageFile($args{StorageFile});
  $self->Contents($args{Contents});
  $self->Results($args{Results});
}

sub SaveContentsToStorageFile {
  my ($self,%args) = @_;
  return unless $self->StorageFile;
  if ($args{Force} or ! -f $self->StorageFile) {
    my $OUT;
    open (OUT,">".$self->StorageFile) and print OUT $self->Contents and close(OUT);
  }
}

1;
