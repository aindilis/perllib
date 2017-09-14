package Rival::AI::Categorizer::Learner::NaiveBayes;

use Manager::Dialog qw(ApproveCommands);
use Rival::AI::Categorizer::_Util;

use MIME::Base64;

use Class::MethodMaker new_with_init => 'new',
  get_set => [ qw / / ];

sub init {
  my ($self,%args) = @_;
}

sub save_state {
  my ($self,$path) = @_;
  if (! $self->NoDifference(Path => $path)) {
    ApproveCommands
      (
       Commands => ["rm -rf \"".$path."\""],
       Method => "parallel",
      );
    DoCmd("cp -ar ~/.rainbow \"".$path."\"");
  }
}

sub restore_state {
  my ($self,$path) = @_;
  # first check whether the id for this state is the same as the ~/.rainbow
  if (! $self->NoDifference(Path => $path)) {
    ApproveCommands
      (
       Commands => ["rm -rf ~/.rainbow"],
       Method => "parallel",
      );
    DoCmd("cp -ar \"".$path."\" ~/.rainbow");
  }
  return Rival::AI::Categorizer::Learner::NaiveBayes->new();
}

sub NoDifference {
  my ($self,%args) = @_; 
  my $path = $args{Path}; 
  my $res = `diff "$path" ~/.rainbow/`;
  if ($res =~ /^$/) {
    return 1;
  }
  return 0;
}

sub train {
  my ($self,%args) = @_;
  DoCmd("rainbow -i ".$args{knowledge_set}->_KnowledgeSetDataLocation."/*");
}

sub categorize {
  my ($self,$document) = @_;
  my $file = $document->_FileNameLong;
  my $results = `rainbow --query=$file 2> /dev/null`;
  $results =~ s/.*^$//s;
  my %score;
  foreach my $line (split(/\n/,$results)) {
    if ($line ne "") {
      my @result = split(/ /,$line);
      my $base64 = $result[0];
      $base64 =~ s/_/\n/g;
      my $category = decode_base64($base64);
      $score{$category} = $result[1];
    }
  }
  return \%score;
}

1;
