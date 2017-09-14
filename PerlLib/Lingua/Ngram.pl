package PerlLib::Lingua::Ngram;

use Data::Dumper;
use Lingua::EN::Tokenizer;
use Text::Ngrams;
use Lingua::EN::Sentence qw( get_sentences );

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / NG Order / ];

sub init {
  my ($self,%args) = (shift,@_);
  $self->Order($args{Order} || 4);
  $self->NG
    (Text::NGrams->new
     (type => 'word',
      windowsize => $self->Order));
}

sub Process {
  my ($self,%args) = (shift,@_);
  my $sentences = get_sentences($args{Contents});
  foreach my $sentence (@$sentences) {
    if ((scalar split(/\s+/, $sentence)) > 10) {
      $self->NG->process_text($sentence);
    }
  }
}

sub MakeRegex {
  my ($self,%args) = (shift,@_);
  my $item = $args{Item};
  if (defined $item) {
    if ($item =~ /^[0-9]+$/) {
      return "<NUMBER>";
    } elsif (defined $args{Completion}) {
      return $item."\S*";
    } else {
      return $item;
    }
  } else {
    return "\S+";
  }
}

sub GetMatches {
  my ($self,%args) = (shift,@_);
  my $regex = join('\s+',map $self->MakeRegex(Item => $_), @{$args{Vector}});
  my $ngs = $self->NG->{table}->[$self->Order];
  my $res = {};
  foreach my $ng (keys %$ngs) {
    if ($ng =~ /$regex/) {
      $res->{$ng} += $ngs->{$ng};
    }
    $total += $ngs->{$ng};
  }
  foreach my $k (splice((sort {$res->{$b} <=> $res->{$b}} keys %$res),10)) {
    push @ret, $k;
  }
  return \@ret;
}

1;
