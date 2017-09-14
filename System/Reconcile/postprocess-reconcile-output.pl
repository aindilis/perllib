#!/usr/bin/perl -w

use Data::Dumper;
use File::Slurp;

ProcessCoreferenceResolution();

sub ProcessCoreferenceResolution {
  my %args = @_;
  my $dir1 = "/var/lib/myfrdcsa/sandbox/reconcile-20100208/reconcile-20100208/mitkov_corpus";
  foreach my $dir2 (split /\n/, `ls -1 $dir1`) {
    next unless $dir2 =~ /^\d+$/;
    my $raw = read_file("$dir1/$dir2/raw.txt");
    my $gsfile = "$dir1/$dir2/annotations/gs_nps";
    if (-f $gsfile) {
      my $gs = read_file($gsfile);
      print Dumper
	(ReplaceCoreferences
	 (
	  Text => $raw,
	  Annotations => $gs,
	 ));
    } else {
      print "FILE: ERROR $gsfile\n";
    }
    my $it = <STDIN>;
  }
}


sub ReplaceCoreferences {
  my %args = @_;
  # my @tokens;
  my @items;
  my $sets = {};
  my $ids = {};
  my $newset = 0;
  foreach my $line (split /\n/, $args{Annotations}) {
    # 172	3593,3612	string	np	matched_ce="211" ID="169" NO="169" 
    if ($line =~ /^(\d+)\t(\d+),(\d+)\t(.+?)\t(.+?)\t(.+)$/) {
      my $item = {
		  ID => $1,
		  Start => $2,
		  End => $3,
		  Tmp1 => $4,
		  POS => $5,
		 };
      my $phrase = $6;
      my $item2 = {};
      foreach my $segment (split /\s+/, $phrase) {
	if ($segment =~ /^(.+)="(.+)"$/) {
	  $item2->{$1}->{$2}++;
	} else {
	  print "ERROR: <$segment>\n";
	}
      }
      $item->{Phrase} = $item2;
      # print Dumper($item);
      # now go ahead and retrieve it
      my $token = substr $args{Text},$item->{Start},($item->{End} - $item->{Start});
      my $temp = {};
      next unless defined $item2->{CorefID};
      foreach my $key (keys %{$item2->{CorefID}}) {
	$temp->{$key} = 1;
      }
      foreach my $key (keys %{$item2->{ID}}) {
	$temp->{$key} = 1;
      }
      # print Dumper([keys %$temp]);
      my $max = 10000000000;
      my $lowestsetid = $max;
      foreach my $key (keys %$temp) {
	if (defined $sets->{$key}) {
	  if ($sets->{$key} < $lowestsetid) {
	    $lowestsetid = $sets->{$key};
	  }
	} else {
	  $sets->{$key} = $newset;
	}
      }
      ++$newset;
      foreach my $key (keys %$temp) {
	if ($lowestsetid < $max) {
	  $sets->{$key} = $lowestsetid;
	}
      }
      $ids->{$item->{ID}} = $token;
    } else {
      print "ERROR: $line\n";
    }
  }
  my $isets = {};
  foreach my $key (keys %$sets) {
    $isets->{$sets->{$key}}->{$key}++;
  }
  foreach my $setid (keys %$isets) {
    my $nps = {};
    foreach my $key (keys %{$isets->{$setid}}) {
      if (exists $ids->{$key}) {
	$nps->{$ids->{$key}}++;
      }
    }
    my @items = keys %$nps;
    next unless scalar @items;
    print "<<<".join("|", sort @items).">>>\n";
  }
}
