package Rival::Yahoo::Search;

use Rival::Yahoo::Search::Result;

use WebService::Yahoo::BOSS;

use Data::Dumper;

my %args = ();
my $boss;

sub Results {
  my ($class, %args) = @_;
  unless (defined $boss) {
    $argsspec{ckey} ||= `cat /etc/myfrdcsa/config/yahoo-consumer-key`;
    chomp $argsspec{ckey};

    $argsspec{csecret} ||= `cat /etc/myfrdcsa/config/yahoo-consumer-secret`;
    chomp $argsspec{csecret};

    $boss = WebService::Yahoo::BOSS->new( ckey => $argsspec{ckey}, csecret => $argsspec{csecret} );
  }

  print Dumper($args{Doc});
  my $response = $boss->Web(
			    start => ($args{Start} || 0),
			    q => $args{Doc},
			    count => ($args{Count} || 50),
			   );
  my $i = 1;
  my @list;
  foreach my $result (@{$response->results()}) {
    push @list, Rival::Yahoo::Search::Result->new
      (
       result => $result,
       I => $i++,
      );
  }
  return @list;
}

1;
