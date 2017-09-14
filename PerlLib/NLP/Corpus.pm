package PerlLib::NLP::Corpus;

use PerlLib::Collection;
use PerlLib::NLP::Corpus::Document;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Documents FileNames /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Documents
    ($args{Documents} ||
     PerlLib::Collection->new
     (Type => "PerlLib::NLP::Corpus::Document"));
  if ($args{FileNames}) {
    $self->FileNames
      ($args{FileNames});
    $self->LoadFiles;
  }
}

sub AddFile {
  my ($self,%args) = @_;
  my $doc = PerlLib::NLP::Corpus::Document->new
    (ID => $args{ID} || $args{File},
     File => $args{File});
  $self->Documents->Add($doc->ID => $doc);
  return $doc;
}

sub AddContents {
  my ($self,%args) = @_;
  my $doc = PerlLib::NLP::Corpus::Document->new
    (ID => $args{ID} || ":".$self->Documents->Count,
     Contents => $args{Contents});
  $self->Documents->Add($doc->ID => $doc);
  return $doc;
}

sub LoadFiles {
  my ($self,%args) = @_;
  print "loading files\n";
  my @f;
  foreach my $file ($self->FileNames->Values) {
    if (-e $file and ! -d $file) {
      my $c = `cat "$file"`;
      my $doc = PerlLib::NLP::Corpus::Document->new
	(ID => $file,
	 File => $file,
	 Contents => $c);
      $self->Documents->Add($doc->ID => $doc);
    }
  }
}

1;
