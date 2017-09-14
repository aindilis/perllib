package Capability::WebSearch::API::Rival::Yahoo::Search::AsList;

use PerlLib::SwissArmyKnife;
use Rival::Yahoo::Search::Result;

use WebService::Yahoo::BOSS::Response::Web;
# see Rival::Yahoo::Search;

my %args = ();
my $boss;

sub Results {
  my ($class, %args) = @_;
  my $i = 1;
  my @list;
  # WebService::Yahoo::BOSS
  my $date = `date "+%Y/%m/%d"`;
  foreach my $url (@{$args{URLList}}) {
    my $dispurl = $url;
    $dispurl =~ s/^(.+?)\:\/\///;
    my $result = WebService::Yahoo::BOSS::Response::Web->new
	(
	 clickurl => $url,
	 abstract => '',
	 title => '',
	 url => $url,
	 date => $date,
	 dispurl => $dispurl,
	);
    push @list, Rival::Yahoo::Search::Result->new
      (
       result => $result,
       I => $i++,
      );
  }
  return @list;
}

1;
