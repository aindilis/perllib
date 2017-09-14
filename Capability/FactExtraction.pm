package Capability::FactExtraction;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw (FactExtraction);

use Capability::Tokenize;
use System::Assert;
use System::JavaRAP;
use System::LinkParser;

use Data::Dumper;
use Lingua::EN::Sentence qw(get_sentences);

my $sayer;
my $assert = System::Assert->new;
my $linkparser = System::LinkParser->new();

sub FactExtraction {
  my %args = @_;

  my $text;
  my $anaphora_processed_text;
  if ($args{Text}) {
    $text = $args{Text};
    $anaphora_processed_text = $text;
    if (0) {
      # resolve anaphoras
      $anaphora_processed_text = ResolveAnaphoras
	(Text => $args{Text});
      print Dumper($anaphora_processed_text);
      exit(0);
    }
  }

  my @all;
  my $sentences;
  if (exists $args{Sentences}) {
    $sentences = $args{Sentences};
  } else {
    $sentences = get_sentences($anaphora_processed_text);
  }
  foreach my $sentence (@$sentences) {
    #my $res = $linkparser->CheckSentence
    # (Sentence => $sentence);
    my $res = 1;
    if ($res) {
      # print $sentence."\n";
      $sentence =~ s/\n/ /g;
      $sentence =~ s/\s+/ /g;
      push @all, $sentence;
    }
  }

  # print Dumper({ALL => \@all});

  # tokenize
  # my $tokenized_text = tokenize_treebank($text);
  # print Dumper($tokenized_text);

  # parse with assert or some other shallow parser

  my $results;
  if ($args{Sayer}) {
    if (ref $args{Sayer} eq "Sayer") {
      $sayer = $args{Sayer};
    }
    if (! defined $sayer) {
      require Sayer;
      $sayer = Sayer->new;
    }
    $results = $sayer->ExecuteCodeOnData
      (
       Data => [\@all],
       CodeRef => sub {
	 return $assert->Parse
	   (
	    Text => join("\n",@{$_[0]}),
	    Results => "full",
	   );
       }
      );
  } else {
    $results = $assert->Parse
      (
       Text => join("\n",@all),
       Results => "full",
      );
  }

  if (exists $args{Topic}) {
    return {
	    Target => Process
	    (
	     Topic => $args{Topic},
	     Results => $results,
	    ),
	   };
  } else {
    return $results;
  }
}

sub Process {
  my %args = @_;
  my $topic = $args{Topic};
  my $targets = {};
  my @partial = split /\s+/, $topic;
  foreach my $entry (@{$args{Results}->{Processed}}) {
    my $match = 0;
    if (exists $entry->{ARG1}) {
      if (exists $conf->{'-p'}) {
	foreach my $item (@partial) {
	  if ($entry->{ARG1} =~ /$item/i) {
	    $match = 1;
	    last;
	  }
	}
      } elsif (exists $conf->{'-a'}) {
	$match = $entry->{ARG1} =~ /$topic/i;
      } else {
	$match = $entry->{ARG1} =~ /^$topic$/i;
      }
    }
    if (exists $entry->{ARG1} and $match) {
      my @list;
      foreach my $item (sort keys %$entry) {
	if ($item ne "ARG1" and $item ne "TARGET") {
	  push @list, "[".$item." ".$entry->{$item}."]";
	}
      }
      $targets->{$entry->{TARGET}}->{join(" ",@list)}++;
    }
  }
  my @keys = keys %$targets;
  if (scalar @keys) {
    print "$topic\n";
    foreach my $key (@keys) {
      print "\t$key\n";
      foreach my $key2 (keys %{$targets->{$key}}) {
	print "\t\t$key2\n";
      }
    }
  } else {
    print "No results found for search <$topic>!\n"
  }
  return $targets;
}

1;
