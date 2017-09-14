#!/usr/bin/perl -w

use Data::Dumper;

foreach my $line (split /\n/, `cat output.parses`) {
  # 0: [ARG1 I] am [TARGET tired ] [ARG0 of those who claim that good is subjective]
  my $res = {};
  foreach my $item ($line =~ /\[([^\]]+)\]/g) {
    if ($item =~ /^(\w+)\s+(.+?)\s*$/) {
      $res->{$1} = $2;
    }
  }
  print Dumper($res);
  PrintStruct($res);
}

sub PrintStruct {
  my $res = shift;
  my @list;
  if (exists $res->{TARGET}) {
    push @list, $res->{TARGET};
  }
  if (exists $res->{"ARG0"}) {
    my $i = 0;
    while (exists $res->{"ARG$i"}) {
      push @list, $res->{"ARG$i"};
      ++$i;
    }
  } elsif (exists $res->{"ARG1"}) {
    my $i = 1;
    while (exists $res->{"ARG$i"}) {
      push @list, $res->{"ARG$i"};
      ++$i;
    }
  }
  print join(" ",map {"'$_'"} @list)."\n";
}
