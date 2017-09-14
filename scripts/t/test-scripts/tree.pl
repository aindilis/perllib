#!/usr/bin/perl -w

use AI::DecisionTree;
use GraphViz;
my $dtree = new AI::DecisionTree;

# A set of training data for deciding whether to play tennis
$dtree->add_instance
  (attributes => {outlook     => 'sunny',
		  temperature => 'hot',
		  humidity    => 'high'},
   result => 'no');

$dtree->add_instance
  (attributes => {outlook     => 'overcast',
		  temperature => 'hot',
		  humidity    => 'normal'},
   result => 'yes');

PrintTree();

# Find results for unseen instances
my $result = $dtree->get_result
  (attributes => {outlook     => 'sunny',
		  temperature => 'hot',
		  humidity    => 'normal'});

print "$result\n";

sub PrintTree {
  my $OUT = 1;
  open(OUT,">/tmp/temp.ps") or
    die "Cannot open /tmp/temp.ps\n";
  print OUT $dtree->as_graphviz->as_ps;
  close OUT;
  system "gv /tmp/temp.ps";
}
