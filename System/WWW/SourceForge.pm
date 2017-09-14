package System::WWW::SourceForge;

use Manager::Dialog qw (Message Choose ApproveCommands SubsetSelect QueryUser);
use MyFRDCSA qw ( Dir ConcatDir );
use Packager::Rename qw (Normalize);

use Data::Dumper;
use WWW::Mechanize;

use vars qw($VERSION);
use strict;
use Carp;

$VERSION = '1.00';

use Class::MethodMaker new_with_init => 'new',
  get_set => [ qw / Items Mech FRDCSAHome / ];

sub init {
  my ($self,%args) = (shift,@_);
  $self->Items($args{Items} || []);
  $self->FRDCSAHome(MyFRDCSA::Dir("home"));
}

sub PossibleMatches {
  my ($self,%args) = (shift,@_);
  # determine whether this looks to be here, return a list of probable matches
  my $query = $args{Query};
  if ($self->Mech->get( "http://sourceforge.net/projects/$query/")) {
    return [$query];
  } else {
    return [];
  }
}

sub AddItems {
  my ($self,%args) = (shift,@_);
  $self->Items($args{Items});
  # push @{$self->Items}, @{$args{Items}};
}

sub Execute {
  my ($self,%args) = (shift,@_);
  $self->Mech(WWW::Mechanize->new());
  foreach my $item (@{$self->Items}) {
    $self->RetrieveSoftware($item);
  }
}

sub RetrieveSoftware {
  my ($self,$projectname) = (shift,lc(shift));
  my $mech = $self->Mech;
  if ($projectname) {
    $mech->get( "http://sourceforge.net/projects/$projectname" );

    # go to files list
    $mech->follow_link( text_regex => qr/files/i,
			n => 1);
    my (@matches,@allfiles);
    foreach my $link ($mech->links()) {
      if ($link->[0] =~ /\?download$/) {
	push @matches, $link->[0];
      }
    }

    # estimate what are the new releases
    # call each filename with the function that parses out names and versions
    # foreach unique name select the greatest version
    my $nameversion = {};
    my $possible = {};
    my $selection = {};
    foreach my $match (@matches) {
      if ($match =~ /^http:\/\/prdownloads.sourceforge.net\/[^\/]+\/(.*?)\?download$/) {
	my $filename = $1;
	push @allfiles, $filename;
	my ($name,$version,$filetype) = RADAR::Method::CodeBase::GetVersion($filename);
	# print "<$name><$version><$filetype>\n";
	if ($version) {
	  $nameversion->{$name}->{$version} = $filename;
	  if (! defined $nameversion->{$name}->{MAX}) {
	    $nameversion->{$name}->{MAX} = $version;
	  } else {
	    $nameversion->{$name}->{MAX} =
	      RADAR::Method::CodeBase::VersionGreater
		  ($nameversion->{$name}->{MAX},$version)
		    ? $nameversion->{$name}->{MAX} : $version;
	  }
	  $possible->{$filename} = [$name,$version];
	}
      } else {
	print "ERROR: $match\n";
      }
    }

    foreach my $name (keys %{$nameversion}) {
      $selection->{$nameversion->{$name}->{$nameversion->{$name}->{MAX}}} = 1;
    }

    # now select
    my @todownload = SubsetSelect(Set => \@allfiles, #[sort keys %{$possible}],
				  Selection => $selection);

    # choose a random mirror
    my @mirrors =
      map {"http://$_.dl.sourceforge.net/sourceforge"}
	qw(ovh jaist optusnet kent easynews puzzle nchc citkit switch
	   heanet mesh superb internap surfnet);
    my @failed = qw(keihanna); 
    my $mirror = $mirrors[int(rand(scalar @mirrors))];
    my @URIs = map "\"$mirror/$projectname/$_\"", @todownload;

    my $cb = RADAR::Method::CodeBase->new
      (Site => "http://sourceforge.net/projects/$projectname",
       URI => \@URIs);
    $cb->Execute;
  }
}

1;

