package System::KBPToolkit;

use PerlLib::SwissArmyKnife;

use Moose;

has 'PAPropertyFile' =>
  (
   is => 'rw',
   isa => 'Str',
   default => '/var/lib/kbptoolkit/props/slotfilling/2014_frdcsa_kbp_slot_filling_pa.property',
   # default => 'props/slotfilling/2009_sample_kbp_slot_filling_pa.property',
  );

has 'PAOutputFile' =>
  (
   is => 'rw',
   isa => 'Str',
   default => '/var/lib/kbptoolkit/output/2014_frdcsa_kbp_slot_filling_pa.final',
   # output="./output/2009_sample_kbp_slot_filling_pa.final"
  );

sub BUILD {
  my ($self,$args) = @_;
  # system "source /usr/share/kbptoolkit/component.env";
  $ENV{KBP_HOME}='/usr/share/kbptoolkit/';
  #Java home directory
  $ENV{JAVA_HOME}='/usr/lib/jvm/java-7-openjdk-amd64/jre/';
  #Ant home directory
  $ENV{ANT_HOME}='/usr/share/ant';
  #path variable
  $ENV{PATH}="$ENV{PATH}:$ENV{JAVA_HOME}/bin:$ENV{ANT_HOME}/bin";
  # system "export PATH ANT_HOME JAVA_HOME";
  $ENV{CLASSPATH} = "bin:lib/ml/maxent-2.5.0.jar:lib/ml/minorthird.jar:lib/nlp/jwnl.jar:lib/nlp/lingpipe.jar:lib/nlp/opennlp-tools.jar:lib/nlp/plingstemmer.jar:lib/nlp/snowball.jar:lib/nlp/stanford-ner.jar:lib/nlp/stanford-parser.jar:lib/nlp/stanford-postagger.jar:lib/qa/javelin.jar:lib/search/googleapi.jar:lib/search/indri.jar:lib/search/yahoosearch.jar:lib/util/commons-logging.jar:lib/util/htmlparser.jar:lib/util/log4j.jar:lib/util/trove.jar:lib/search/lucene-core-3.0.2.jar:lib/search/lucene-smartcn-3.0.2.jar:lib/db/jdom.jar:lib/db/mltags.jar:lib/util/commons-math-2.0.jar";
}

sub DefaultPAPropertyFileValues {
  my ($self,$args) = @_;
  my $values =
    {
     'kbp.slotfilling.language' => 'English',
     'kbp.slotfilling.description' => 'Pattern matching pipeline',
     'kbp.querylist' => 'evaluation/2009_sample_slot_filling_queries.xml',
     'kbp.corpus.name' => 'BLEBDER_Sample_Source_Text_Corpus',
     'kbp.corpus.home' => 'corpus/Source_Text_Corpus/',
     'kbp.corpus.index' => 'corpus/Source_Text_Corpus/index/',
     'kbp.corpus.docmap' => 'corpus/Source_Text_Corpus/docs/docid_to_file_mapping.tab',
     'kbp.slotfilling.nameexpansion' => 'output/2009_sample_kbp_slot_filling_name_expansion',
     'kbp.corpus.maxquery' => '1000',
     'kbp.slotfilling.pa.threshold' => '3',
     'kbp.slotfilling.patterndir' => 'res/patternlearning/answerpatterns/',
     'kbp.slotfilling.pa.out' => 'output/2009_sample_kbp_slot_filling_pa',
     'kbp.slotfilling.pa.out.final' => 'output/2009_sample_kbp_slot_filling_pa.final',
     };
  # foreach my $key (keys %{$args->{Values}}) {
  #   $values->{$key} = $args->{Values}->{$key};
  # }
  return $values;
}

sub WriteKBPSlotFillingPAPropertyFile {
  my ($self,$args) = @_;
my $c =<<EOF;
# configuration for English KBP PA pipeline on LDC 2010 English source data
kbp.slotfilling.language = <KBP.SLOTFILLING.LANGUAGE>
kbp.slotfilling.description = <KBP.SLOTFILLING.DESCRIPTION>
#query list 
kbp.querylist = <KBP.QUERYLIST>

kbp.corpus.name = <KBP.CORPUS.NAME>
kbp.corpus.home = <KBP.CORPUS.HOME>
kbp.corpus.index = <KBP.CORPUS.INDEX>
kbp.corpus.docmap = <KBP.CORPUS.DOCMAP>

#name expansion file for the query list
kbp.slotfilling.nameexpansion = <KBP.SLOTFILLING.NAMEEXPANSION>
#maximum number of relevant documents retrieved
kbp.corpus.maxquery = <KBP.CORPUS.MAXQUERY>

kbp.slotfilling.pa.threshold = <KBP.SLOTFILLING.PA.THRESHOLD>
kbp.slotfilling.patterndir = <KBP.SLOTFILLING.PATTERNDIR>

#output file 
kbp.slotfilling.pa.out = <KBP.SLOTFILLING.PA.OUT>
kbp.slotfilling.pa.out.final = <KBP.SLOTFILLING.PA.OUT.FINAL>
EOF

  my $values =  $self->DefaultPAPropertyFileValues(Values => $args->{Values});
  foreach my $key (keys %$values) {
    my $token = '<'.uc($key).'>';
    my $value = $values->{$key};
    $c =~ s/$token/$value/sg;
  }
  WriteFile
    (
     File => $self->PAPropertyFile,
     Contents => $c,
    );
}

