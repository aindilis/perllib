#!/usr/bin/perl -w

use Test::More no_plan;

use Data::Dumper;
use Error qw(:try);

use_ok('TestError');

my $testerror = TestError->new();

isa_ok($testerror, 'TestError');

try {
  $testerror->Test1();
# test catch with "general" class spec
} catch Error::Simple with {
  my $E = shift;
  diag(Dumper($E));
};

try {
  $testerror->Test1();
# test catch with "specific" class spec
} catch TestError with {
  my $E = shift;
  diag(Dumper($E));
};

$testerror->Test3();

try {
  $testerror->Test2();
} finally {
  diag("hello");
};


