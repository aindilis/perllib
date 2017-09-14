package PerlLib::Lingua::Tokenizer;

# http://www.geocities.com/SoHo/Square/3472/tokenizer.txt

# To make English text suitable for input into a parser.
#
# Requirements:
# 1. Put each sentence of the article on a new line.
# 2. Protect abbreviations; e.g., Mr., M.D., Mrs., Esq., and so on.
#    When you're tokenizing (or splitting off) the punctuation in #4
#    don't tokenize the punctuation in these abbreviations.
# 3. Contractions: Expand all the contractions you encounter:
#    can't ==> can 't
#    wouldn't ==> would n't
#    I'll ==> I 'll
#    and so on ....
# 4. Tokenize punctuation:
#    ... business day. ==> ... business day .
#    ...reason to be cheerful: ==> ...reason to be cheerful :
#    "They are in trouble." ==> " They are in trouble . "
#    also for , ! ( ) ? ; and so on ....
# 5. Insert paragraph markers between the paragraphs, so as not to
#    lose the text marking.
# 6. Do not split names that have false punctuation in them;
#     e.g., index.html, http://name.here.
# 7. Handle the abbreviations and contractions in two different
#    subroutines.
# (as specified in Professor Pustejovsky's course in computational
#  linguistics at Brandeis University)
#
# Extract strings with false punctuation and protect them
#
# Definition of false punctuation:
# 1. A comma between numbers is assumed to be a thousands separator (e.g. 1,000)
#    that has to be protected.
# 2. Any dot "." with adjacent characters to the left and right can be assumed to
#    not be a period indicating end of sentence and therefore has to be protected.
#    Between two numbers it is a
#    a decimal point e.g. 3.24, between two strings it is likely to be
#    part of a domain name, e.g. "cnbc.com". This rule will fail when
#    they have typed their sentences like this "This is a cat.It is big."
#    which is a little strange and is regarded as an error here.
# 3. Any series of adjacent dots like "..." is assumed to denote a short pause
#    in someone's speech.
# 4. Otherwise dot with space with space on the left and space on the right
#    is assumed to be a period indicating end of sentence.


$filename = "toktest.txt";
$text = "";
file2string($filename);

# protecting abbreviations
protect('Dr.','M.D.','P.M.D.','Mr.','a.m.','p.m.','Inc.','S.E.','sec.');

# protecting multiple dots
$text =~ s/(\.{2,})/protectit($1,".","@")/eg;

# protecting dots between characters
$text =~ s/(\S+\.\S+)/protectit($1,".","@")/eg;

# protecting commas in numbers
$text =~ s/(\d+\,*\d+)/protectit($1,",","#")/eg;

expand("can't","'t");
expand("wouldn't","n't");
expand("don't","'t");
expand("I'll","'ll");
expand("we'll","'ll");
expand("that's","'s");

separate(".");
separate(",");
separate("!");
separate("(");
separate(")");
separate("?");
separate(";");
separate("\"");

unprotect();

print "$text\n";


sub file2string {
     my($filename) = $_[0];

        open(FILE,$filename) or die "Can't open file $filename\n";
        @text = <FILE>;
        $text = join(" ",@text);
        $text =~ s/\n\s*?\n/  <PARAGRAPH>  /g;
        $text =~ s/\n/ /g;
        $text =~ s/\r/ /g;
     }

sub expand {
     my($word,$clitic,$expanded);
        $word     = $_[0];
        $clitic   = $_[1];
        $expanded = $word;
        $expanded =~ s/$clitic/ $clitic/gi;
        $text     =~ s/$word/$expanded/gi;
     }

sub separate {
     my($punc);
        $punc = quotemeta($_[0]);
        $text =~ s/$punc/ $punc /g;
     }

sub unprotect {
     $text =~ s/\\//g;
        $text =~ s/@/./g;
     }

sub protect {
     my(@toprotect) = sort { length($b) <=> length($a) } @_;
        my($before,$after);
     foreach $item (@toprotect) {
             $before = quotemeta($item);
	           $after  = $before;
	           $after  =~ s/\./@/g;
	           $text   =~ s/$before/$after/g;
	   }
     }

sub protectit {
     my($arg0,$arg1,$arg2);
        $arg0 = $_[0];
        $arg1 = quotemeta($_[1]);
        $arg2 = $_[2];
        $arg0 =~ s/$arg1/$arg2/g;
        return $arg0;
     }

1;
