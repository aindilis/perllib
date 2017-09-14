package Lingua::EN::Extract::Dates;

use Data::Dumper;
use File::Temp;
use Lingua::EN::Tagger;
use Lingua::EN::Sentence qw(get_sentences);
use XML::LibXML;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyTagger MyParser /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyTagger
    (Lingua::EN::Tagger->new);
}

sub AlembicTagText {
  my ($self,%args) = @_;
  # in order to get Alembic like tags, just use the Perl
  # Lingua::EN::Tagger, and rewrite it to look like Alembic output,
  # this should be sufficient to feed to the MITRE date extraction
  # system
  my $sentences=get_sentences($args{Text});
  my $res;
  $res = "<doc>\n";
  foreach my $Sent (@$sentences) {
    my $tagged_text = $self->MyTagger->add_tags( $Sent );
    $tagged_text =~ s/<([a-zA-Z].*?)>/<lex pos=$1>/g;
    $tagged_text =~ s/<\/.*?>/<\/lex>/g;
    $res .= "<s>$tagged_text</s>\n\n";
  }
  $res .= "</doc>\n";
  return $res;
}

sub TimeRecognizeText {
  my ($self,%args) = @_;
  # send it to the MITRE date extraction system
  my $tmpf1 = File::Temp->new;
  my $tmpfile = $tmpf1->filename;
  print $tmpf1 $self->AlembicTagText(Text => $args{Text});
  my $res;
  my $tmpf2 = File::Temp->new;
  my $tmpfile2 = $tmpf2->filename;
  undef $tmpf2;
  my $date = $args{Date} || `date`;
  chomp $date;
  if (!$args{Type} or $args{Type} eq "TIMEX3") {
    system "cd /var/lib/myfrdcsa/codebases/internal/perllib/scripts/t/gutime && ./gutime.pl -t doc -dct \"$date\" $tmpfile $tmpfile2";
    $res = `cat "$tmpfile2"`;
  } elsif ($args{Type} eq "TIMEX2") {
    $res = `/var/lib/myfrdcsa/codebases/internal/perllib/Lingua/EN/Extract/Dates/TimeTag.pl -FDNW $tmpfile`;
  }
  return $res;
}

sub GetDates {
  my ($self,%args) = @_;
  my $timex = $args{TIMEX} || $self->TimeRecognizeText(Text => $args{Text});
  my @res = $timex =~ /(.*?)<TIMEX2 ?(.*?)>(.*?)<\/TIMEX2>(.*?)/smg;
  my $dates = {};
  my $i = 0;
  my @taggedtext;
  while (@res) {
    my $x = shift @res;
    my $a = shift @res;
    my $b = shift @res;
    my $y = shift @res;
    if ($a =~ /TYPE=\"(.*?)\" VAL=\"(.*?)\"/) {
      my $messageevent = "MESSAGE".$args{Message}."-EVENT".$i;
      $dates->{$2}->{$messageevent} =
	{
	 Message => $args{Message},
	 Event => $i,
	 DateText => $self->CleanText(Text => $b),
	};
    }
    push @taggedtext,
      $self->CleanText(Text => $x),
	"<a name=\"EVENT$i\"><font size=\"+2\">",
	  $self->CleanText(Text => $b),
	    "</font><sub>EVENT$i</sub></a>",
	      $self->CleanText(Text => $y);
    ++$i;
  }
  my $taggedtext = join("", @taggedtext);
  return {
	  Dates => $dates,
	  CleanedText => $taggedtext,
	 };
}

sub HTMLify {
  my ($self,%args) = @_;
  my $t = $args{Text};
  if ($t) {
    $t =~ s/&/&AMP;/g;
    $t =~ s/</&LT;/g;
  }
  return $t;
}


sub CleanText {
  my ($self,%args) = @_;
  my $t = $args{Text};
  if ($t) {
    $t =~ s/<\/?s>//g;
    $t =~ s/<\/?doc>//g;
    $t =~ s/<lex .*?>//g;
    $t =~ s/<TIMEX\d+ .*?>//g;
    $t =~ s/<\/TIMEX\d+>//g;
    $t =~ s/<\/lex>//g;
  }
  return $self->HTMLify(Text => $t);
}

sub GetDatesTime3XML {
  my ($self,%args) = @_;
  my $dates = {};
  $self->LoadParser;
  $args{Text} =~ s/&/|AMPERSAND|;/sg;
  my $timex = $self->TimeRecognizeText(Text => $args{Text});
  $args{Text} =~ s/|AMPERSAND|/&amp;/sg;
  $timex =~ s/<lex pos=(\w+)/<lex pos="$1"/g;
  my $doc = $self->MyParser->parse_string($timex);
  my $root = $doc->documentElement();
  my @sentences;
  foreach my $s ($root->getChildrenByTagName("s")) {
    foreach my $timex ($s->getChildrenByTagName("TIMEX3")) {
      $date = $timex->getAttribute("VAL");
      if (defined $date) {
	$dates->{$date} = 1;
      }
    }
    my @words;
    foreach my $word ($s->getChildrenByTagName("lex")) {
      push @words, [$word->childNodes()]->[0]->toString;
    }
    push @sentences, \@words;
  }
  return {
	  Dates => $dates,
	  Sentences => \@sentences,
	 };
}

