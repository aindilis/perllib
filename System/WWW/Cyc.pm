# package System::WWW::Cyc;

# use KBFS::Cache;

# use Cache::FileCache;
# use PerlLib::SwissArmyKnife;
# use WWW::Mechanize::Cached;

# use HTML::Form;

# # system to retrieve  images from google images, using  a local cache,
# # with the possibility of selection, and a few other criteria

# use Class::MethodMaker
#   new_with_init => 'new',
#   get_set =>
#   [
#    qw / Mech Cache CacheDir /
#   ];

# sub init {
#   my ($self,%args) = @_;
#   system "mkdir -p /tmp/system-www-cyc";
#   my $cacheobj = new Cache::FileCache
#     ({
#       namespace => 'system-www-cyc',
#       default_expires_in => "2 years",
#       cache_root => "/tmp/system-www-cyc",
#      });

#   $self->Mech
#     (WWW::Mechanize::Cached->new
#      (
#       cache => $cacheobj,
#       timeout => 15,
#      ));
# }

# sub SearchForConstant {
#   my ($self,%args) = @_;
#   $self->Mech->get('http://localhost:3602/cgi-bin/cyccgi/cg?cb-start');
#   print $self->Mech->content;
#   my @res = $self->Mech->forms();
#   print Dumper({Res => \@res});
# }

# 1;
