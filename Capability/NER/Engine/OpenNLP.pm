package Capability::NER::Engine::OpenNLP;

use Lingua::EN::Sentence;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Engine /

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

sub NER {
  my ($self,%args) = @_;
  # have to format the text carefully
  my $OUT;
  open (OUT, ">/tmp/opennlptext") or die "death!\n";
  print OUT $args{Text};
  close (OUT);
  my $dir = `pwd`;
  chdir "/var/lib/myfrdcsa/sandbox/opennlp-0.9.0/opennlp-0.9.0";
  my $res = `java -cp output/opennlp-tools-1.3.0.jar:lib/ant.jar:lib/jakarta-ant-optional.jar:lib/jwnl-1.3.3.jar:lib/maxent-2.4.0.jar:lib/trove.jar opennlp.tools.lang.english.SentenceDetector opennlp.models/english/sentdetect/EnglishSD.bin.gz < /tmp/opennlptext | java -Xmx350m  -cp output/opennlp-tools-1.3.0.jar:lib/ant.jar:lib/jakarta-ant-optional.jar:lib/jwnl-1.3.3.jar:lib/maxent-2.4.0.jar:lib/trove.jar opennlp.tools.lang.english.NameFinder opennlp.models/english/namefind/*.bin.gz`;
  chdir $dir;
  return $res;
}

1;
