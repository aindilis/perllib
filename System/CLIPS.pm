package System::CLIPS;
use Moose;

use Data::Dumper;
use Inline Java => <<'END_OF_JAVA_CODE',
import CLIPSJNI.*;

class Clips {
   Environment clips;

   public Clips(){
      clips = new Environment();
   }

   public void assertString(String s){
      clips.assertString(s);
   }

   public void load(String s) {
      clips.load(s);
   }

   public void reset() {
      clips.reset();
   }

   public PrimitiveValue eval(String s) {
      return clips.eval(s);
   }

   public void destroy() {
      clips.destroy();
   }

   public void run() {
      clips.run();
   }

   public String findAllFacts(String s1, String s2){
      String evalStr = "(find-all-facts ((?f " + s1 + ")) TRUE)";
      String result = "";
      try
         { result = eval(evalStr).get(0).getFactSlot(s2).toString(); }
      catch (Exception e)
         { e.printStackTrace(); }
      return result;
   }
}
END_OF_JAVA_CODE
  AUTOSTUDY => 1,
  CLASSPATH => '/var/lib/myfrdcsa/sandbox/clipsjni-0.3/clipsjni-0.3/CLIPSJNI.jar',
  EXTRA_JAVA_ARGS => '-Djava.library.path=/var/lib/myfrdcsa/sandbox/clipsjni-0.3/clipsjni-0.3';

has 'clips' =>
  (
   is      => 'rw',
   lazy    => 1,
   default => sub { System::CLIPS::Clips->new() },
   handles => {
	       assertString => 'assertString',
	       load => 'load',
	       reset => 'reset',
	       eval => 'eval',
	       destroy => 'destroy',
	       run => 'run',
	      },
  );

sub facts {
  my ($self,%args) = @_;
  $self->eval('(facts)');
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=pod

=head1 NAME

System::CLIPS - A wrapper for the CLIPS expert system shell

=head1 SYNOPSIS

  use System::CLIPS;
  my $clips = new System::CLIPS;
  $clips->load("clips-file.clp");
  $clips->reset;
  $clips->run;
  $clips->facts;

=head1 DESCRIPTION

System::CLIPS is a wrapper for CLIPS.

=head1 EXPORTED FUNCTIONS

=head1 METHODS

=head1 BUGS

What could possibly go wrong?

If you have an error like:

Can't receive packet from JVM: or
Clips : Unsupported major.minor version 51.0

Try finding and removing the _Inline directory, which should be in the
path where the containing program was run.

=head1 TODO

Support should be added for Persistence using FreeKBS2.

=head1 AUTHOR

Andrew DoughertyE<lt>andrew.dougherty@ionzero.comE<gt>

=cut

