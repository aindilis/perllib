#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

my @files;
while (<STDIN>) {
  chomp;
  push @files, $_;
}
print Dumper(\@files);

my @stats;
foreach my $file (@files) {
  push @stats, {
		stat => File::Stat ->new($file),
		file => $file,
	       };
}

foreach my $ref (sort {$b->{stat}->ctime <=> $a->{stat}->ctime} @stats) {
  print $ref->{file}."\n";
}
