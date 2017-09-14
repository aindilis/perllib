package Capability::TextCleaning;

use Capability::Tokenize;
use System::LinkParser;

use Data::Dumper;
use IO::File;
use Lingua::EN::Sentence qw(get_sentences);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Freq FreqNorm Sentences MyParser MyLinkParser /

  ];

sub init {
  my ($self,%args) = @_;
  $Data::Dumper::Indent = 1;
  $self->Sentences({});
  $self->LoadFrequencyData();
  $self->MyParser
    (System::LinkParser->new);
}

sub CleanText {
  my ($self,%args) = @_;
  my $freq = $self->FreqNorm;
  my $unknowns = {};
  my $unaccepted = {};
  my $j = 0;
  my $c = $args{Text};

  my @results;
  my $sentences = get_sentences($args{Text});
  foreach my $sentence (@$sentences) {
    # now check if it has above a certain percentage of dictionary
    # words
    $sentence =~ s/[\n\r]/ /sg;
    $sentence =~ s/\s+/ /g;
    my $tokenized = tokenize_treebank($sentence);
    if ($tokenized !~ /^</) {
      # Hopefully not markup

      # tokenize and iterate over each word, determining frequency
      # (if appropriate, i.e. not for numbers), and determine
      # several norms for sentence "difficulty" based on frequency
      my @freqs;
      chomp $tokenized;
      my @myunknowns = ();
      my @myunaccepted = ();
      foreach my $token (split /\s+/, $tokenized) {
	if ($token =~ /^[a-zA-Zäöüß]+$/) {
	  # check whether it is in dictionary
	  if (exists $freq->{lc($token)}) {
	    push @freqs, $freq->{lc($token)};
	  } else {
	    # this is a valid word without a frequency
	    $unknowns->{$token}++;
	    push @myunknowns, $token;
	    push @freqs, 0;
	  }
	} else {
	  if ($token =~ /^[0-9]+$/) {

	  } else {
	    $unaccepted->{$token}++;
	    push @myunaccepted, $token;
	  }
	}
      }

      # compute overall sentence scores
      my $min = 1000;
      my $l1c = 0;
      my $l2c = 0;
      if (scalar @freqs) {
	foreach my $freq (@freqs) {
	  if ($freq < $min) {
	    $min = $freq;
	  }
	  $l1c += $freq;
	  $l2c += $freq * $freq;
	}
	my $l1 = $l2c / (scalar @freqs);
	my $l2 = sqrt($l2c);
	my $item =
	  {
	   Min => $min,
	   L1 => $l1,
	   L2 => $l2,
	   Unknowns => \@myunknowns,
	   Unaccepted => \@myunaccepted,
	   Tokenized => $tokenized,
	  };
	$self->Sentences->{$tokenized} = $item;
	if (! scalar @{$item->{Unknowns}}) {
	  my $reject = 0;
	  foreach my $token (@{$item->{Unaccepted}}) {
	    if ($token !~ /^[[:punct:]\,\.\!\?]+$/) {
	      $reject = 1;
	      last;
	    }
	  }
	  if (! $reject) {
	    # okay we can go ahead and print this sentence
	    # now check it for link parser
	    if (0) {
	      my $res = $self->MyParser->CheckSentence
		(Sentence => $sentence);
	      if ($res) {
		push @results,
		  {
		   Success => 1,
		   Result => $sentence,
		  };
	      }
	    } else {
	      push @results,
		{
		 Success => 1,
		 Result => $sentence,
		};
	    }
	  }
	}
      }
    }
  }
  return {
	  Success => 1,
	  Results => \@results,
	 };
}

sub LoadFrequencyData {
  my ($self,%args) = @_;
  my $total = 0;
  my $freq = {};
  my $freqnorm = {};
  my $file = "/var/lib/myfrdcsa/codebases/minor/language-learning/reading-difficulty-measure/anc-lexicon.tgz";
  my $c = `zcat $file`;
  foreach my $line (split /[\r\n]+/, $c) {
    if ($line =~ /^(.+) (\d+)$/) {
      $freq->{lc($1)} = $2;
      $total += $2;
    } else {
      print ".";
    }
  }
  die "Total is 0" unless $total > 0;
  print "\n";
  foreach my $key (keys %$freq) {
    $freqnorm->{$key} = $freq->{$key} / $total;
  }
  $self->Freq($freq);
  $self->FreqNorm($freqnorm);
}

sub WriteResults {
  my ($self,%args) = @_;
  my $fh = IO::File->new;
  $fh->open(">sentence-info.dat");

  # foreach my $key (sort {$self->Sentences->{$b}->{Min} <=> $self->Sentences->{$a}->{Min}} keys %{$self->Sentences}) {
  foreach my $key (sort {$self->Sentences->{$b}->{L1} <=> $self->Sentences->{$a}->{L1}} keys %{$self->Sentences}) {
    print $fh Dumper({$key => $self->Sentences->{$key}});
  }
  $fh->close();

}

1;

# ### From: /var/lib/myfrdcsa/codebases/internal/digilib/scripts/clean-out-junk-ocr.pl

# #!/usr/bin/perl -w

# use Capability::Tokenize;
# use Lingua::EN::Sentence qw(get_sentences);
# use PerlLib::Dictionary;

# use Data::Dumper;

# my $dict = PerlLib::Dictionary->new;
# my $text = shift;

# my $c = `cat "$text"`;
# my $sentences = get_sentences($c);
# foreach my $sentence (@$sentences) {
#   # tokenize it now
#   my $total = 0;
#   my $contained = 0;
#   my @tokens;
#   foreach my $token (split /\s+/, $sentence) {
#     # tokenize_treebank($sentence)) {
#     if (length($token) > 3) {
#       $contained += $dict->Lookup(Word => $token);
#       ++$total;
#     }
#     push @tokens, $token;
#   }
#   if ($total and (($contained / $total) > 0.3)) {
#     push @sentences, join(" ", @tokens);
#   }
# }

# print join("\n", @sentences);
