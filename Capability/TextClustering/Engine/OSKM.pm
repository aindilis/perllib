package Capability::TextClustering::Engine::OSKM;

use Lingua::EN::Sentence;

use Data::Dumper;
use File::Slurp;
use String::ShellQuote;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Texts NumberOfClusters /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Texts({});
  $self->NumberOfClusters($args{NumberOfClusters} || 30);
}

sub StartServer {
  my ($self,%args) = @_;
}

sub StartClient {
  my ($self,%args) = @_;
}

sub AddTexts {
  my ($self,%args) = @_;
  foreach my $text (@{$args{Texts}}) {
    $text =~ s/(\n\s*)+\n/\n/g;
    $self->Texts->{$text}++;
  }
}

sub GetClusters {
  my ($self,%args) = @_;
  my $k = $args{NumberOfClusters} || $self->NumberOfClusters;

  #     octave
  #       init_tmg
  # 	# press enter

  my $oskmdatadir = "/var/lib/myfrdcsa/codebases/internal/perllib/data/modules/Capability/TextClustering/Engine/OSKM";
  my $ccsdir = "$oskmdatadir/ccs";
  my $filename = "$oskmdatadir/output/texts.txt";

  if (0) {
    system "rm ".shell_quote($filename);
    my $fh = IO::File->new;
    $fh->open(">$filename") or die "ouch!\n";
    # obviously need to add the OPTION for a better separator
    my @texts = keys %{$self->Texts};
    print $fh join("\n\n",@texts);
    $fh->close();
  } else {
    system "rm /var/lib/myfrdcsa/codebases/internal/perllib/data/modules/Capability/TextClustering/Engine/OSKM/files.txt /var/lib/myfrdcsa/codebases/internal/perllib/data/modules/Capability/TextClustering/Engine/OSKM/output/* /var/lib/myfrdcsa/codebases/internal/perllib/data/modules/Capability/TextClustering/Engine/OSKM/matrix/*";
    my $i = 0;
    # system "rm ".shell_quote($filename);
    foreach my $key (keys %{$self->Texts}) {
      my $fh = IO::File->new;
      $fh->open(">$filename.$i") or die "ouch!\n";
      print $fh "Doc $i\n$key";
      $fh->close();
      ++$i;
    }
    system "find /var/lib/myfrdcsa/codebases/internal/perllib/data/modules/Capability/TextClustering/Engine/OSKM/output/ | sort > /var/lib/myfrdcsa/codebases/internal/perllib/data/modules/Capability/TextClustering/Engine/OSKM/files.txt";
    system "cd /var/lib/myfrdcsa/codebases/internal/perllib/data/modules/Capability/TextClustering/Engine/OSKM/matrix && perl -I/var/lib/myfrdcsa/sandbox/tmg-5.0r6/tmg-5.0r6/perl /var/lib/myfrdcsa/sandbox/tmg-5.0r6/tmg-5.0r6/perl/tmg_perl.pl /var/lib/myfrdcsa/codebases/internal/perllib/data/modules/Capability/TextClustering/Engine/OSKM/matrix \"\" 0 /home/andrewdo/Media/data/backup/onshore-laptop-backup/.cpan/build/WordNet-Similarity-1.03/samples/stoplist.txt 0 0 1000 /var/lib/myfrdcsa/codebases/internal/perllib/data/modules/Capability/TextClustering/Engine/OSKM/files.txt 0";
  }
  system "rm /var/lib/myfrdcsa/codebases/internal/perllib/data/modules/Capability/TextClustering/Engine/OSKM/ccs/*";
  my $CODE =<<CODE;
  load /var/lib/myfrdcsa/codebases/internal/perllib/data/modules/Capability/TextClustering/Engine/OSKM/matrix/matrix.tmp
  load /var/lib/myfrdcsa/codebases/internal/perllib/data/modules/Capability/TextClustering/Engine/OSKM/matrix/wpd.tmp
  addpath("/var/lib/myfrdcsa/sandbox/oskm-20091005/oskm-20091005/textclust");
  toccs(matrix,wpd,"/var/lib/myfrdcsa/codebases/internal/perllib/data/modules/Capability/TextClustering/Engine/OSKM/ccs/text-clustering")
CODE
  system "cd /var/lib/myfrdcsa/sandbox/oskm-20091005/oskm-20091005 && octave --eval ".shell_quote($CODE);
  # my $oskmdir = "/var/lib/myfrdcsa/sandbox/oskm-20091005/oskm-20091005";
  system "/var/lib/myfrdcsa/sandbox/oskm-20091005/oskm-20091005/oskm/oskm -K 10 -f /var/lib/myfrdcsa/codebases/internal/perllib/data/modules/Capability/TextClustering/Engine/OSKM/ccs/text-clustering";
  my $i10 = read_file("/var/lib/myfrdcsa/codebases/internal/perllib/data/modules/Capability/TextClustering/Engine/OSKM/ccs/text-clustering.i10");
  my $c10 = read_file("/var/lib/myfrdcsa/codebases/internal/perllib/data/modules/Capability/TextClustering/Engine/OSKM/ccs/text-clustering.c10");

  # now map the numbers to the files
  print Dumper([$i10,$c10]);

  # and then return the stuff
  my $clusters = {};
  return {
	  Clusters => $clusters,
	 };
}

