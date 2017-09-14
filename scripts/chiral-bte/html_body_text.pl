#!/usr/bin/perl
use HTML::TreeBuilder;

our $alpha = 0.5;
our ($best,$best_rate);

our %special_alpha=('div',0.8,'span',1,'p',1,'a',0.1,
		    'ul',0.9,'ol',0.9,'li',0.9,
		    'style',0.1,'script',0.1,'noscript',0.1,
		    'b',1,'i',1,'h1',1,'h2',1,'h3',1,'font',1);
our %output_tags=('div',1,'span',1,'body',1);

sub get_honbun {
  my $file = shift;
  print STDERR "$file\n";

  my $tree = HTML::TreeBuilder->new;
  $tree->parse_file($file);

  $best=undef;
  traverse($tree);


  if (defined $best) {
    my ($id)=split(/\s+/,'#'.$best->attr("id"));
    my ($klass)=split(/\s+/,'.'.$best->attr("class"));
    for my $k (grep {length($_)>1} ($id,$klass)) {
      print "$k\n";
    }
    # print $best->as_text,"\n";
  }

  $tree = $tree->delete;
}

sub traverse {
  my $node = shift;

  my ($len,$score,$volume)=(0,0,0);
  foreach my $e ($node->content_list) {
    if (ref $e eq 'HTML::Element') {
      my ($s,$v)=traverse($e);
      # print $e->tag,"\n";

      my $sa=$special_alpha{lc($e->tag)};
      $s*=($sa?$sa:$alpha);
      $score+=$s;
      $volume+=$v;
    } else {
      # print $e,"\n";
      $len=length($e);
    }
  }

  $score+=$len;
  $volume+=$len;

  # print $node->tag(),"\n$score,$volume\n\n";

  if ($volume>0 && $output_tags{lc($node->tag)}) {
    my $id=$node->attr("id");
    my $klass=$node->attr("class");
    if ($id && $id !~ /:/ || $klass && $klass !~ /:/) {
      my $rate=$score*$score/$volume;
      ($best,$best_rate)=($node,$rate)
	if (!defined $best || $best_rate<$rate);
    }
  }

  return ($score,$volume);
}

sub main {
  get_honbun($_) for @ARGV;
}

main();
