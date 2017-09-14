package System::RelEx;

use Data::Dumper;
use File::Temp qw(tempfile);
use Lingua::EN::Sentence qw(get_sentences);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / /

  ];

sub init {
  my ($self,%args) = @_;
}

sub Parse {
  my ($self,%args) = @_;
  my $text;
  my $sentences;
  if (exists $args{Text}) {
    $text = $args{Text};
    $sentences = get_sentences($text);
  } elsif (exists $args{Sentences}) {
    $sentences = $args{Sentences};
  }
  my @all;
  foreach my $sentence (@$sentences) {
    my @t = split /\W+/, $sentence;
    if (scalar @t <= 20) {
      $sentence =~ s/\n/ /sg;
      push @all, $sentence;
    }
  }
  my $fh = File::Temp->new();
  my $tmpfile = $fh->filename;
  print $fh join("\n",@all);

  $ENV{LANG}="en_US.UTF-8";

  my $VM_OPTS="-Xmx1024m -Djava.library.path=/usr/lib:/usr/local/lib";


  my $RELEX_OPTS=[
		  "-Drelex.algpath=data/relex-semantic-algs.txt",
		  "-Dwordnet.configfile=data/wordnet/file_properties.xml",
		 ];

  my $CLASSPATH=[
		 "bin",
		 "/var/lib/myfrdcsa/sandbox/relex-0.98.1/relex-0.98.1/bin",
		 "/var/lib/myfrdcsa/sandbox/jwnl-14/jwnl-14/jwnl.jar",
		 "/var/lib/myfrdcsa/sandbox/opennlp-1.4.2/opennlp-1.4.2/opennlp-tools-1.4.2/opennlp-tools-1.4.2/output/opennlp-tools-1.4.2.jar",
		 "/var/lib/myfrdcsa/sandbox/opennlp-1.4.2/opennlp-1.4.2/opennlp-tools-1.4.2/opennlp-tools-1.4.2/lib/maxent-2.5.2.jar",
		 "/var/lib/myfrdcsa/sandbox/opennlp-1.4.2/opennlp-1.4.2/opennlp-tools-1.4.2/opennlp-tools-1.4.2/lib/trove.jar",
		 "/var/lib/myfrdcsa/sandbox/link-grammar-4.4.2/link-grammar-4.4.2/linkgrammar-4.4.2.jar",
		 "/usr/share/java/commons-logging.jar",
		 "/usr/share/java/gnu-getopt.jar",
		 "/usr/share/java/xercesImpl.jar",
		 "/var/lib/myfrdcsa/sandbox/gate-5.0/gate-5.0/bin/gate.jar",
		 "/var/lib/myfrdcsa/sandbox/gate-5.0/gate-5.0/lib/jdom.jar",
		 "/var/lib/myfrdcsa/sandbox/gate-5.0/gate-5.0/lib/jasper-compiler-jdt.jar",
		 "/var/lib/myfrdcsa/sandbox/gate-5.0/gate-5.0/lib/nekohtml-1.9.8+2039483.jar",
		 "/var/lib/myfrdcsa/sandbox/gate-5.0/gate-5.0/lib/ontotext.jar",
		 "/var/lib/myfrdcsa/sandbox/gate-5.0/gate-5.0/lib/stax-api-1.0.1.jar",
		 "/var/lib/myfrdcsa/sandbox/gate-5.0/gate-5.0/lib/PDFBox-0.7.2.jar",
		 "/var/lib/myfrdcsa/sandbox/gate-5.0/gate-5.0/lib/wstx-lgpl-3.2.3.jar",
		];

    chdir "/var/lib/myfrdcsa/sandbox/relex-0.98.1/relex-0.98.1";
  my $command = "cat $tmpfile | java $VM_OPTS ".join(" ",@$RELEX_OPTS)." -classpath \"".join(":",@$CLASSPATH)."\" relex.WebFormat -n 4 -g";
  print "$command\n";
  my $result = `$command`;
  print Dumper($result);
}

1;





#!/bin/bash
#
# relation-extractor.sh: example relationship extractor.
# Parses a simple sentence about dinosaurs.
# This provides a basic demo of the RelEx abilities.
#
# Flags:
# RelationExtractor [-s Sentence (in quotes)] [-h (show this help)] 
# [-t (show parse tree)] [-l (show parse links)] 
# [-o (show opencog S-exp output)] [-v verbose]
# [-n parse-number] [--maxParses N] [--maxParseSeconds N]

export LANG=en_US.UTF-8

# Remote debugging
# VM_OPTS="-Xdebug -Xnoagent -Djava.compiler=none -Xrunjdwp:transport=dt_socket,server=y,suspend=y -Xmx1024m -Djava.library.path=/usr/lib:/usr/local/lib"

VM_OPTS="-Xmx1024m -Djava.library.path=/usr/lib:/usr/local/lib"

