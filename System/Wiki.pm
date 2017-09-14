package System::Wiki;

use PerlLib::Collection;
use System::Wiki::Page;

# a system for maintaining wiki pages

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / StorageDir Repository WikiSite  /

  ];

sub init {
  my ($self,%args) = @_;
  $self->StorageDir($args{StorageDir} || "/tmp/wiki");
  $self->Repository
    (PerlLib::Collection->new
     (Type => "System::Wiki::Page",
      StorageFile => $self->StorageDir."/.pages.pl"));
}

sub AddWikiPage {
  my ($self,%args) = @_;
  my $page =  System::Wiki::Page->new
    ();
  $self->Repository->Add(Item => $page);
  $self->Repository->Save;
}

sub RemoveWikiPage {
  my ($self,%args) = @_;
  $self->Repository->SearchAndDestroy(Item => $args{Page});
  $self->Repository->Save;
}

sub SyncWikiPages {
  my ($self,%args) = @_;
  # check what files, if any, have been updated since last sync

  if (! $self->WikiSite) {
    # ask for credentials
  }
  # use mvs here to upload the contents of the pages
}

1;