sub GetDatesTIMEX3 {
  my ($self,%args) = @_;
  my $dates = {};
  my $i = 0;

  $self->LoadParser;
  $args{Text} =~ s/&/|AMPERSAND|;/sg;
  $args{Text} =~ s/</|LESSTHAN|;/sg;
  $args{Text} =~ s/>/|GREATERTHAN|;/sg;
  my $timex = $args{TIMEX} || $self->TimeRecognizeText
    (
     Text => $args{Text},
     Date => $args{Date},
    );
  $args{Text} =~ s/|LESSTHAN|;/&lt;/sg;
  $args{Text} =~ s/|GREATERTHAN|;/&gt;/sg;
  $args{Text} =~ s/|AMPERSAND|;/&amp;/sg;
  $timex =~ s/<lex pos=(\w+)/<lex pos="$1"/g;
  $timex =~ s/ERROR="[^"]+"/ /sg;
  my $doc = $self->MyParser->parse_string($timex);
  my $root = $doc->documentElement();
  my @sentences;
  my @taggedtext;
  foreach my $s ($root->getChildrenByTagName("s")) {
    foreach my $child ($s->nonBlankChildNodes()) {
      if ($child->nodeName eq "TIMEX3") {
	$x = join(" ",@text);
	@text = ();
	foreach my $child ($child->getChildrenByTagName("lex")) {
	  push @text, $child->textContent;
	}
	$b = join(" ",@text);

	$date = $child->getAttribute("VAL");
	if (defined $date) {
	  my $messageevent = "MESSAGE".$args{Message}."-EVENT".$i;
	  $dates->{$date}->{$messageevent} =
	    {
	     Message => $args{Message},
	     Event => $i,
	     DateText => $self->CleanText(Text => $b),
	    };
	}
	push @taggedtext,
	  $self->CleanText(Text => $x),
	    "<a name=\"EVENT$i\"><font size=\"+2\">",
	      $self->CleanText(Text => $b),
		"</font><sub>EVENT$i</sub></a>";
	++$i;

      } elsif ($child->nodeName eq "lex") {
	push @text, $child->toString;
      }
    }
  }
  if (@text) {
    $y = join(" ",@text);
    push @taggedtext, $self->CleanText(Text => $y);
  }
  my $taggedtext = join("", @taggedtext);
  return {
	  Dates => $dates,
	  CleanedText => $taggedtext,
	  TIMEX3 => $timex,
	 };
}

sub GetDatesTIMEX3Old {
  my ($self,%args) = @_;
  my $dates = {};
  my $i = 0;

  $self->LoadParser;
  $args{Text} =~ s/&/|AMPERSAND|;/sg;
  $args{Text} =~ s/</|LESSTHAN|;/sg;
  $args{Text} =~ s/>/|GREATERTHAN|;/sg;
  my $timex = $args{TIMEX} || $self->TimeRecognizeText
    (
     Text => $args{Text},
     Date => $args{Date},
    );
  $args{Text} =~ s/|LESSTHAN|;/&lt;/sg;
  $args{Text} =~ s/|GREATERTHAN|;/&gt;/sg;
  $args{Text} =~ s/|AMPERSAND|;/&amp;/sg;
  $timex =~ s/<lex pos=(\w+)/<lex pos="$1"/g;
  my $doc = $self->MyParser->parse_string($timex);
  my $root = $doc->documentElement();
  my @sentences;
  my @taggedtext;
  foreach my $s ($root->getChildrenByTagName("s")) {
    foreach my $timex ($s->getChildrenByTagName("TIMEX3")) {
      print Dumper({THISisIT => $timex});
      # my @res = $timex =~ /(.*?)<TIMEX2 ?(.*?)>(.*?)<\/TIMEX2>(.*?)/smg;
      # my $x = shift @res;
      # my $a = shift @res;
      # my $b = shift @res;
      # my $y = shift @res;

      $date = $timex->getAttribute("VAL");
      if (defined $date) {
	my $messageevent = "MESSAGE".$args{Message}."-EVENT".$i;
	$dates->{$date}->{$messageevent} =
	  {
	   Message => $args{Message},
	   Event => $i,
	   DateText => $self->CleanText(Text => $b),
	  };
      }
      push @taggedtext,
	$self->CleanText(Text => $x),
	  "<a name=\"EVENT$i\"><font size=\"+2\">",
	    $self->CleanText(Text => $b),
	      "</font><sub>EVENT$i</sub></a>",
		$self->CleanText(Text => $y);
      ++$i;
    }
    if (0) {
      my @words;
      foreach my $word ($s->getChildrenByTagName("lex")) {
	push @words, [$word->childNodes()]->[0]->toString;
      }
      push @sentences, \@words;
    }
  }
  my $taggedtext = join("", @taggedtext);
  return {
	  Dates => $dates,
	  CleanedText => "",	# $taggedtext,
	  TIMEX3 => $timex,
	 };
}

sub LoadParser {
  my ($self,%args) = @_;
  if (! defined $self->MyParser) {
    $self->MyParser(XML::LibXML->new);
  }
}

1;
