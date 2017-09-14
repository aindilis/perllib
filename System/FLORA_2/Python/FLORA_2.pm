package System::FLORA_2::Python::FLORA_2;

use PerlLib::SwissArmyKnife;

use Moose;

use Inline Python => <<'END_OF_PYTHON_CODE';
import sys
# sys.path.append("/var/lib/myfrdcsa/sandbox/reasonablepython-0.1.2/reasonablepython-0.1.2")
# sys.path.append("/var/lib/myfrdcsa/sandbox/reasonablepython-0.1.2/reasonablepython-0.1.2/build/lib.linux-x86_64-2.7/rp/xsb_swig/")
# sys.path.append("/var/lib/myfrdcsa/sandbox/reasonablepy-20140307/reasonablepy-20140307")
# sys.path.append("/var/lib/myfrdcsa/sandbox/reasonablepy-20140307/reasonablepy-20140307/build/lib.l
sys.path.append("/var/lib/myfrdcsa/sandbox/reasonablepy-20140309/reasonablepy-20140309")
sys.path.append("/var/lib/myfrdcsa/sandbox/reasonablepy-20140309/reasonablepy-20140309/build/lib.linux-x86_64-2.7/rp/xsb_swig/")
from rp import *
def temp():
	class temp:
		def __init__(self):
			self.myTemp = f.Variable( 'X' )
		def Variable(self, var):
			return f.Variable( var )
		def query(self, query, list):
			f.query( query, list)
		def close_query(self):
			f.close_query()
		def Construct(self):
			f.Construct()
		def _and(self, a, b):
			a & b
		def _or(self, a, b):
			a | b
		def _rule(self, head, body):
			head << body
		def consult(self, file_name):
			try:
				f.consult( file_name )
			except Exception as e:
				print(e)
		def Bogus(self):
			f.Bogus()
	return temp();
END_OF_PYTHON_CODE

has 'FLORA_2' =>
  (
   is      => 'rw',
   lazy    => 1,
   default => sub { temp(); },
   handles => {
	       Variable => 'Variable',
	       query => 'query',
	       close_query => 'close_query',
	       Construct => 'Construct',
	       _and => '_and',
	       _or => '_or',
	       _rule => '_rule',
	       consult => 'consult',
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
