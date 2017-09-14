package PerlLib::Geo;

use Manager::Dialog qw (QueryUser Choose);
use Data::Dumper;

use DBI;
use Geo::Distance;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [ qw
    / LatLongFile RoadNameHash LocationHash MyGeo StopNameHashFile DBH
    / ];

sub init {
  my ($self,%args) = @_;
  $self->MyGeo(Geo::Distance->new);
  $self->MyGeo->formula('hsin');
  $self->RoadNameHash({});
  $self->LocationHash({});
  $self->LoadTigerData;
}

sub LoadTigerData {
  my ($self,%args) = @_;
  my $number = "17031";
  my ($regex,$cnt) = $self->GenRegex();
  # print "$regex\n$cnt\n";
  print "Loading Tiger Route data\n";
  my $tigerdatadir = "data/TIGER/chicago";
  foreach my $l (split /\n/, `cat $tigerdatadir/TGR$number.RT1`) {
    if ($l =~ /$regex/) {

      my $roadname = $4;
      if ($roadname) {
	$roadname =~ s/^\s*//;
	$roadname =~ s/\s*$//;
      }

      my $s1 = $13;
      if ($s1) {
	$s1 =~ s/^\s*//;
	$s1 =~ s/\s*$//;
      }

      my $s2 = $14;
      if ($s2) {
	$s2 =~ s/^\s*//;
	$s2 =~ s/\s*$//;
      }

      if (! exists $self->RoadNameHash->{$roadname}) {
	$self->RoadNameHash->{$roadname} = {};
      }
      $self->RoadNameHash->{$roadname}->{$s1} = 1;
      $self->RoadNameHash->{$roadname}->{$s2} = 1;
    }
  }
  print "Done\n";
}

sub GetStreetname {
  my ($self,$retval) = (shift,shift);
  # attempt to find matching keys
  my @matches;
  foreach my $key (keys %{$self->RoadNameHash}) {
    # print "<$key>\n";
    if ($key =~ /^$retval$/i) {
      return $key;
    } elsif ($key =~ /$retval/i) {
      push @matches, $key;
    }
  }
  if (scalar @matches == 0) {
    return "";
  } elsif (scalar @matches == 1) {
    my $streetname = Choose(@matches);
    if (! $streetname) {
      print "";
    } else {
      return $streetname;
    }
  } else {
    return "";
  }
}

sub LookupStreetLocation {
  my ($self,%args) = @_;
  my $s1 = $args{Street1};
  my $s2 = $args{Street2};
  $s1 = $self->GetStreetname($s1);
  my $matches = {};
  if ($s1) {
    $s2 = $self->GetStreetname($s2);
    if ($s2) {
      # now attempt to find a shared latlong data point for these two
      foreach my $latlong (keys %{$self->RoadNameHash->{$s1}}) {
	if (exists $self->RoadNameHash->{$s2}->{$latlong}) {
	  # -79912672+40446768
	  # to this:
	  # -79.912672, +40.446768
	  $latlong =~ s/(.{3})(.{6})(.{3})(.{6})/$1.$2, $3.$4/;
	  $matches->{$latlong} = 1;
	}
      }
    }
  }
  if (scalar keys %$matches) {
    foreach my $key (keys %$matches) {
      $self->LocationHash->{"$s1 at $s2"} = $key;
    }
  } else {
    $self->LocationHash->{"$s1 at $s2"} = "unknown";
  }
  return $self->LocationHash->{"$s1 at $s2"};
}

sub CalculateDistanceBetweenLatLongs {
  my ($self,%args) = @_;
  my $ll1 = $args{LatLong1};
  my $ll2 = $args{LatLong2};
  $ll1 =~ /(.*), (.*)/;
  my ($a,$b) = ($1,$2);
  $ll2 =~ /(.*), (.*)/;
  my ($c,$d) = ($1,$2);
  if ($args{Type} eq "streetwise") {
    # x1,y1 to x2,y2 = x1,y1 to x1,y2 + x1,y2 to x2,y2
    return $self->MyGeo->distance("mile", $a,$b => $c,$b) +
      $self->MyGeo->distance("mile", $c,$b => $c,$d);
  } else {
    return $self->MyGeo->distance("mile", $a,$b => $c,$d);
  }
}

sub GetDistanceBetween {
  my ($self,%args) = @_;
  my $s = $args{StartLoc};
  my $e = $args{EndLoc};
  # get the starting address geo coordinates
  my $l1 = $self->GetLatLongForAddress($s);
  my $l2 = $self->GetLatLongForAddress($s);
  $self->CalculateDistanceBetweenLatLongs
    (
     Type => $args{Type} || "shortest",
     LatLong1 => $l1,
     LatLong2 => $l2,
    );
}

sub GetLatLongForAddress {
  my ($self,$address) = @_;
  return unless $address;

  # print "look up <$s>\n";
  # strip s of all its undesirea

  # get rid of additional
  $address =~ s/ at (North|South|East|West)$/ at SPECIAL1/ig;
  $address =~ s/North Ave(nue)?/SPECIAL1/ig;

  $address =~ s/ at (.+) and (.+)$/$1 at $2/;
  $address =~ s/(\/| and )\w+$//;

  $address =~ s/\./ /g;

  # remove common lint
  $address =~ s/\s*\b([nsew]|west|north|south|east|avenue|ave|st|street|blvd|drive|dr|court|ct|place|pl)\.?\b\s*/ /ig;

  # remove prefixed street address
  $address =~ s/^[\d]+ //;

  $address =~ s/^\s+//g;
  $address =~ s/\s+$//g;
  $address =~ s/\s{2,}/ /g;

  $address =~ s/SPECIAL1/North/g;

  # remove
  print $address."\n";
  if ($address =~ /^(.*) at (.*)$/) {
    my ($s1,$s2) = (lc($1),lc($2));
    $s2 =~ s/\s+//;
    # print "\t\t<$s1>at<$s2>\n";
    return $self->LookupStreetLocation
      (
       Street1 => $s1,
       Street2 => $s2,
      );
  } else {
    return "unknown";
  }
}

sub GenRegex {
  my ($self,%args) = @_;
  my $sample = "10604  #51671428 #A  #Steiner                       #Ave".
    "   #A41       #2201       #2299       #2200       #229800001512215122".
      "              #42420030038351283512          #8351283512488400488400".
	"10051004 #-79865570+40371569 #-79865970+40371069";
  my $regex;
  my @items = split /\#/,$sample;
  foreach my $e (@items) {
    $regex .= "(.{".length($e)."})";
  }
  return ($regex,scalar @items);
}

1;