sub ExpandQueryNames {
  my ($self,$args) = @_;
  $self->ExecuteInDir
    (
     Command => 'java -cp $CLASSPATH -Xms3000m -Xmx3000m cuny.blender.kbp.slotfilling.ExpandNames '.$self->PAPropertyFile,
     Dir => $ENV{KBP_HOME},
    );
}

sub KBPPASlotFilling {
  my ($self,$args) = @_;
  $self->ExecuteInDir
    (
     Command => 'java -cp $CLASSPATH -Xms3000m -Xmx3000m cuny.blender.kbp.slotfilling.PASlotFilling '.$self->PAPropertyFile,
     Dir => $ENV{KBP_HOME},
    );
}

sub FilterResultsOfPAPipeline {
  my ($self,$args) = @_;
  $self->ExecuteInDir
    (
     Command => 'java -cp $CLASSPATH -Xms3000m -Xmx3000m cuny.blender.kbp.slotfilling.PAFiltering '.$self->PAPropertyFile,
     Dir => $ENV{KBP_HOME},
     );
}

sub ExecuteInDir {
  my ($self,%args) = @_;
  if (-d $args{Dir}) {
    my $dir = `pwd`;
    chdir $args{Dir};
    system $args{Command};
    chdir $dir;
  }
}

sub ProcessResults {
  my ($self,$args) = @_;
  if (-f $self->PAOutputFile) {
    return
      {
       Success => 1,
       Result => read_file($self->PAOutputFile),
      };
  } else {
    return
      {
       Success => 0,
      };
    }
}

1;

# #load environment variables from component.env
# . component.env

# #cd to the home directory
# cd $KBP_HOME
# export PATH ANT_HOME JAVA_HOME

# #build the toolkit from source and generate a jar file
# echo "========================================================"
# echo "building the toolkit from source and generate a jar file"
# echo "========================================================"
# ant 

# #run a sample test
# echo "========================================================"
# echo "running a sample test"
# echo "========================================================"
# CLASSPATH=bin:lib/ml/maxent-2.5.0.jar:lib/ml/minorthird.jar:lib/nlp/jwnl.jar:lib/nlp/lingpipe.jar:lib/nlp/opennlp-tools.jar:lib/nlp/plingstemmer.jar:lib/nlp/snowball.jar:lib/nlp/stanford-ner.jar:lib/nlp/stanford-parser.jar:lib/nlp/stanford-postagger.jar:lib/qa/javelin.jar:lib/search/googleapi.jar:lib/search/indri.jar:lib/search/yahoosearch.jar:lib/util/commons-logging.jar:lib/util/htmlparser.jar:lib/util/log4j.jar:lib/util/trove.jar:lib/search/lucene-core-3.0.2.jar:lib/search/lucene-smartcn-3.0.2.jar:lib/db/jdom.jar:lib/db/mltags.jar:lib/util/commons-math-2.0.jar

# #2.1 Expand query names
# java -cp $CLASSPATH -Xms3000m -Xmx3000m cuny.blender.kbp.slotfilling.ExpandNames props/slotfilling/2009_sample_kbp_slot_filling_pa.property
# #2.2 KBP PA slot filling
# java -cp $CLASSPATH -Xms3000m -Xmx3000m cuny.blender.kbp.slotfilling.PASlotFilling props/slotfilling/2009_sample_kbp_slot_filling_pa.property
# #2.3 Filter results of PA pipeline
# java -cp $CLASSPATH -Xms3000m -Xmx3000m cuny.blender.kbp.slotfilling.PAFiltering props/slotfilling/2009_sample_kbp_slot_filling_pa.property


# #validate the output files
# echo "========================================================"
# echo "validating the output files"
# echo "========================================================"



# flagfile="./success"
# output="./output/2009_sample_kbp_slot_filling_pa.final"
# expectedResult="./output/2009_sample_kbp_slot_filling_pa.validate"
# if [ ! -e $flagfile ];then
# rm -rf $flagfile
# fi
# result=$(diff -u $output $expectedResult)
# if [ $? -eq 0 ]; then 
# echo "Validation passed!"
# touch $flagfile
# else 
# echo "Validation failed!"
# fi
