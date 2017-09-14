package System::Sensor::RTL433;

use PerlLib::SwissArmyKnife;

use Expect;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyExpect PreviousArgs Debug PreviousMessageFromDevice /

  ];

sub init {
  my ($self,%args) = @_;
  $self->PreviousArgs([]);
  $self->Debug($args{Debug});
  $self->PreviousMessageFromDevice({});
}

sub StartServer {
  my ($self,%args) = @_;
  my $sensors = $args{Sensors} || ['Honeywell Door/Window Sensor','Generic wireless motion sensor'];
  my $sensornumbers =
    {
     'Honeywell Door/Window Sensor' => 70,
     'Generic wireless motion sensor' => 87,
    };
  print Dumper({StartServerArgs => \%args});
  push @{$self->PreviousArgs}, \%args;

  foreach my $sensor (@$sensors) {
    if (exists $sensornumbers->{$sensor}) {
      push @arguments, '-R '.$sensornumbers->{$sensor};
    }
  }

  my $command = 'cd /var/lib/myfrdcsa/sandbox/rtl-433-20170709/rtl-433-20170709/build/src && ./rtl_433 '.join(' ',@arguments).' -A -t';
  print $command."\n";

  $self->MyExpect(Expect->new);
  $self->MyExpect->raw_pty(1);
  $self->MyExpect->log_stdout($self->Debug);
  $self->MyExpect->spawn($command, @parameters)
        or die "Cannot spawn $command: $!\n";

  my $sub = sub {print "Initialized.\n"};
  $self->MyExpect->expect($args{Timeout} || 300, [qr/Tuned to \d+ Hz/, $sub]);
  $self->MyExpect->clear_accum();
}

sub RestartServer {
  my ($self,%args) = @_;
  $self->MyExpect->hard_close();
  # FIXME: change to a throw error
  die 'No previous StartServer Invocation' unless scalar @{$self->PreviousArgs};
  my %previousargs = %{$self->PreviousArgs->[-1]};
  $self->StartServer(%previousargs);
}

sub ListenForTransmissions {
  my ($self,%args) = @_;
  # this is specific to ALPProlog
  $self->MyExpect->expect
    (360, [qr/(.*Guessing modulation|.*\[\d{1,2}\] \{\d{1,2}\} \w{1,2} \w{1,2} \w{1,2} \w{1,2} : \d{8} \d{8} \d{8} \d{1})/sm, sub {ProcessCallback($self)} ]);
  # $self->MyExpect->expect
  #   (360, [qr/.*bitbuffer:: Number of rows:/sm, $args{Callback} ]);
}

# sub MyMainLoop {
#   my ($self,%args) = @_;
#   # we want to listen to expect and then alternate between agent listening
#   my $delay = 0.05;
#   while (1) {
#     my $seen = 0;
#     if (defined $self->MyExpect) {
#       $seen = 1;
#       # FIX ME
#       $self->MyExpect->expect
# 	($delay, [qr/jkdsjlfakj/,sub {print "Huh?\n"}]);
#     }
#     if (defined $UNIVERSAL::agent) {
#       $seen = 1;
#       $UNIVERSAL::agent->Listen
# 	(
# 	 TimeOut => $delay,
# 	);
#     }
#     if (! $seen) {
#       sleep 5;
#     }
#   }
# }

sub Stop {
  my ($self,%args) = @_;
  $self->MyExpect->soft_close();
}

sub ProcessCallback {
  my ($self) = @_;
  my $res = $self->MyExpect->match();
  $self->ParseResponse(Response => $res);
}

sub ParseResponse {
  my ($self,%args) = @_;
  my $graceperiod = 12;
  my $hash =
    {
     DeviceID => 1,
    };

  my $c = $args{Response};
  # print Dumper({C => $c});
  my $message;
  my $notify = 0;
  if ($c =~ /(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})/s) {
    $hash->{DateTimeStamp} = $1;
  }
  if ($c =~ /Guessing modulation/) {
    $notify = 1;
    $message = 'The door sensor has become open (or closed) at '.$hash->{DateTimeStamp};
  } elsif ($c =~ /\[\d{1,2}\] \{\d{1,2}\} \w{1,2} \w{1,2} \w{1,2} \w{1,2} : \d{8} \d{8} \d{8} \d{1}/) {
    $message = 'There is motion in the livingroom at '.$hash->{DateTimeStamp};
    my $epoch = `date "+%s"`;
    chomp $epoch;
    if (! exists $self->PreviousMessageFromDevice->{$hash->{DeviceID}}) {
      $self->PreviousMessageFromDevice->{$hash->{DeviceID}} = $epoch;
      $notify = 1;
    } else {
      if ($epoch > $self->PreviousMessageFromDevice->{$hash->{DeviceID}} + $graceperiod) {
	$self->PreviousMessageFromDevice->{$hash->{DeviceID}} = $epoch;
	$notify = 1;
      }
    }
  }
  if ($notify) {
    $self->NotifyFLPOfSensorActivity
      (
       Message => $message,
       Hash => $hash,
       DateTimeStamp => $hash->{DateTimeStamp},
      );
  }
}

sub NotifyFLPOfSensorActivity {
  my ($self,%args) = @_;
  my $message = $args{Message};
  print $message."\n";
  SayToAlexa
    (
     Login => 'loginFn(andrewdo,aiFrdcsaOrg)',
     Message => $message,
    );
}

sub SayToAlexa {
  my (%args) = @_;
  my $login = $args{Login};
  my $qmessage = shell_quote($args{Message});
  my $command = "/var/lib/myfrdcsa/codebases/minor/formalog/scripts/formalog-client -q \"alexaPushNotification($login,$qmessage).\"";
  print $command."\n";
  # system $command;
}

1;
