package PerlLib::UI::AutoGenerate;

# Looking  at the  source code  for  objects, we  can determine  which
# functions that object  can call, and therefore, when  the UI selects
# and  object, we  can display  those  functions that  the user  could
# conceivably  call by  themselves,  therefore, avoiding  the need  to
# manually write that.

use Data::Dumper;

use BOSS::ICodebase qw(GetSystems GetPerlModuleLinks);
use Manager::Dialog qw(Choose);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw /  /

  ];

sub init {
  my ($self, %args) = @_;
}

sub GenerateUIForCodebase {
  my ($self,%args) = @_;
  my $systems = GetSystems;
  my $codebase = $args{Codebase} ||
    Choose(sort keys %$systems);
  my $ret = GetPerlModuleLinks($codebase);
  my @files = ($ret->{LinkModule});
  my $linkdir = $ret->{LinkDirectory};
  push @files, grep(!/~$/, split /\n/,`find "$linkdir" -follow`);
  $self->GenerateUIForObjects(Files => \@files);
}

sub GenerateUIForObjects {
  my ($self,%args) = @_;
  foreach my $f (@{$args{Files}}) {
    if (-f $f) {
      my $c = `cat "$f"`;
      my $objectdata = {};
      if ($c =~ /^package (.*);$/m) {
	$objectdata->{PackageName} = $1;
      }
      # extract function names and parameters

      # this work should really use a perl parser, so don't work on it
      # till CPAN gets done.
    }
  }
}

1;
