package Rival::AI::Categorizer::Category;

use PerlLib::SwissArmyKnife;
use Rival::AI::Categorizer::_Util;

use MIME::Base64;

use Class::MethodMaker new_with_init => 'new',
  get_set => [ qw / Name Documents _Dir _DirName / ];

sub init {
  my ($self,%args) = @_;
  $self->Name($args{name});
  $self->Documents($args{_Documents} || []);
  my $dirname = encode_base64($self->Name);
  chomp $dirname;
  $dirname =~ s/\s+/_/sg;
  $self->_DirName($dirname);
  if (defined $args{_CategoriesDataLocation}) {
    $self->_Dir($args{_CategoriesDataLocation}."/$dirname");
  } else {
    $self->_Dir($UNIVERSAL::systemdir."/data/rival-categorizer/categories/".$dirname)
  }

  MkDirIfNotExists(Directory => $self->_Dir);
  foreach my $document (@{$self->Documents}) {
    $self->_LinkDocument(Document => $document);
  }
}

sub by_name {
  my ($self,%args) = @_;
  return Rival::AI::Categorizer::Category->new(%args);
}

sub add_document {
  my ($self,$doc) = @_;
  push @{$self->Documents}, $doc;
  $self->_LinkDocument(Document => $doc);
}

sub _LinkDocument {
  my ($self,%args) = @_;
  if (! -f $self->_Dir."/".$args{Document}->_FileNameShort) {
    DoCmd("ln -s \"".$args{Document}->_FileNameLong."\" ".$self->_Dir);
  }
}

1;
