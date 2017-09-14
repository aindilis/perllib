package System::EDITS3;

use Capability::Tokenize;
use Manager::Dialog qw(ApproveCommands);
use MyFRDCSA qw(ConcatDir);

use PerlLib::Util;
use Data::Dumper;
use File::Slurp;
use IO::File;
use Lingua::EN::Sentence;
use String::ShellQuote;
use XML::Simple;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Algorithm Source ModelFile EDITSDir Annotator /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Algorithm($args{Algorithm} || "token"); # token,
  my $algorithm = $self->Algorithm;
  $self->Source($args{Source} || "syntax");
  my $source = $self->Source;
  $self->ModelFile($args{ModelFile} || "modelRTE3dev-$algorithm-$source");
  $self->EDITSDir($args{EDITSDir} || "/var/lib/myfrdcsa/sandbox/edits-3.0/edits-3.0");
  $self->Annotator($args{Annotator} || "stanford-parser");
}

sub StartServer {
  my ($self,%args) = @_;
  my $res = PidsForProcess
    (
     Process => "java -server -mx400m -cp stanford-ner.jar edu.stanford.nlp.ie.NERServer 1234",
    );
  return if scalar @$res;
  my $algorithm = $self->Algorithm;
  my $modelfile = $self->ModelFile;
  my $editsdir = $self->EDITSDir;
  # check if it has been trained, if not, train
  if (! -f ConcatDir($self->EDITSDir,$modelfile)) {
    my $devfile = $args{DevFile} || "rte/etaf/".$self->Source."/RTE3_dev.xml";
    my $c1 = "export EDITS_PATH=\"/var/lib/myfrdcsa/sandbox/edits-3.0/edits-3.0\" && cd $editsdir && bin/edits -train -conf=share/configurations/conf2.xml $devfile $modelfile";
    ### bin/edits -train -algorithm=$algorithm -scheme=share/cost-schemes/simple-scheme.xml $devfile $modelfile";
    ### bin/edits -train -conf=share/configurations/conf2.xml rte/etaf/syntax/RTE3_dev.xml modelRTE3dev-token-syntax
    ### my $c1 = "cd $editsdir && bin/edits -train -algorithm=$algorithm -scheme=share/cost-schemes/simple-scheme.xml $devfile $modelfile";
    ### my $c2 = "cd $editsdir && bin/edits -train -conf=share/configurations/conf1.xml rte/etaf/morpho-syntax/RTE3_dev.xml $modelfile";
    # ApproveCommands
    #   (
    #    Commands => [$c1],
    #    Method => "parallel",
    #   );
  }
}

sub StartClient {
  my ($self,%args) = @_;
}

sub RTE {
  my ($self,%args) = @_;
  my $algorithm = $self->Algorithm;
  my $modelfile = $self->ModelFile;
  my $editsdir = $self->EDITSDir;
  my $inputfile = "/tmp/edits.xml";
  my $annotatedfile = "/tmp/edits-annotated.xml";
  my $outputfile = "/tmp/edits-output.xml";
  if (-f $inputfile) {
    system "rm ".shell_quote($inputfile);
  }
  if (-f $annotatedfile) {
    system "rm ".shell_quote($annotatedfile);
  }
  if (-f $outputfile) {
    system "rm ".shell_quote($outputfile);
  }

  # have to format the text carefully
  my $fh = IO::File->new;
  $fh->open(">$inputfile") or die "Death!\n";
  print $fh "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<entailment-corpus>\n";
  my $id = 1;
  foreach my $pair (@{$args{Pairs}}) {
    my $ttokenized = tokenize_treebank($pair->{T},"perl");
    my $htokenized = tokenize_treebank($pair->{H},"perl");
    my $entailment = $pair->{Entailment};
    print $fh "\t<pair task=\"IE\" id=\"$id\">\n\t\t<t>$ttokenized</t>\n\t\t<h>$htokenized</h>\n\t</pair>\n";
    # print $fh "\t<pair task=\"IE\" id=\"$id\" entailment=\"$entailment\">\n\t\t<t>$ttokenized</t>\n\t\t<h>$htokenized</h>\n\t</pair>\n";
    ++$id;
  }
  print $fh "</entailment-corpus>\n";
  $fh->close;
  # my $c2 = "export EDITS_PATH=\"/var/lib/myfrdcsa/sandbox/edits-3.0/edits-3.0\" && cd $editsdir && bin/edits-ga -f -x -o king $inputfile";
  my $c2 = "export EDITS_PATH=\"/var/lib/myfrdcsa/sandbox/edits-3.0/edits-3.0\" && cd $editsdir && bin/edits-ga -x -o king $inputfile";
  print "$c2\n";
  system $c2;

  # now read the outputfile
  # next;

  my $output = read_file($outputfile);
  # process this and return results

  my $xml = XMLin($output);

  my @results;
  $id = 1;
  foreach my $pair (@{$args{Pairs}}) {
    foreach my $key (qw(confidence normalization entailment distance score)) {
      $pair->{result}->{$key} = $xml->{pair}->{$id}->{$key};
    }
    push @results, $pair;
    ++$id;
  }
  return {
	  Success => 1,
	  Result => \@results,
	 };
}

1;
