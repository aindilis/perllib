package System::FLORA_2::Python::FLORA_2_SPADE;

use PerlLib::SwissArmyKnife;

use Moose;

use Inline Python => <<'END_OF_PYTHON_CODE';
import sys
sys.path.append("/var/lib/myfrdcsa/sandbox/spade-2.2.1/spade-2.2.1/spade")
from Flora2KB import Flora2KB
from logic import KB
def Flora2():
	return Flora2KB()
END_OF_PYTHON_CODE

has 'FLORA_2' =>
  (
   is      => 'rw',
   lazy    => 1,
   default => sub { Flora2(); },
   handles => {
	       tell => 'tell',
	       ask => 'ask',
	       retract => 'retract',
	       loadModule => 'loadModule',
	      },
  );

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=pod

=head1 NAME

System::FLORA_2::Python::FLORA_2 - A wrapper for the FLORA-2 Python API

=head1 SYNOPSIS

  use System::FLORA_2::Python::FLORA_2;
  my $flora2 = System::FLORA_2::Python::FLORA_2->new;

=head1 DESCRIPTION

System::FLORA_2::Python::FLORA_2 is a wrapper for the FLORA-2 Python
API, which is itself a wrapper for the FLORA-2 XSB C API.

=head1 EXPORTED FUNCTIONS

=head1 METHODS

=head1 BUGS

What could possibly go wrong?


=head1 TODO

Support should be added for Persistence using FreeKBS2.

=head1 AUTHOR

Andrew DoughertyE<lt>andrewdo@frdcsa.orgE<gt>

=cut