# By default, these resources are read from the relex jar file.
# Alternately, they are taken from the default paths, which are the
# same as those immediate below.
# RELEX_OPTS="\
# 	-Drelex.algpath=data/relex-semantic-algs.txt \
# 	-Dwordnet.configfile=data/wordnet/file_properties.xml \
# 	"

# /var/lib/myfrdcsa/sandbox/opennlp-1.4.2/opennlp-1.4.2/opennlp-tools-1.4.2/opennlp-tools-1.4.2/output/opennlp-tools-1.4.2.jar:\
# /var/lib/myfrdcsa/sandbox/opennlp-1.4.2/opennlp-1.4.2/opennlp-tools-1.4.2/opennlp-tools-1.4.2/lib/maxent-2.5.2.jar:\
# /var/lib/myfrdcsa/sandbox/opennlp-1.4.2/opennlp-1.4.2/opennlp-tools-1.4.2/opennlp-tools-1.4.2/lib/trove.jar:\

CLASSPATH="-classpath \"\
bin:\
/var/lib/myfrdcsa/sandbox/relex-0.98.1/relex-0.98.1/bin:\
/var/lib/myfrdcsa/sandbox/jwnl-14/jwnl-14/jwnl.jar:\
/var/lib/myfrdcsa/sandbox/link-grammar-4.4.2/link-grammar-4.4.2/linkgrammar-4.4.2.jar:\
/var/lib/myfrdcsa/sandbox/opennlp-tools-1.3.0/opennlp-tools-1.3.0/output/opennlp-tools-1.3.0.jar:\
/var/lib/myfrdcsa/sandbox/opennlp-tools-1.3.0/opennlp-tools-1.3.0/lib/maxent-2.4.0.jar:\
/var/lib/myfrdcsa/sandbox/opennlp-tools-1.3.0/opennlp-tools-1.3.0/lib/trove.jar:\
/usr/share/java/commons-logging.jar:\
/usr/share/java/gnu-getopt.jar:\
/usr/share/java/xercesImpl.jar:\
/var/lib/myfrdcsa/sandbox/gate-5.0/gate-5.0/bin/gate.jar:\
/var/lib/myfrdcsa/sandbox/gate-5.0/gate-5.0/lib/jdom.jar:\
/var/lib/myfrdcsa/sandbox/gate-5.0/gate-5.0/lib/jasper-compiler-jdt.jar:\
/var/lib/myfrdcsa/sandbox/gate-5.0/gate-5.0/lib/nekohtml-1.9.8+2039483.jar:\
/var/lib/myfrdcsa/sandbox/gate-5.0/gate-5.0/lib/ontotext.jar:\
/var/lib/myfrdcsa/sandbox/gate-5.0/gate-5.0/lib/stax-api-1.0.1.jar:\
/var/lib/myfrdcsa/sandbox/gate-5.0/gate-5.0/lib/PDFBox-0.7.2.jar:\
/var/lib/myfrdcsa/sandbox/gate-5.0/gate-5.0/lib/wstx-lgpl-3.2.3.jar\"
"

# wordnet doesn't work with the gate version of jwnl ...
# /opt/GATE-4.0/lib/jwnl.jar:\

# Read a sentence from stdin:
#echo "Alice wrote a book about dinosaurs for the University of California in Berkeley." | \
#	java $VM_OPTS $RELEX_OPTS $CLASSPATH relex.RelationExtractor -n 4 -l -t -f -r -g
#/usr/lib/jvm/java-6-sun/bin/java $VM_OPTS $RELEX_OPTS $CLASSPATH relex.RelationExtractor -n 4 -l -t -f -r -g -s "Alice ate the mushroom."

COMMAND="java $VM_OPTS $RELEX_OPTS $CLASSPATH relex.RelationExtractor -n 4 -l -t -f -r -s \"This system seems to work really well, we shall have to see exactly how to deploy it.\""
echo $COMMAND

java $VM_OPTS $RELEX_OPTS $CLASSPATH relex.RelationExtractor -n 4 -l -t -f -r -s "This system seems to work really well, we shall have to see exactly how to deploy it."

# Alternately, the sentence can be specified on the command line:
# java $VM_OPTS $RELEX_OPTS $CLASSPATH relex.RelationExtractor -n 4 -l -t \
#	-s "Alice wrote a book about dinosaurs for the University of California in Berkeley."

# Alternately, a collection of sentences can be read from a file:
# cat trivial-corpus.txt | \
#	java $VM_OPTS $RELEX_OPTS $CLASSPATH relex.RelationExtractor -n 4 -l -t

# A collection of sentences can be read from a file and sent to the 
# opencog server (assumed to be at port 17001 on localhost).
# cat trivial-corpus.txt | \
#	java $VM_OPTS $RELEX_OPTS $CLASSPATH relex.RelationExtractor -o | \
#	telnet localhost 17001
