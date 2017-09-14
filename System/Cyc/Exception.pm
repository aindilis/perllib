package System::Cyc::Exception;
use Moose;
with 'Throwable';

has msg => (is => 'ro');
has rethrowable => (is => 'ro');

1;
