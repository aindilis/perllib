package System::MinorThird;

use Env qw(CLASSPATH);

use Manager::Dialog qw (Message);
use MyFRDCSA;
use PerlLib::Collection;
use System::MinorThird::Entry;

use Data::Dumper;
use String::ShellQuote;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / TrainingSet TestingSet TrainingDir TestingDir Debug /

  ];

sub init {
  my ($self,%args) = @_;

  # my $minorthird = "/var/lib/myfrdcsa/sandbox/minorthird-20080611/minorthird-20080611";
  # chdir $minorthird;
  # system "$minorthird/script/setup";

  $ENV{JAVA_HOME} = "/usr/lib/jvm/java-6-sun-1.6.0.07/jre";
  $ENV{MINORTHIRD} = "/var/lib/myfrdcsa/sandbox/minorthird-20080611/minorthird-20080611";
  # $ENV{CLASSPATH} = "$ENV{MINORTHIRD}/class:$ENV{MINORTHIRD}/lib/*:$ENV{MINORTHIRD}/class/edu/cmu/minorthird/ui/*";
  $ENV{CLASSPATH} ="$ENV{CLASSPATH}:.:$ENV{MINORTHIRD}/class:$ENV{MINORTHIRD}/lib/*:$ENV{MINORTHIRD}/lib/minorThirdIncludes.jar";
  $ENV{CLASSPATH} ="$ENV{CLASSPATH}:.:$ENV{MINORTHIRD}/lib/mixup/*:$ENV{MINORTHIRD}/config";
  $ENV{MONTYLINGUA} ="$ENV{MINORTHIRD}/lib/montylingua";
  $ENV{ORG} = "$ENV{MINORTHIRD}/lib/poi/src/java/org";

  $self->Debug(1);
  $self->TrainingSet
    ($args{TrainingSet} ||
     PerlLib::Collection->new
     (Type => "System::MinorThird::Entry",
      StorageFile => $args{TrainingStorageFile} || "trainingset"));
  $self->TestingSet
    ($args{TestingSet} ||
     PerlLib::Collection->new
     (Type => "System::MinorThird::Entry",
      StorageFile => $args{TestingStorageFile} || "testingset"));
  $self->TrainingSet->Load;
  $self->TestingSet->Load;
  if ($args{Force} or
      $self->TrainingSet->IsEmpty and
      $args{TrainingDir} and
      -d $args{TrainingDir}) {
    $self->TrainingDir($args{TrainingDir});
    foreach my $file (split /\n/,`ls $args{TrainingDir}`) {
      $self->TrainingSet->Add("$args{TrainingDir}/$file" => "");
    }
  }
  if ($args{Force} or
      $self->TestingSet->IsEmpty and
      $args{TestingDir} and
      -d $args{TestingDir}) { 
    $self->TestingDir($args{TestingDir});
    foreach my $file (split /\n/,`ls $args{TestingDir}`) {
      $self->TestingSet->Add("$args{TestingDir}/$file" => "");
    }
  }
}

sub TrainTestExtractor {
  my ($self,%args) = @_;
  return unless -d $args{LabelledDir} and $args{Span};
  my @a;
  push @a, "-labels", $args{LabelledDir};
  push @a, "-spanType", $args{Span};
  my $c = "java -Xmx1500m edu.cmu.minorthird.ui.TrainTestExtractor ".join(" ",@a);
  print "$c\n";
  system $c;
}

sub LearnExtractor {
  my ($self,%args) = @_;
  return unless -d $args{LabelledDir} and $args{Span} and $args{Extractor};
  return if -f $args{Extractor};
  my @a;
  push @a, "-labels", $args{LabelledDir};
  push @a, "-spanType", $args{Span};
  push @a, "-saveAs", $args{Extractor};
  push @a, "-learner", shell_quote($args{Learner}) if $args{Learner};
  my $c = "java -Xmx1500m edu.cmu.minorthird.ui.TrainExtractor ".join(" ",@a);
  print "$c\n";
  system $c;
}

sub RunExtractorOnUnlabelledData {
  my ($self,%args) = @_;
  return unless -d $args{UnlabelledDir} and $args{Extractor};
  my @a;
  push @a, "-labels", $args{UnlabelledDir};
  push @a, "-loadFrom", $args{Extractor};
  if (! $args{Result}) {
    push @a, "-gui";
  } else {
    push @a, "-saveAs", $args{Result};
  }
  push @a, "-learner", shell_quote($args{Learner}) if $args{Learner};

  my $c = "java -Xmx1500m edu.cmu.minorthird.ui.ApplyAnnotator ".join(" ",@a);
  print "$c\n";
  system $c;

}

1;
