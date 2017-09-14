package Capability::Tokenize;

use Lingua::EN::Sentence qw(get_sentences);

use File::Temp;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw (tokenize_treebank Tokenize);

sub Tokenize {
  my %args = @_;
  return [split /\s+/,tokenize_treebank($args{Text})];
}

sub tokenize_treebank {
  my $text = shift;
  my $engine = shift;
  if (defined $engine and $engine eq "perl") {
    $text =~ s/^"/`` /g;
    $text =~ s/([ ([{<])"/$1 `` /g;
    $text =~ s/\.\.\./ ... /g;
    $text =~ s/([,;:@#$%&])/ $1 /g;
    $text =~ s/([^.])([.])([])}>"']*)[ 	]*$/$1 $2$3 /g;
    $text =~ s/([?!])/ $1 /g;
    $text =~ s/([][(){}<>])/ $1 /g;
    $text =~ s/--/ -- /g;
    $text =~ s/$/ /;
    $text =~ s/^/ /;
    $text =~ s/"/ '' /g;
    $text =~ s/([^'])' /$1 ' /g;
    $text =~ s/'([sSmMdD]) / '$1 /g;
    $text =~ s/'ll / 'll /g;
    $text =~ s/'re / 're /g;
    $text =~ s/'ve / 've /g;
    $text =~ s/n't / n't /g;
    $text =~ s/'LL / 'LL /g;
    $text =~ s/'RE / 'RE /g;
    $text =~ s/'VE / 'VE /g;
    $text =~ s/N'T / N'T /g;
    $text =~ s/ ([Cc])annot / $1an not /g;
    $text =~ s/ ([Dd])'ye / $1' ye /g;
    $text =~ s/ ([Gg])imme / $1im me /g;
    $text =~ s/ ([Gg])onna / $1on na /g;
    $text =~ s/ ([Gg])otta / $1ot ta /g;
    $text =~ s/ ([Ll])emme / $1em me /g;
    $text =~ s/ ([Mm])ore'n / $1ore 'n /g;
    $text =~ s/ '([Tt])is / '$1 is /g;
    $text =~ s/ '([Tt])was / '$1 was /g;
    $text =~ s/ ([Ww])anna / $1an na /g;
    $text =~ s/  */ /g;
    $text =~ s/^ *//g;
    return $text;
  } else {
    my $f = File::Temp->new;
    my $res = get_sentences($text);
    if (defined $res) {
      foreach my $sentence (@$res) {
	$sentence =~ s/[\n\r]+/ /g;
	$sentence =~ s/\s+/ /g;
	print $f $sentence."\n";
      }
      my $fn = $f->filename;
      my $result = `/var/lib/myfrdcsa/codebases/internal/perllib/scripts/tokenizer.sed < $fn`;
      return $result;
    }
  }
}

1;
