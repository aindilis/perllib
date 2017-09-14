package System::WWW::Firefox::Cached;

use PerlLib::SwissArmyKnife;
use System::WWW::Firefox;

# use PerlLib::EasyPersist;
# use PerlLib::Cacher;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyFirefox /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyFirefox(WWW::Mechanize::Firefox->new(%args));
  my $cacheobj = new Cache::FileCache
    ({
      namespace => $args{Namespace} || "default",
      default_expires_in => $args{Expires} || "2 years",
      cache_root => $args{CacheRoot} ||
      ConcatDir(Dir("internal codebases"),"perllib/data/modules/PerlLib/EasyPersist/Cache"),
     });
  $self->CacheObj($cacheobj);
  $self->Silent($args{Silent});
}

sub Get {
  my ($self,%args) = @_;
  my $url = $args{URL};
  # first check if it's in the cache
  my $result = $self->CacheObj->get( $url );
  if ($args{Overwrite} or not defined $result) {
    # if it is not, run the command, store the results with the
    # expiration, and return the results
    print "Running command:\n";
    $self->MyFirefox->get($args{URL});
    my $result = $self->MyFirefox->content;
    $self->CacheObj->set( $url, $result, $args{Expires} );
  } else {
    # $self->MyFirefox->get($args{URL});
    # if it is, return it, and maybe set it's renewal period to the
    # expiration, I'm not sure
    print "Retrieved result from cache for command:\n" unless $self->Silent;
    print $url."\n" unless $self->Silent;
  }
  return {
	  Success => 1,
	  Result => $result,
	 };
}

sub GetContent {
  my ($self,%args) = @_;
  my $res1 = $self->Get(URL => $args{URL});
  my $retval =
    {
     Success => 1,
     Res1 => $res1,
    };
  return $retval;
}

sub Remove {
  my ($self,%args) = @_;
  $self->CacheObj->remove($args{Key});
}

# FIXME: have this use inheritance instead of wrapping these functions
# this way

sub HasProcess {
  my ($self,%args) = @_;
  $self->MyFirefox->HasProcess(%args);
}

sub IsRunningP {
  my ($self,%args) = @_;
  $self->MyFirefox->IsRunningP(%args);
}

sub StartServer {
  my ($self,%args) = @_;
  $self->MyFirefox->StartServer(%args);
}

sub ServerRunningP {
  my ($self,%args) = @_;
  $self->MyFirefox->ServerRunningP(%args);
}

sub StartClient {
  my ($self,%args) = @_;
  $self->MyFirefox->StartClient(%args);
}

1;
