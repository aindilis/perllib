package TestError;

use Moose;

use Data::Dumper;
use Error qw(:try);
use base Error::Simple;

sub Test1 {
  my ($self) = @_;
  throw TestError->new("A simple error")
}

sub Test2 {
  my ($self) = @_;
  die "hi";
}

sub Test3 {
  my ($self) = @_;
  try {
    #$self->Test1();
    throw Error::Simple("x");
  } catch Error::Simple with {
    my $E = shift;
    print(Dumper($E)."\n");
  };
}

1;
