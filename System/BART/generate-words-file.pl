#!/usr/bin/perl -w

use Capability::Tokenize;

use Data::Dumper;
use Lingua::EN::Sentence qw(get_sentences);
use XML::Smart;

my $i = 1;
my $XML = XML::Smart->new();
my $text = "This is a test of the anaphora resolution system called BART.  This will test whether it works well enough.  Now we see.";
my $sentences = get_sentences($text);
foreach my $sentence (@$sentences) {
  foreach my $token (split /\s+/,tokenize_treebank($sentence, "perl")) {
    if (length $token > 0) {
      push @{$XML->{words}{word}},
	{
	 '/order' => [
		      'id',
		      'CONTENT'
		     ],
	 'id' => "word_".$i++,
	 'CONTENT' => $token,
	};
    }
  }
}

my $xmldata =$XML->data;

my @l = split /\n/, $xmldata;
shift @l;
shift @l;
print '<?xml version="1.0"?>
<!DOCTYPE words SYSTEM "words.dtd">'."\n".join("\n",@l)."\n";


# my $XML2 = XML::Smart->new('/var/lib/myfrdcsa/sandbox/bart-20091005/bart-20091005/BART/sample/Andy/Basedata/APW19980309.1618_words.xml');
# print Dumper($XML2);


