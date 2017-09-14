package PerlLib::Mechanize;

use Data::Dumper;
use KBFS::Cache;
use WWW::Mechanize;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Mech Cache /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Cache
    (KBFS::Cache->new
     (CacheType => "web",
      CacheDir => $args{CacheDir}));
  $self->Mech(WWW::Mechanize->new());
}

sub get {
  my ($self,$url) = (shift,shift);
  my $item = $self->Cache->Contains($url);
  if (! $item) {
    $self->Mech->get($url);
    $item = $self->Cache->CacheNewItem
      (URI => $url,
       Contents => $self->Mech->content);
    $self->Cache->ExportMetadata;
  } else {
    $self->Mech->get("file://".$item->Loc);
    $self->Mech->_parse_html();
  }
}

sub links {
  my ($self,%args) = @_;
  return $self->Mech->links;
}

sub content {
  my ($self,%args) = @_;
  return $self->Mech->content;
}

1;
