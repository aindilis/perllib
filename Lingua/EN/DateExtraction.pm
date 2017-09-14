package Lingua::EN::DateExtraction;

use Data::Dumper;
use Lingua::EN::Tagger;
use Lingua::EN::Sentence qw(get_sentences);

my $p = new Lingua::EN::Tagger;

sub AlembicTagText {
  my (%args) = @_;
  # in order to get Alembic like tags, just use the Perl
  # Lingua::EN::Tagger, and rewrite it to look like Alembic output,
  # this should be sufficient to feed to the MITRE date extraction
  # system
  my $sentences=get_sentences($args{Text});
  my $res;
  $res = "<doc>\n";
  foreach my $Sent (@$sentences) {
    my $tagged_text = $p->add_tags( $Sent );
    $tagged_text =~ s/<([a-zA-Z].*?)>/<lex pos=$1>/g;
    $tagged_text =~ s/<\/.*?>/<\/lex>/g;
    $res .= "<s>$tagged_text</s>\n\n";
  }
  $res .= "</doc>\n";
  return $res;
}

sub TimeRecognizeText {
  my (%args) = @_;
  # send it to the MITRE date extraction system
  my $tmpfile = "/tmp/alembictext";
  system "rm \"$tmpfile\"";
  my $OUT;
  open(OUT, ">$tmpfile");
  print OUT AlembicTagText(Text => $args{Text});
  close(OUT);
  my $timetag = "/var/lib/myfrdcsa/codebases/releases/perllib-0.1/perllib-0.1/Lingua/EN/Extract/Dates/TimeTag.pl";
  my $res = `$timetag -FD $tmpfile`;
  return $res;
}

sub GetDates {
  my (%args) = @_;
  my $timex = TimeRecognizeText(Text => $args{Text});
  my @res = $timex =~ /<TIMEX2 ?(.*?)>(.*?)<\/TIMEX2>/smg;
  my $dates = {};
  while (@res) {
    my $a = shift @res;
    my $b = shift @res;
    if ($a =~ /TYPE=\"(.*?)\" VAL=\"(.*?)\"/) {
      $dates->{$2}->{$args{Title}} = $b;
    }
  }
  return $dates;
}

1;
