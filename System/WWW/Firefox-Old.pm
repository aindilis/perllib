package System::WWW::Firefox;

use PerlLib::SwissArmyKnife;

use WWW::Mechanize::Firefox;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyFirefox Method Headless ViewHeadless Port Debug /

  ];

sub init {
  my ($self,%args) = @_;

  $self->Method($args{Method} || 'Tor');
  $self->Headless($args{Headless} || 1);
  $self->ViewHeadless($args{ViewHeadless} || 0);
  $self->Port($args{Port} || 1);

  $self->StartServer();
  $self->MyFirefox(WWW::Mechanize::Firefox->new(tab => 'current'));
}

sub HasProcess {
  my ($self,%args) = @_;
  my $search = $args{Search};
  my $command = $args{Command} || "ps auxwww | grep '$search' | grep -v grep | wc -l";
  $count = `$command`;
  chomp $count;
  my $res = ($count > 0);
  return $res;
}

sub IsRunningP {
  my ($self,%args) = @_;
  print "Checking whether the system is running\n";
  if ($args{System} eq 'Firefox') {
    my $count;
    if ($self->Method eq 'Tor') {
      print "Checking Tor\n";
      return $self->HasProcess(Search => 'Tor Browser')
    } elsif ($self->Method eq 'Normal') {
      print "Checking Firefox\n";
      return $self->HasProcess(Command => "ps auxwww | grep WWW_Mechanize_Firefox | grep -v grep | grep firefox | wc -l");
    }
  } elsif ($args{System} eq 'Xvfb') {
    return $self->HasProcess(Search => 'Xvfb')
  }
}

sub StartServer {
  my ($self,%args) = @_;
  my $THISENV = ' ';
  if ($self->Headless) {
    # FIXME: my $xvfb = System::Xvfb->new(...);

    my $port = $self->Port || 1;
    $THISENV = "export DISPLAY=:$port \&\& ";
    if (! $self->IsRunningP(System => 'Xvfb')) {
      print "Starting Xvfb for headless Firefox\n";
      system "(Xvfb :$port &)";
      sleep 5;

      if ($self->ViewHeadless) {
	# # "/usr/bin/Xvfb :$port -ac -screen 0 1024x768x8";
	# # "export DISPLAY=\":$port\" && ";

	system "x11vnc -display :$port -localhost &";
	sleep 5;
	system "vncviewer :0"
      }
    }
  }
  if (! $self->IsRunningP(System => 'Firefox')) {
    if ($self->Method eq 'Tor') {
      print "Starting Tor\n";
      system "(cd /home/andrewdo/tor/Mechanize/tor-browser_en-US && ${THISENV}./start-tor-browser.desktop)";
      sleep 20;
    } elsif ($self->Method eq 'Normal') {
      print "Starting Firefox\n";
      system "(${THISENV}firefox -P WWW_Mechanize_Firefox -repl &)";
      sleep 10;
    }
    $self->ServerRunningP();
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

sub GetContent {
  my ($self,%args) = @_;
  my $res1 = $self->Get(URL => $args{URL});
  my $res2 = $self->MyFirefox->content;
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
