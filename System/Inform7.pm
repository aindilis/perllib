package System::Inform7;

use PerlLib::SwissArmyKnife;

use Moose;
use Moose::Util::TypeConstraints;

has 'Package' =>
  (is => 'rw', => isa => 'Str', default =>
   '/var/lib/myfrdcsa/codebases/minor/normal-form/inform7/Normal-Form/Normal Form.inform');

enum 'MachineType', [qw(glulx z8)];

has 'Machine' =>
  (is => 'ro', => isa => 'MachineType', default => 'glulx');

sub CompileToI6 {
  my ($self, $args) = @_;
  my %args = %{$args || {}};
  my $machinetype;
  if ($self->Machine eq 'glulx') {
    $machinetype = 'ulx';
  } elsif ($self->Machine eq 'z8') {
    $machinetype = 'z8';
  }
  my $command =
    join(' ',
	 (
	  '/usr/lib/x86_64-linux-gnu/gnome-inform7/ni',
	  '-rules',
	  '/usr/share/gnome-inform7/Extensions',
	  '-package',
	  shell_quote($self->Package),
	  '-extension='.$machinetype,
	  '2>&1'
	 ));
  print 'Compile to I6 command: '.$command."\n";
  my $res = `$command`;
  if ($res =~ />\-\-> (.+?)\n\+\+ Ended: Translation Failed:/si) {
    my $errormsg = $1;
    return
      {
       Success => 0,
       Error => $errormsg,
      };
  } else {
    return
      {
       Success => 1,
      };
  }
}

sub Compile {
  my ($self, $args) = @_;
  my %args = %{$args || {}};

  # add a feature to make sure it has been compiled first, for now,
  # just run compile again anyway
  my $res1 = $self->CompileToI6;
  if (! $res1->{Success}) {
    return $res1;
  } elsif ($res1->{Success}) {
    my ($flags,$machinetype);
    if ($self->Machine eq 'glulx') {
      $flags = '-wxE2kSDG';
      $machinetype = 'ulx';
    } elsif ($self->Machine eq 'z8') {
      $flags = '-wxE2kSDv8';
      $machinetype = 'z8';
    }
    my $command =
      join(' ',
	   (
	    '/usr/lib/x86_64-linux-gnu/gnome-inform7/inform6',
	    $flags,
	    '$huge',
	    shell_quote(ConcatDir($self->Package,'Build/auto.inf')),
	    shell_quote(ConcatDir($self->Package,'Build/output.'.$machinetype)),
	   ));
    print 'Compile command: '.$command."\n";
    my $res2 = `$command`;

    return
      {
       Success => 1,
       Result => $res2,
      };
  }
}

__PACKAGE__->meta()->make_immutable();
1;
