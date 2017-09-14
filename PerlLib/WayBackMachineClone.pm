package PerlLib::WayBackMachineClone;

use Cache::FileCache;
use PerlLib::ToText;
use PerlLib::SwissArmyKnife;

use CHI;
use Data::Dumper;
use Rival::WWW::Mechanize::Cached::Multiple;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / CacheRoot CacheObj Cacher MyToText /

  ];

sub init {
  my ($self,%args) = @_;
  my $cacheroot = $args{CacheRoot} || "/var/lib/myfrdcsa/codebases/internal/perllib/data/modules/PerlLib/WayBackMachineClone/FileCache";
  $self->CacheRoot($cacheroot);
  MkdirP($cacheroot);
  my $cacheobj = CHI->new
    (
     driver   => 'File',
     root_dir => $cacheroot,
     expires_in => 'never',
     namespace => 'rival-www-mechanize-cached-special',
    );
  $self->CacheObj($cacheobj);
  my $cacher = Rival::WWW::Mechanize::Cached::Multiple->new
    (
     cache => $cacheobj,
     timeout => $args{TimeOut} || 15,
    );
  $self->Cacher
    ($cacher);
}

sub get {
  my ($self,$url) = @_;
  return $self->Cacher->get($url);
}

sub delete {
  my ($self,$url) = @_;
  my @matches;
  foreach my $key ($self->CacheObj->get_keys()) {
    my @items = split /[\r\n]+/, $key;
    if ($items[0] eq "GET $url") {
      push @matches, $key;
    }
  }
  my $count = scalar @matches;
  if ($count == 1) {
    $self->CacheObj->remove($matches[0]) or print "cannot remove $!";
  } else {
    print "Different count that 1 ($count)\n";
    if (scalar @matches > 5) {
      print "Not removing as count > 5.\n";
    } else {
      foreach my $match (@matches) {
	$self->CacheObj->remove($match) or print "cannot remove $!";
      }
    }
  }
}

sub content {
  my ($self,$url) = @_;
  return $self->Cacher->content;
}

sub links {
  my ($self,%args) = @_;
  return $self->Cacher->links;
}

sub follow_link {
  my ($self,%args) = @_;
  return $self->Cacher->follow_link
    (%args);
}

sub is_cached {
  my ($self,%args) = @_;
  return $self->Cacher->is_cached();
}


sub ToText {
  my ($self,%args) = @_;
  if (! $self->MyToText) {
    $self->MyToText
      (PerlLib::ToText->new
       ());
  }
  return $self->MyToText->ToText
    (String => $self->Cacher->content);
}

1;
