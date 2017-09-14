package Capability::POSTagging::GPoSTTL;

use Data::Dumper;
use File::Temp;
use Lingua::EN::Sentence qw(get_sentences);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Server Client /

  ];

sub init {
  my ($self,%args) = @_;
}

sub StartServer {
  my ($self,%args) = @_;
}

sub StartClient {
  my ($self,%args) = @_;
}

sub Tag {
  my ($self,%args) = @_;
  my $fh = File::Temp->new;
  my $filename = $fh->filename;
  if ($args{Style} and $args{Style} eq "supersensetagger") {
    my $sentences = get_sentences($args{Text});
    my @sents;
    foreach my $sentence (@$sentences) {
      $sentence =~ s/\n/ /g;
      $sentence =~ s/\s+/ /g;
      push @sents, $sentence;
    }
    my $it = join("\nThis is the sentazoid to split on.\n",@sents);
    print $fh $it;
    my $res = `gposttl --brill-mode $filename`;
    my @results;
    my $i = 1;
    # foreach my $line (split /\s*This\/DT is\/VBZ the\/DT sentazoid\/JJ to\/TO split\/VB on\/IN \.\/\.\s*/, $res) {
    foreach my $line (split /\s*This\/DT is\/VBZ the\/DT sentazoid\/JJ to\/TO split\/VB on\/IN \.\/\.\s*/, $res) {
      my @l;
      push @l, "S-$i";
      foreach my $thing (split /\s+/, $line) {
	$thing =~ s/\// /g;
	push @l, $thing;
      }
      push @results, join("\t",@l);
      ++$i;
    }
    return join("\n",@results);
  }
}

1;
