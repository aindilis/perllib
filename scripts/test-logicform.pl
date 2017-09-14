#!/usr/bin/perl -w

use Capability::LogicForm;
use KBS2::ImportExport;

use Data::Dumper;

$UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/internal/freekbs2";
my $logicform = Capability::LogicForm->new();
$logicform->StartServer;
my $importexport = KBS2::ImportExport->new
  ();

my $result = $logicform->LogicForm
  (Text => 'The sale was made to pay Yukos\' US$ 27.5 billion tax bill, Yuganskneftegaz was originally sold for US$ 9.4 billion to a little known company Baikalfinansgroup which was later bought by the Russian state-owned oil company Rosneft .This is the first sentence that has the word first twice.');
print Dumper($result);

if ($result->{Success}) {
  my @lfs;
  foreach my $thing (@{$result->{Result}}) {
    push @lfs, $thing->{LogicForms}
  }
  my $res = $importexport->Convert
    (
     Input => \@lfs,
     InputType => "Logic Forms",
     OutputType => "KIF String",
    );
  print Dumper($res);
}
