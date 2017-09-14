package System::WWW::Firefox;

use PerlLib::SwissArmyKnife;
use PerlLib::Util::Misc;
use System::Xvfb;
use WWW::Mechanize::Firefox;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyFirefox Method Headless ViewHeadless MyXvfb Display Debug
   Verbose /

  ];

sub init {
  my ($self,%args) = @_;

  $self->Method($args{Method} || 'Tor');
  $self->Headless($args{Headless} || 1);
  $self->ViewHeadless($args{ViewHeadless} || 0);
  $self->Display($args{Display} || ':1');
  $self->Verbose(1);

  $self->StartServer();
  $self->MyFirefox
    (WWW::Mechanize::Firefox->new
     (
      tab => 'current',
     ));
  print "Done Initializing System::WWW::Firefox\n";
}

sub MyIsRunningP {
  my ($self,%args) = @_;
  print "Checking whether the system <$args{System}> is running\n";
  if ($args{System} eq 'Firefox') {
    my $count;
    if ($self->Method eq 'Tor') {
      print "Checking Tor\n";
      return IsRunningP(Search => 'Tor Browser')
    } elsif ($self->Method eq 'Normal') {
      print "Checking Firefox\n";
      return IsRunningP(Command => "ps auxwww | grep -E 'firefox-esr -P WWW_Mechanize_Firefox -repl' | grep -v grep | grep firefox | wc -l");
    }
  } elsif ($args{System} eq 'Xvfb') {
    return IsRunningP(Search => 'Xvfb')
  }
}

sub StartServer {
  my ($self,%args) = @_;
  print "Start Firefox Server\n" if $self->Verbose;
  my $display = $self->Display;
  if ($self->Headless) {
    $self->MyXvfb
      (System::Xvfb->new());
    $self->MyXvfb->StartXvfb
      (
       Display => $display,
       StartX11vnc => $self->ViewHeadless,
       StartXvncViewer => $self->ViewHeadless,
      );
  }
  if (! $self->MyIsRunningP
      (
       System => 'Firefox',
      )) {
    $THISENV = "export DISPLAY=$display \&\& ";
    if ($self->MyIsRunningP
	(
	 System => 'Xvfb',
	)) {
      print 'Method '.$self->Method."\n";
      if ($self->Method eq 'Tor') {
	print "Starting Tor\n";
	system "(cd /home/andrewdo/tor/Mechanize/tor-browser_en-US && ${THISENV}./start-tor-browser.desktop)";
	sleep 20;
      } elsif ($self->Method eq 'Normal') {
	print "Starting Firefox\n";
	system "(${THISENV}firefox -P WWW_Mechanize_Firefox -repl &)";
	sleep 10;
      }
      # $self->ServerRunningP();
    }
  }
}

sub StopServer {
  my ($self,%args) = @_;
  print "Stop Firefox Server\n" if $self->Verbose;
  my $display = $self->Display;
  if ($self->Method eq 'Tor') {
    # /media/andrewdo/s3/backup-from-ai-220/tor/Mechanize/tor-browser_en-US/Browser/TorBrowser/Tor/tor --defaults-torrc /media/andrewdo/s3/backup-from-ai-220/tor/Mechanize/tor-browser_en-US/Browser/TorBrowser/Data/Tor/torrc-defaults -f /media/andrewdo/s3/backup-from-ai-220/tor/Mechanize/tor-browser_en-US/Browser/TorBrowser/Data/Tor/torrc DataDirectory /media/andrewdo/s3/backup-from-ai-220/tor/Mechanize/tor-browser_en-US/Browser/TorBrowser/Data/Tor GeoIPFile /media/andrewdo/s3/backup-from-ai-220/tor/Mechanize/tor-browser_en-US/Browser/TorBrowser/Data/Tor/geoip GeoIPv6File /media/andrewdo/s3/backup-from-ai-220/tor/Mechanize/tor-browser_en-US/Browser/TorBrowser/Data/Tor/geoip6 HashedControlPassword 16:9ec94c1e21afc9c760394296217ff8217c976f219f45f323622f17013b __OwningControllerProcess 11444
    Killall
      (
       Pattern => 'Browser/TorBrowser/Tor/tor',
       Simulate => $args{Simulate},
      );
  } elsif ($self->Method eq 'Normal') {
    $self->MyFirefox->quit();
    # Killall
    #   (
    #    Pattern => 'firefox-esr -P WWW_Mechanize_Firefox -repl',
    #    Simulate => $args{Simulate},
    #   );
  }
  if ($args{StopAllXvfb}) {
    $self->MyXvfb->StopAll
      (
       Simulate => $args{Simulate},
       Display => $display,
      );
  }
}

sub ServerRunningP {
  my ($self,%args) = @_;
  # FIXME: instead of sleeping, try polling running a command like
  # (+ 1 1) and getting the result
  sleep 10;
}

sub StartClient {
  my ($self,%args) = @_;

}

sub Get {
  my ($self,%args) = @_;
  $self->MyFirefox->get($args{URL});
}

sub Content {
  my ($self,%args) = @_;
  return $self->MyFirefox->content(%args);
}

sub GetContent {
  my ($self,%args) = @_;
  my $res1 = $self->Get(URL => $args{URL});
  my %contentargs = ();
  if ($args{ContentArgs}) {
    %contentargs = %{$args{ContentArgs}};
  }
  # print Dumper({ContentArgs => \%contentargs});
  my $res2 = $self->Content(%contentargs);
  # print Dumper($res2);
  my $retval =
    {
     Success => 1,
     Res1 => $res1,
     Res2 => $res2,
    };
  # print Dumper({Retval => $retval});
  return $retval;
}

1;
