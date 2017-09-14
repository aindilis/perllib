package Capability::WebSearch::Method::WWWMechanizeFirefox;

use PerlLib::SwissArmyKnife;

use POSIX qw(floor);
use System::WWW::Firefox;
use URL::Encode qw(url_encode);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Firefox Method SearchEngine /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Method($args{Method} || 'Normal');
  $self->SearchEngine($args{SearchEngine} || 'Google');
  $self->Firefox
    (System::WWW::Firefox->new
     (
      Method => $self->Method,
      ViewHeadless => $args{ViewHeadless} || 0,
     ));
}

sub StartServer {
  my ($self,%args) = @_;
  # $self->Firefox->StartServer;
}

sub StartClient {
  my ($self,%args) = @_;

}

sub WebSearch {
  my ($self,%args) = @_;
  my $octets = url_encode($args{Search});

  # probably want to do things to increase the number of results
  # returned, page through as needed etc.

  # maybe can do this with a tor browser bundle.

  my $url;
  my $results;
  if ($self->SearchEngine eq 'DuckDuckGo') {
    $url = "https://duckduckgo.com/?q=$octets";
    print "URL: $url\n";
    my $res1 = $self->Firefox->MyFirefox->get($url);
    sleep 10;
    # my $l = $self->Firefox->MyFirefox->xpath("//a[\@class='result--more__btn']", single => 1);
    # my $l = $self->Firefox->MyFirefox->xpath("//input[\@value='Upload'][@type='button']", single => 1);
    if ($args{NumberOfResults}) {
      my $j = floor($args{NumberOfResults} / 30);
      for (my $i = 1; $i <= $j; ++$i) {
	print $i."\n";
	my $l = $self->Firefox->MyFirefox->xpath("//div[\@id='rld-$i']/a", single => 1);
	$self->Firefox->MyFirefox->click( $l );
	my $c = $self->Firefox->Content();
	last if $c =~ /No more results\./;
	sleep 3;
      }
    }
    my $res2 = $self->Firefox->MyFirefox->content(%{$args{ContentArgs}});
    $results =
      {
       Success => 1,
       Res1 => $res1,
       Res2 => $res2,
       NumberOfResults => $args{NumberOfResults},
      };
  } elsif ($self->SearchEngine eq 'Google') {
    $url = "https://www.google.com/#safe=active\&q=$octets\&\*";
    print "URL: $url\n";
    $results = $self->Firefox->GetContent
      (
       URL => $url,
       ContentArgs => $args{ContentArgs},
      );
  }
  # print Dumper({MyResults => $results});
  return $self->ParseResults(Results => $results);
}

sub ParseResults {
  my ($self,%args) = @_;
  if ($self->SearchEngine eq 'DuckDuckGo') {
    return $self->ParseDuckDuckGoResults(Results => $args{Results});
  } elsif ($self->SearchEngine eq 'Google') {
    return $self->ParseGoogleResults(Results => $args{Results});
  }
}

sub ParseDuckDuckGoResults {
  my ($self,%args) = @_;
  my @results;
  my @tmpresults;
  if ($args{Results}{Success}) {
    my $html = $args{Results}{Res2};
    # # save this here
    # print "######################\n";
    # print $html."\n";
    # print "######################\n";
    my @res1 = $html =~ /<div data-nir=(.*?)<\/div><\/div><\/div>/sg;
    foreach my $res2 (@res1) {
      my $hash = {};
      if ($res2 =~ /\<a href=\"([^"]+?)\" rel/sm) {
	$hash->{url} = $1;
      }
      if ($res2 =~ /class="result__a">(.+?)<\/a>/sm) {
      	$hash->{title} = $1;
      }
      if ($res2 =~ /<div class="result__snippet([^"]*)">(.+?)<\/div>/sm) {
      	$hash->{content} = $2;
      }
      push @tmpresults, $hash;
    }
  }
  if ($args{Results}{NumberOfResults}) {
    @results = splice(@tmpresults,0,$args{Results}{NumberOfResults});
  } else {
    @results = @tmpresults;
  }
  return \@results;
}

sub ParseGoogleResults {
  my ($self,%args) = @_;
  my @results;
  if ($args{Results}{Success}) {
    my $html = $args{Results}{Res2};
    # my @res1 = $html =~ /<div data-nir=(.*?)<\/div><\/div><\/div>/sg;
    # foreach my $res2 (@res1) {
    #   my $hash = {};
    #   if ($res2 =~ /\<a href=\"([^"]+?)\" rel/sm) {
    # 	$hash->{url} = $1;
    #   }
    #   if ($res2 =~ /class="result__a">(.+?)<\/a>/sm) {
    #   	$hash->{title} = $1;
    #   }
    #   if ($res2 =~ /<div class="result__snippet">(.+?)<\/div>/sm) {
    #   	$hash->{content} = $1;
    #   }
    #   push @results, $hash;
    # }
  }
  return \@results;
}

1;
