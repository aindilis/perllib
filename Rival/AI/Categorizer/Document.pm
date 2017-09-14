package Rival::AI::Categorizer::Document;

use PerlLib::SwissArmyKnife;
use Rival::AI::Categorizer::_Util;

use utf8;

use Digest::MD5 qw(md5 md5_hex md5_base64);
use IO::File;

use Class::MethodMaker new_with_init => 'new',
  get_set => [ qw / Name Content Categories _FileNameLong _FileNameShort / ];

sub init {
  my ($self,%args) = @_;
  $self->Name($args{name});
  $self->Content($args{content});
  $self->Categories($args{categories});
  my $dir = $args{_DocumentsDataLocation} || $UNIVERSAL::systemdir."/data/rival-categorizer/documents";

  MkDirIfNotExists(Directory => $dir);

  my $hashname = $self->_GetHashName(Content => $self->Content);
  $self->_FileNameShort($hashname.".txt");

  my $file = $dir."/".$self->_FileNameShort;

  $self->_FileNameLong($file);
  # write contents to the file
  if (! -f $self->_FileNameLong) {
    my $fh = IO::File->new;
    $fh->open(">".$self->_FileNameLong) or die "Cannot open file!: ".$self->_FileNameLong."\n";
    See({See => $self->Content}) if $args{Debug};
    print $fh $self->Content;
    $fh->close;
    DoCmd("konwert \"utf8-iso1\" ".$self->_FileNameLong." > /tmp/temp");
    DoCmd("mv /tmp/temp ".$self->_FileNameLong);
  }
  # foreach  my $category (@{$self->Categories}) {
  # $category->add_document
  # }
}

sub _GetHashName {
  my ($self,%args) = (shift,@_);
  return md5_hex($args{Content});
}

1;
