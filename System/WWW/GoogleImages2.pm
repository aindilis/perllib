package System::WWW::GoogleImages2;

use KBFS::Cache;

use Cache::FileCache;
use Data::Dumper;
use PerlLib::ParallelDownload;
use WWW::Mechanize::Cached;

# system to retrieve  images from google images, using  a local cache,
# with the possibility of selection, and a few other criteria

use Class::MethodMaker
  new_with_init => 'new',
  get_set =>
  [
   qw / Mech Cache CacheDir MyParallelDownloader /
  ];

sub init {
  my ($self,%args) = (shift,@_);

  my $cacheobj = new Cache::FileCache
    ({
      namespace => 'clear-visualizer',
      default_expires_in => "2 years",
      cache_root => "$UNIVERSAL::systemdir/data/FileCache",
     });

  $self->Mech
    (WWW::Mechanize::Cached->new
     (
      cache => $cacheobj,
      timeout => 15,
     ));

  $self->MyParallelDownloader
    (PerlLib::ParallelDownload->new);

  my $imagecachedir = "$UNIVERSAL::systemdir/data/imagecache";
  system "mkdir $imagecachedir" if ! -d $imagecachedir;
  $self->Cache
    (KBFS::Cache->new
     (CacheDir =>
      # "/var/lib/myfrdcsa/codebases/internal/silo/data/imagecache",
      "$imagecachedir",
      CacheType => "web"));

  if (! $self->Cache->ListContents) {
    $self->Cache->ExportMetadata;
  }
}

sub Search {
  my ($self,%args) = (shift,@_);
  my @terms = split /\s+/,$args{Search};
  my $query = join("+",@terms);
  $query =~ s/[[:^ascii:]]/\+/g;

  my $url = "http://images.google.com/images\?q=$query\&hl=en\&btnG=Search+Images";
  $self->Mech->get($url);
  my @matches = map {$_->url_abs->[0]->as_string} $self->Mech->find_all_links
    (url_regex => qr/^\/imgres/);
  my @all;
  my @download;
  foreach my $match (@matches) {
    if ($match =~ /^http:\/\/images.google.com\/imgres\?imgurl=(.*)\&imgref/) {
      my $m = $1;
      $m =~ s/\%2520/ /g;
      if (! $self->Cache->Contains($m)) {
	my $item = $self->Cache->CacheNewItem
	  (
	   DoNotRetrieve => 1,
	   URI => $m,
	  );
	push @all, $item;
	push @downloads, {
			  Source => $item->URI,
			  Target => $item->Loc,
			 };
      } else {
	push @all, $self->Cache->URIHash->{$m};
      }
    }
  }
  $self->Cache->ExportMetadata;
  # now take these and do a parallel download using the technique from radar-web-search
  $self->MyParallelDownloader->Download
    (
     Downloads => \@downloads,
    );
  return @all;
}

1;
