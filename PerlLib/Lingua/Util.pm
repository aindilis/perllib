package PerlLib::Lingua::Util;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw (ListSentences GetSentences);

use Lingua::EN::Sentence qw ( get_sentences );
use Lingua::EN::Tagger;
# use Lingua::Ispell qw( spellcheck );

sub ListSentences {
  my $input = shift;
  $input =~ s/[\r\n]/ /g;
  my $sentences = get_sentences($input);
  foreach my $sentence (@$sentences) {
    print "$sentence\n";
  }
}

# sub Spelling {
#   my ($self,%args) = @_;
#   Lingua::Ispell::allow_compounds(1);
#   for my $r ( spellcheck( shift ) ) {
#     if ( $r->{'type'} eq 'ok' ) {
#       # as in the case of 'hello'
#       print "'$r->{'term'}' was found in the dictionary.\n";
#     } elsif ( $r->{'type'} eq 'root' ) {
#       # as in the case of 'hacking'
#       print "'$r->{'term'}' can be formed from root '$r->{'root'}'\n";
#     } elsif ( $r->{'type'} eq 'miss' ) {
#       # as in the case of 'perl'
#       print "'$r->{'term'}' was not found in the dictionary;\n";
#       print "Near misses: @{$r->{'misses'}}\n";
#     } elsif ( $r->{'type'} eq 'guess' ) {
#       # as in the case of 'salmoning'
#       print "'$r->{'term'}' was not found in the dictionary;\n";
#       print "Root/affix Guesses: @{$r->{'guesses'}}\n";
#     } elsif ( $r->{'type'} eq 'compound' ) {
#       # as in the case of 'fruithammer'
#       print "'$r->{'term'}' is a valid compound word.\n";
#     } elsif ( $r->{'type'} eq 'none' ) {
#       # as in the case of 'shrdlu'
#       print "No match for term '$r->{'term'}'\n";
#     }
#     # and numbers are skipped entirely, as in the case of 42.
#   }
# }

sub GetSentences {
  my %args = @_;
  my $sentences = get_sentences($args{Text});
  my @res;
  foreach my $line (@$sentences) {
    $line =~ s/\s+/ /g;
    $line =~ s/^\s*//;
    $line =~ s/\s*$//;
    push @res, $line;
  }
  return \@res;
}

1;
