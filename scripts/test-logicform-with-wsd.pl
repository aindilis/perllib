#!/usr/bin/perl -w

use Capability::LogicForm;

use Data::Dumper;

my $lf = Capability::LogicForm->new;

print Dumper
  ($lf->LogicForm
   (
    Text => "This is the first time I have tried this.  I wonder how well it will work.  Hopefully, well.",
    WSD => 1,
   ));
