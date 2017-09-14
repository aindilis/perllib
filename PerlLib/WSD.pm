package PerlLib::WSD;

use Data::Dumper;
use Lingua::EN::Sentence qw(get_sentences);
use Text::Wrap qw(wrap $columns $huge);
use WordNet::QueryData;
use WordNet::SenseRelate::AllWords;
use WordNet::Tools;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / MyQueryData MyTools MySenseRelate Debug / ];

sub init {
  my ($self,%args) = @_;
  $self->Debug($args{Debug});
  $columns = 100;
  print "Creating QueryData object\n";
  $self->MyQueryData
    (WordNet::QueryData->new("/usr/local/WordNet-3.0/dict/"));
  $self->MyTools(WordNet::Tools->new($self->MyQueryData));
  defined $self->MyTools or die "\nCouldn't construct WordNet::Tools object";
  my %options = (
		 wordnet => $self->MyQueryData,
		 wntools => $self->MyTools,
		 measure => 'WordNet::Similarity::lesk',
		);
  print "Creating SenseRelate object\n";
  $self->MySenseRelate
    (WordNet::SenseRelate::AllWords->new
     (%options));
  print "Finished loading...\n";
}

sub WQD {
  my ($self,%args) = @_;
  my $wqd = $args{WQD};
  if ($wqd !~ /^(.+)#(.+)#(\d+)$/) {
    return {
	    Success => 0,
	   };
  } else {
    my @text = $self->MyQueryData->querySense("$wqd", "glos");
    return {
	    Success => 1,
	    Glos => \@text,
	   };
  }
}

sub ProcessText {
  my ($self,%args) = @_;
  # break a text down and wsd it, formalize it
  # do we pre-process it to avoid embarrassing terminological mistakes

  # FIX ME

  my $sentences = get_sentences($args{Text});
  my @res;
  foreach my $sentence (@$sentences) {
    push @res, $self->ProcessSentence
      (
       Sentence => $sentence,
       Hypen => $args{Hypen},
      );
  }
  return \@res;
}

sub ProcessSentence {
  my ($self,%args) = @_;
  my $sentence = $args{Sentence};
  my @words;
  my @lint;
  my @results;
  # load a dictionary
  $sentence =~ s/\n/ /g;
  $sentence =~ s/\s+/ /g;
  $sentence =~ s/^\W*//;
  $sentence .= " ";
  my @i1 = $sentence =~ /(\w+)(\W+)/g;
  foreach my $s (@i1) {
    if ($s =~ /^\w+$/) {
      push @words, $s;
    } else {
      push @lint, $s;
    }
  }
  # now take words and wsd them
  if (@words and @words < 20) {
    my @res = $self->MySenseRelate->disambiguate
      (
       window => 2,
       tagged => 0,
       scheme => 'normal',
       context => [@words],
      );
    my $i = 0;
    foreach my $wqd (@res) {
      my $results = {};
      my $notcertain = 0;
      $results->{WQD} = $wqd;
      $results->{Word} = $words[$i];
      $results->{Lin} = $lint[$i];
      my $res = $self->WQD
	(WQD => $wqd);
      my $glos;
      if ($res->{Success}) {
	$glos = $res->{Glos}->[0];
      }
      if ($glos) {
	$results->{Glos} = $glos;
      } else {
	$results->{NotCertain} = 1;
      }
      if ($wqd =~ /^(.+)#(.+)#(\d+)$/) {
	$results->{POS} = $2;
	$results->{Sense} = $3;
      } elsif ($wqd =~ /^(.+)#(.+)$/) {
	$results->{POS} = $2;
      }
      print Dumper({
		    Args => \%args,
		    Results => $results,
		   });
      if (exists $args{Hypen} and ((! exists $results->{POS}) or (exists $results->{POS} and $results->{POS} =~ /^[nva]$/))) {
	$results->{Hypen} = $self->Hypen
	  (WQD => $results->{WQD});
      }
      push @results, $results;
      ++$i;
    }
    return \@results;
  }
}

sub Hypen {
  my ($self,%args) = @_;
  my $wqd = $args{WQD};
  # same thing as wn $wqd -hypen
  print "Synonyms/Hypernyms (Ordered by Estimated Frequency) of noun $wqd\n\n" if $self->Debug;
  my @senses;
  if ($wqd =~ /^(.+)#(.+)#(\d+)$/) {
    @senses = ($wqd);
  } elsif ($wqd =~ /^(.+)#(.+)$/) {
    @senses = $self->MyQueryData->querySense($wqd);
  } else {
    @senses = $self->MyQueryData->querySense($wqd);
  }

  my $num = scalar @senses;
  print "$num senses of $wqd\n\n" if $self->Debug;
  my @res;
  my $i = 1;
  foreach my $sense (@senses) {
    push @res, $self->HypenRec
      (
       Sense => $sense,
       Depth => 0,
      );
    ++$i;
  }
  return {
	  Result => \@res,
	 };
}

sub HypenRec {
  my ($self,%args) = @_;
  my $sense = $args{Sense};
  my @res;
  if ($args{Depth} > 0) {
    # push @res, "   ".("    "x$args{Depth})."=> ";
  }
  # push @res, [map {$self->Clean(Item => $_)} $self->MyQueryData->querySense($sense, "syns")];
  push @res, [$self->MyQueryData->querySense($sense, "syns")];

  # now call hypenrec on each of the hypes of this word
  foreach my $hype ($self->MyQueryData->querySense($sense,"hypes")) {
    push @res, $self->HypenRec(
	     Sense => $hype,
	     Depth => $args{Depth}+1,
	    );
  }
  return \@res;
}

sub Clean {
  my ($self,%args) = @_;
  my $item = $args{Item};
  $item =~ s/#.*//;
  $item =~ s/_/ /g;
  return $item;
}

1;
