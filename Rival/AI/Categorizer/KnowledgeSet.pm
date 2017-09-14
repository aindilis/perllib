package Rival::AI::Categorizer::KnowledgeSet;

use Rival::AI::Categorizer::_Util;

use Data::Dumper;

use Class::MethodMaker new_with_init => 'new',
  get_set => [ qw / Categories Documents _KnowledgeSetDataLocation / ];

sub init {
  my ($self,%args) = @_;
  $self->Categories($args{categories});
  $self->Documents($args{documents});
  $self->_KnowledgeSetDataLocation($args{_KnowledgeSetDataLocation} || $UNIVERSAL::systemdir."/data/rival-categorizer/knowledge-set");
  DoCmd("mkdir -p ".$self->_KnowledgeSetDataLocation);

  my $marked = {};
  foreach my $document (@{$self->Documents}) {
    $marked->{$document->_FileNameShort} = 1;
  }

  foreach my $category (@{$self->Categories}) {
    # print Dumper($category);
    DoCmd("mkdir ".$self->_KnowledgeSetDataLocation."/".$category->_DirName);

    foreach my $document (@{$category->Documents}) {
      if (exists $marked->{$document->_FileNameShort}) {
	# add this to the directory structure
	if (! -f $self->_KnowledgeSetDataLocation."/".$category->_DirName."/".$document->_FileNameShort) {
	  DoCmd("ln -s ".$category->_Dir."/".$document->_FileNameShort." ".$self->_KnowledgeSetDataLocation."/".$category->_DirName);
	}
      }
    }
  }
}

1;
