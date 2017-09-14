package PerlLib::EasyPersist;

use MyFRDCSA qw(ConcatDir Dir);
# use PerlLib::Cacher;

use Cache::FileCache;
use Data::Dumper;
use Storable qw( freeze thaw );
# use WWW::Mechanize::Cached;

# maybe just use sayer or something

# the goal of this is to have an easy way to save data written
# immediately to a particular file and then reload after executions,
# etc

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / CacheObj Silent /

  ];

sub init {
  my ($self,%args) = @_;
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
  my $command = $args{Command};
  # first check if it's in the cache
  my $result = $self->CacheObj->get( $command );
  if ($args{Overwrite} or not defined $result) {
    # if it is not, run the command, store the results with the
    # expiration, and return the results
    print "Running command:\n";
    $result = eval $command;
    $self->CacheObj->set( $command, $result, $args{Expires} );
  } else {
    # if it is, return it, and maybe set it's renewal period to the
    # expiration, I'm not sure
    print "Retrieved result from cache for command:\n" unless $self->Silent;
    print $command."\n" unless $self->Silent;
  }
  return {
	  Success => 1,
	  Result => $result,
	 };
}

sub Remove {
  my ($self,%args) = @_;
  $self->CacheObj->remove($args{Key});
}

1;
