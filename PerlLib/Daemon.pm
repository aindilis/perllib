package PerlLib::Daemon;

use Data::Dumper;

# use strict;
use Carp;

use vars qw/ $VERSION /;
$VERSION = '1.00';
use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / ProcessName User PIDFile LogFile / ];


sub init {
  my ($self,%args) = @_;
  $self->ProcessName($args{ProcessName});
  $self->User($args{User});
  $self->PIDFile($args{PIDFile});
  $self->LogFile($args{LogFile});
}

sub MakePidFile {
  my ($self,%args) = @_;

}

sub StartLogging {
  my ($self,%args) = @_;
}

sub SetUid {
  my ($self,%args) = @_;
  my $uid;
  my $user = $self->User;
  if ($user !~ /^\d+$/) {
    if (defined(my $uid = getpwnam($user))) {
      $user = $uid;
    }
  }
  if ($user) {
    $< = ($> = $user);
  }
}

1;
