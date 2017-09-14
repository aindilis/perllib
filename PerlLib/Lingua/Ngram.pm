package PerlLib::Lingua::Ngram;

use Data::Dumper;
use Text::Ngrams;
use Lingua::EN::Sentence qw( get_sentences );

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / NG Order / ];

sub init {
  my ($self,%args) = (shift,@_);
}

sub Process {
  my ($self,%args) = (shift,@_);
  my $sentences = get_sentences($args{Contents});
  if (! defined $self->NG) {
    $self->Order($args{Order} || 4);
    $self->NG
      (Text::Ngrams->new
       (type => 'word',
	windowsize => $self->Order));
  }
  foreach my $sentence (@$sentences) {
    my @a = split /\s+/, $sentence;
    if (1 or @a > 10) {
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
      return $item.'\S*';
    } else {
      return $item;
    }
  } else {
    return '\S+';
  }
}

sub GetMatches {
  my ($self,%args) = (shift,@_);
  my $regex = join('\s+',map $self->MakeRegex(Item => $_), @{$args{Vector}});
  print "<$regex>\n";
  my $ngs = $self->NG->{table}->[$self->Order];
  my $res = {};
  foreach my $ng (keys %$ngs) {
    if ($ng =~ /$regex/i) {
      $res->{$ng} += $ngs->{$ng};
    }
    $total += $ngs->{$ng};
  }
  my @a = sort {$res->{$b} <=> $res->{$b}} keys %$res;
  my @ret;
  foreach my $k (splice(@a,0,$args{Depth})) {
    push @ret, $k;
  }
  return \@ret;
}

sub Print {
  my ($self,%args) = (shift,@_);
  print Dumper($self->NG->{table}->[$self->Order]);
}

1;
