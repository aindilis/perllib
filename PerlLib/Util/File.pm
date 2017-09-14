package PerlLib::Util::File;

use vars qw/ $VERSION /;
$VERSION = '1.00';
use strict;
use File::Basename;
use Class::MethodMaker new_with_init => 'new',
  get_set       => [ qw / Name Spec / ];

sub init {
  my ($self,%args) = @_;
  $self->Name($args{Name});
}

sub DirName {
  my ($self,%args) = @_;
  dirname($self->Name);
}

sub Open {
  my ($self,%args) = @_;
  $self->Spec->updir;
}

sub Writable {
  my ($self,%args) = @_;
  -W $self->Name;
}

sub Exists {
  my ($self,%args) = @_;
  -e $self->Name;
}

sub Directory {
  my ($self,%args) = @_;
  -d $self->Name;
}

sub Contents {
  my ($self,%args) = @_;
  if ($self->Exists) {
    my $name = $self->Name;
    my $c = `cat "$name"`;
    return $c;
  }
}

sub Remove {
  my ($self,%args) = @_;
  if ($self->Exists) {
    my $name = $self->Name;
    my $c = `rm "$name"`;
    return $c;
  }
}

1;
