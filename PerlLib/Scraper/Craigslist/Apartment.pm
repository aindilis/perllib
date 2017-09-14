package PerlLib::Scraper::Craigslist::Apartment;

use Manager::Dialog qw (Message Choose SubsetSelect);
use PerlLib::Collection;

use Data::Dumper;
use WWW::Mechanize;
use WWW::Mechanize::Link;
use URI::http;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [
   qw / MyPositions Loaded CraigsListURL Mech Cities Categories /
  ];

# system responsible for scraping jobs and resumes off online sites

sub init {
  my ($self,%args) = (shift,@_);
  $self->Mech(WWW::Mechanize->new);
  $self->CraigsListURL("http://www.craigslist.org/");
  $self->Cities({});
  $self->Categories({});
  $self->MyPositions
    (PerlLib::Collection->new
     (StorageFile => $args{StorageFile} || "data/source/CraigsList/.jobsearch",
      Type => "JS::Position"));
  $self->MyPositions->Contents({});
  $self->Loaded(0);
}

sub UpdateSource {
  my ($self,%args) = (shift,@_);
  Message(Message => "Updating source: CraigsList");
  $self->ExtractApartments;
  $self->MyPositions->Save;
}

sub LoadSource {
  my ($self,%args) = (shift,@_);
}

sub ExtractApartments {
  my ($self,%args) = (shift,@_);
  $self->Mech->get($self->CraigsListURL);
  $self->LoadCityNames;
  my @cities = SubsetSelect(Set => [sort keys %{$self->Cities}],
			    Selection => {});
  my $samplecity = $cities[0];
  $self->Mech->get($self->Cities->{$samplecity});
  $self->LoadCategories;
  my @categories = SubsetSelect(Set => [sort keys %{$self->Categories}],
				Selection => {});
  my @urls;
  foreach my $city (@cities) {
    foreach my $category (@categories) {
      my $catloc = $self->Categories->{$category};
      push @urls, "http://$city.craigslist.org/$catloc/";
    }
  }
  print Dumper(@urls);
  foreach my $url (@urls) {
    $self->Mech->get($url);
    my $dir = "data/source/CraigsList/";
    my @links = $self->Mech->find_all_links(url_regex => qr/\/\w{3}\/[0-9]{5,}.html/);
    print Dumper(\@links);
    foreach my $link (@links) {
      my $url = $link->URI->abs->as_string;
      my $c = "wget -N -P \"$dir\" -xN \"$url\"";
      `$c`;
      my $hf = $url;
      $hf =~ s/^http:\/\/(\w+)/$1/;
      my $city = $1;
      $hf = "data/source/CraigsList/".$hf;
      my $id = $hf;
      $id =~ s/.*\/(\w{3})\/([0-9]{5,}).html/$1-$2/;
      $id = $city."-".$id;
    }
  }
}

sub LoadCityNames {
  my ($self,%args) = (shift,@_);
  my $c = $self->Mech->content();
  foreach my $city ($c =~ /.*?(\w+).craigslist.org/g) {
    $self->Cities->{$city} = "http://$city.craigslist.org";
  }
}

sub LoadCategories {
  my ($self,%args) = (shift,@_);
  my $c = $self->Mech->content();
  if ($c =~ /.*\>housing\<\/a\>(.*?)\<\/td\>/s) {
    foreach my $l (grep /href/, split /\n/, $1) {
      if ($l =~ /\<a href=\"([^\"]+)\"\>([^<]+)\</) {
	my $name = $2;
	my $url = $1;
	$name =~ s/\&nbsp;/ /g;
	$name =~ s/\s+/ /g;
	$url =~ s/\/$//;
	$self->Categories->{$name} = $url;
      }
    }
  }
}

1;
