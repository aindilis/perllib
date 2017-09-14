package Capability::TextClassification::Advanced;

use Capability::TextClassification::Advanced::Markup;
use MyFRDCSA;
use Rival::AI::Categorizer;
use Rival::AI::Categorizer::Category;
use Rival::AI::Categorizer::Document;
use Rival::AI::Categorizer::KnowledgeSet;
use Rival::AI::Categorizer::Learner::NaiveBayes;
use Rival::AI::Categorizer::Learner::SVM;

use Data::Dumper;
use IO::File;
use MD5;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyMarkup Learner Retrain MyLearner NeedsTraining Categories
   TrainSet TestSet StatePath MyKnowledgeSet ModelName SystemDir /

  ];

sub init {
  my ($self,%args) = @_;
  $self->ModelName($args{ModelName} || "model");
  $self->Categories({});
  $self->TrainSet([]);
  $self->TestSet([]);
  $self->SystemDir("/var/lib/myfrdcsa/codebases/minor/list-of-lists");
  $self->StatePath
    ($args{StatePath} || ConcatDir($self->SystemDir,"data/classification",$self->ModelName));
  if (-d $self->StatePath) {
    $self->NeedsTraining(0);
  } else {
    $self->NeedsTraining(1);
  }
}

sub StartServer {
  my ($self,%args) = @_;
  $self->Retrain
    ($args{Retrain} || 0);
  print Dumper($retrain);
  $self->Learner
    ($args{Learner} || "NaiveBayes");
  print "Starting Advanced Text Classification Server\n";
  # load the markup
  if (defined $self->Learner) {
    if ($self->Learner eq "SVM") {
      if (-d $self->StatePath and ! $self->Retrain) {
	print "Restoring state\n";
	$self->MyLearner(Rival::AI::Categorizer::Learner::SVM->restore_state($self->StatePath));
      } else {
	$self->MyLearner(Rival::AI::Categorizer::Learner::SVM->new());
      }
    } elsif ($self->Learner eq "NaiveBayes") {
      if (-d $self->StatePath and ! $self->Retrain) {
	print "Restoring state\n";
	$self->MyLearner(Rival::AI::Categorizer::Learner::NaiveBayes->restore_state($self->StatePath));
      } else {
	$self->MyLearner(Rival::AI::Categorizer::Learner::NaiveBayes->new());
      }
    } else {
      die "Learner ".$self->Learner." not found\n";
    }
  }
  $self->MyMarkup
    (Capability::TextClassification::Advanced::Markup->new
     (DBName => $args{DBName}));
}

sub StartClient {
  my ($self,%args) = @_;

}

sub AddInstance {
  my ($self,%args) = @_;
  # first handle the classes
  my @categories;
  foreach my $categoryname (keys %{$args{Classes}}) {
    if (! exists $self->Categories->{$categoryname}) {
      my $cat = Rival::AI::Categorizer::Category->by_name(name => $categoryname);
      $self->Categories->{$categoryname} = $cat;
    }
    push @categories, $self->Categories->{$categoryname};
  }

  # add the features to the text and train using the regular text classifier
  # possibly do some analysis of the classes themselves
  my $res = $self->MyMarkup->Markup
    (Text => $args{Text});

  my $contents = $res->{TextWithFeaturesAdded};

  if ($args{TestSet}) {
    my $d = Rival::AI::Categorizer::Document->new
      (
       name => $self->GetUniqueName(Contents => $contents),
       content => $contents,
      );
    push @{$self->TestSet}, $d;
  } else {
    my $d = Rival::AI::Categorizer::Document->new
      (
       name => $self->GetUniqueName(Contents => $contents),
       content => $contents,
       categories => \@categories,
      );
    foreach my $c (@categories) {
      if (UNIVERSAL::isa($c,'Rival::AI::Categorizer::Category')) {
	$c->add_document($d);
	if (UNIVERSAL::isa($d,'Rival::AI::Categorizer::Document')) {
	  push @{$self->TrainSet}, $d;
	}
      } else {
	print "ERROR, not a class\n";
	print Dumper($c);
      }
    }
  }
}

sub GetUniqueName {
  my ($self,%args) = @_;
  return join("::",time(),MD5->hexhash($args{Contents},rand(10000)));
}

sub Train {
  my ($self,%args) = @_;
  ## return unless $self->NeedsTraining;

  # create a knowledge set
  my $k = new Rival::AI::Categorizer::KnowledgeSet
    (
     categories => [values %{$self->Categories}],
     documents => $self->TrainSet,
    );

  $self->MyKnowledgeSet($k);

  print "Training, this could take some time...\n";
  $self->MyLearner->train(knowledge_set => $self->MyKnowledgeSet);
  $self->MyLearner->save_state($self->StatePath) if $self->StatePath;
}

sub TrainTest {
  my ($self,%args) = @_;
  print "Not yet implemented\n";
}

sub Classify {
  my ($self,%args) = @_;
  print Dumper(%args);
  my $res = $self->MyMarkup->Markup(Text => $args{Text});
  my $d = Rival::AI::Categorizer::Document->new
    (
     name => "target",
     content =>   $res->{TextWithFeaturesAdded},
     _DocumentsDataLocation => $self->SystemDir."/data/rival-categorizer/documents",
    );
  # print Dumper($d);
  return $self->MyLearner->categorize($d);
}

1;
