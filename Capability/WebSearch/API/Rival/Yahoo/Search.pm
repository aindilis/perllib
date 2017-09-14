package Capability::WebSearch::API::Rival::Yahoo::Search;

use Capability::WebSearch;
use PerlLib::SwissArmyKnife;
use Rival::Yahoo::Search::Result;

use WebService::Yahoo::BOSS::Response::Web;
# see Rival::Yahoo::Search;

my %args = ();
my $boss;

my $websearch = Capability::WebSearch->new
  (
   EngineName => 'DuckDuckGo',
   ViewHeadless => 1,
   Method => 'Normal',
  );

sub Results {
  my ($class, %args) = @_;

  # what to do with Start param?
  my $results = $websearch->WebSearch
    (
     Search => $args{Doc},
     NumberOfResults => $args{Count},
    );

  my $i = 1;
  my @list;
  # WebService::Yahoo::BOSS
  my $date = `date "+%Y/%m/%d"`;
  foreach my $entry (@$results) {
    my $dispurl = $entry->{url};
    $dispurl =~ s/^(.+?)\:\/\///;
    my $result = WebService::Yahoo::BOSS::Response::Web->new
	(
	 clickurl => $entry->{url},
	 abstract => $entry->{content},
	 title => $entry->{title},
	 url => $entry->{url},
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
