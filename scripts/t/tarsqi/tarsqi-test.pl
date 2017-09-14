#!/usr/bin/perl -w

use System::TARSQI;

use Data::Dumper;

my $t = System::TARSQI->new;

if (@ARGV) {
  while (@ARGV) {
    my $file = shift @ARGV;
    ProcessFile($file);
  }
} else {
  ProcessFile("test.txt");
}

sub ProcessFile {
  my $file = shift;
  my $string = `cat "$file"`;
  print Dumper($t->ProcessString(String => $string));
}