1;

# `tmg' is a function from the file /s1/temp/myfrdcsa/sandbox/tmg-5.0r6/tmg-5.0r6/tmg.m

#  TMG - Text to Matrix Generator 
#    TMG parses a text collection and generates the term - 
#    document matrix.
#    A = TMG(FILENAME) returns the term - document matrix, 
#    that corresponds to the text collection contained in 
#    files of directory (or file) FILENAME. 
#    Each document must be separeted by a blank line (or 
#    another delimiter that is defined by OPTIONS argument) 
#    in each file. 
#    [A, DICTIONARY] = TMG(FILENAME) returns also the 
#    dictionary for the collection, while [A, DICTIONARY, 
#    GLOBAL_WEIGHTS, NORMALIZED_FACTORS] = TMG(FILENAME) 
#    returns the vectors of global weights for the dictionary 
#    and the normalization factor for each document in case 
#    such a factor is used. If normalization is not used TMG 
#    returns a vector of all ones. 
#    [A, DICTIONARY, GLOBAL_WEIGHTS, NORMALIZATION_FACTORS, 
#    WORDS_PER_DOC] = TMG(FILENAME) returns statistics for 
#    each document, i.e. the number of terms for each document. 
#    [A, DICTIONARY, GLOBAL_WEIGHTS, NORMALIZATION_FACTORS, 
#    WORDS_PER_DOC, TITLES, FILES] = TMG(FILENAME) returns in 
#    FILES the filenames contained in directory (or file) 
#    FILENAME and a cell array (TITLES) that containes a 
#    declaratory title for each document, as well as the 
#    document's first line. Finally [A, DICTIONARY, 
#    GLOBAL_WEIGHTS, NORMALIZATION_FACTORS, WORDS_PER_DOC, 
#    TITLES, FILES, UPDATE_STRUCT] = TMG(FILENAME) returns a 
#    structure that keeps the essential information for the 
#    collection' s update (or downdate).

#    TMG(FILENAME, OPTIONS) defines optional parameters: 
#        - OPTIONS.use_mysql: Indicates if results are to be 
#          stored in MySQL.
#        - OPTIONS.db_name: The name of the directory where 
#          the results are to be saved.
#        - OPTIONS.delimiter: The delimiter between documents 
#          within the same file. Possible values are 'emptyline' 
#          (default), 'none_delimiter' (treats each file as a 
#          single document) or any other string.
#        - OPTIONS.line_delimiter: Defines if the delimiter 
#          takes a whole line of text (default, 1) or not.
#        - OPTIONS.stoplist: The filename for the stoplist, 
#          i.e. a list of common words that we don't use for 
#          the indexing (default no stoplist used).
#        - OPTIONS.stemming: Indicates if the stemming algorithm 
#          is used (1) or not (0 - default).
#        - OPTIONS.update_step: The step used for the incremental 
#          built of the inverted index (default 10,000).
#        - OPTIONS.min_length: The minimum length for a term 
#          (default 3).
#        - OPTIONS.max_length: The maximum length for a term 
#          (default 30).
#        - OPTIONS.min_local_freq: The minimum local frequency for 
#          a term (default 1).
#        - OPTIONS.max_local_freq: The maximum local frequency for 
#          a term (default inf).
#        - OPTIONS.min_global_freq: The minimum global frequency 
#          for a term (default 1).
#        - OPTIONS.max_global_freq: The maximum global frequency 
#          for a term (default inf).
#        - OPTIONS.local_weight: The local term weighting function 
#          (default 't'). Possible values (see [1, 2]): 
#                't': Term Frequency
#                'b': Binary
#                'l': Logarithmic
#                'a': Alternate Log
#                'n': Augmented Normalized Term Frequency
#        - OPTIONS.global_weight: The global term weighting function 
#          (default 'x'). Possible values (see [1, 2]): 
#                'x': None
#                'e': Entropy
#                'f': Inverse Document Frequency (IDF)
#                'g': GfIdf
#                'n': Normal
#                'p': Probabilistic Inverse
#        - OPTIONS.normalization: Indicates if we normalize the 
#          document vectors (default 'x'). Possible values:
#                'x': None
#                'c': Cosine
#        - OPTIONS.dsp: Displays results (default 1) or not (0) to 
#          the command window.

#    REFERENCES: 
#    [1] M.Berry and M.Browne, Understanding Search Engines, Mathematical 
#    Modeling and Text Retrieval, Philadelphia, PA: Society for Industrial 
#    and Applied Mathematics, 1999.
#    [2] T.Kolda, Limited-Memory Matrix Methods with Applications,
#    Tech.Report CS-TR-3806, 1997.

#  Copyright 2008 Dimitrios Zeimpekis, Efstratios Gallopoulos
# :
# Additional help for built-in functions and operators is
# available in the on-line version of the manual.  Use the command
# `doc <topic>' to search the manual index.

# Help and information about Octave is also available on the WWW
# at http://www.octave.org and via the help@octave.org
# mailing list.
