#!/usr/bin/perl -w

use Capability::Tokenize;

use Data::Dumper;

my $text = `head -n 100 /home/andrewdo/to.do`;
my $items = Tokenize(Text => $text);
# my $items = [1..5];
my $min = 3;
my $max = 6;

print Dumper
  (ExtractSlidingWindow
   (
    Min => 3,
    Max => 6,
    Items => $items,
   ));

sub ExtractSlidingWindow {
  my %args = @_;
  my $items = $args{Items};
  my $min = $args{Min};
  my $max = $args{Max};
  my @windows;
  my $start = 0;
  my @window;
  while (@$items or scalar @window >= $min) {
    if (scalar @$items) {
      push @window, shift @$items;
    }
    my $size = scalar @window;
    if ($size < $min) {
      if (scalar @$items) {
	next;
      } else {
	exit(0);
      }
    }

    if (! $start) {
      if (($size == $max) or ! @$items) {
	$start = 1;
      }
    }
    if ($start) {
      # print join(" ",map {"<$_>"} @window)."\n";
      my $size2 = scalar @window;
      foreach my $i ($min .. $max) {
	if ($i <= $size2) {
	  my @copy = @window;
	  my @subwindow = splice @copy, 0, $i;
	  # print join(" ",map {"<$_>"} @subwindow)."\n";
	  push @windows, \@subwindow;
	}
      }
    }

    if ($size >= $max or ! @$items) {
      shift @window;
    }
  }
  return \@windows;
}
