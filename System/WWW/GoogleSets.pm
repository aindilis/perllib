package System::WWW::GoogleSets;
use strict;
use warnings;
use CGI;
use LWP;

use PerlLib::Collection;

use Data::Dumper;

use Cache::FileCache;
use WWW::Mechanize::Cached;

require Exporter;
use vars qw(@EXPORT @EXPORT_OK @ISA $VERSION);

#--------------------------------#

@ISA = qw(Exporter);
@EXPORT = qw(get_gset);

# do this or EXPORT as there are only two functions?
@EXPORT_OK = qw( get_small_gset get_large_gset );

$VERSION = '0.01';

# remove once checked in to svn.
#%EXPORT_TAGS = (
#  all => [ @EXPORT_OK ],
#  small_set => [ 'get_gset' ],
#  large_set => [ 'get_large_gset' ],
#);

# alias get_gset to the more common case.
sub get_gset; # quiet warnings;
*get_gset = \&get_small_gset;

=head1 FUNCTIONS

By default this module exports get_gset.

=over 4

=item get_gset

A utility alias for get_small_gset.

Exported by default.

=item get_small_gset

This function takes an array of terms to expand and attempts to expand them
using the Google Sets website.

It returns undef on failure to connect to the remote server and an array
reference pointing to the expanded list on success.

=cut

sub get_small_gset {
  _get_google_set("small", @_);
}

#--------------------------------#

=item get_large_gset

This function takes an array of terms to expand and attempts to expand them
using the Google Sets website. It returns a larger list than get_small_gset
or get_gset.

This function must be explictly imported.

  use WebService::Google::Sets qw(get_large_gset);

It returns undef on failure to connect to the remote server and an array
reference pointing to the expanded list on success.

=back

=cut

sub get_large_gset {
  _get_google_set("large", @_);
}

#--------------------------------#

sub _get_google_set {
  my $set_size = shift;
  my @words = @_;
  my @expanded_set;

  my $base_url = 'http://labs.google.com/sets?hl=en&';
  my $sets_url;			# this gets built and then escaped

  my $offset;
  for my $word (@words) {
    $offset++;
    $sets_url .= qq{q$offset=$word&};
  }

  # get the set size
  if ($set_size eq "large") {
    $sets_url .= 'btn=Large+Set';
  } else {
    $sets_url .= 'btn=Small+Set+items+or+fewer';
  }

  # encode the query string
  # my $q = new CGI($sets_url);
  # my $escaped_url = $q->query_string;
  my $escaped_url = $sets_url;

  # my $browser = LWP::UserAgent->new();
  # my $response = $browser->get("$base_url$escaped_url");

  my $cacheobj = new Cache::FileCache
    ({
      namespace => 'google-sets',
      default_expires_in => "1 year",
      cache_root => "/var/lib/myfrdcsa/codebases/internal/perllib/data/google-sets/FileCache",
     });
  my $cacher = WWW::Mechanize::Cached->new
    (
     cache => $cacheobj,
     timeout => 30,
    );

  $cacher->get("$base_url$escaped_url");

  my $content = $cacher->content;

  my @res = $content =~ /<center>(.+?)<\/center>/sg;
  foreach my $item (@res) {
    if ($item =~ /<font face="Arial, sans-serif" size=-1><a href="http:\/\/www.google.com\/search\?hl=en&amp;q=(.+?)">(.+?)<\/a><\/font>/) {
      push @expanded_set, $2;
    }
  }

  return \@expanded_set;
}

#--------------------------------#

1;

=head1 COMMAND LINE PROGRAM

A very simple script called F<get_gset> is supplied in the
distribution's F<bin> folder. It accepts between one and five values and
then attempts to expand them.

=head1 DEPENDENCIES

WebService::Google::Sets requires the following modules:

CGI

LWP

=head1 LICENCE AND COPYRIGHT

Copyright (C) 2006 Dean Wilson.  All Rights Reserved.

This module is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 AUTHOR

Dean Wilson <dean.wilson@gmail.com>

=cut
