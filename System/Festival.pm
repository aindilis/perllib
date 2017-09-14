package System::Festival;

use Manager::Dialog qw (Message ApproveCommands);

use Data::Dumper;
use Lingua::EN::Sentence qw(get_sentences);
use Net::Telnet;
use Text::Wrap;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Config TTSServer FestivalConfigFile /

  ];

sub init {
  my ($self,%args) = @_;
  $self->FestivalConfigFile
    ("/etc/clear/fest.conf");
}

sub Execute {
  my ($self,%args) = @_;
  # just sit in a holding pattern, listening for commands to read items.
  $self->InitializeTTS;
}

sub InitializeTTS {
  my ($self,%args) = @_;
  Message(Message => "Initializing TTS engine...");
  system "killall festival";
  $self->StartTTS;
}

sub StartTTS {
  my ($self,%args) = @_;
  system "festival --server ".$self->FestivalConfigFile." &";
  system "sleep 2";
  $self->TTSServer
    (Net::Telnet->new
     (Timeout => 3600,
      Errmode => 'die'));
  $self->TTSTelnetOpen;
}

sub RestartTTSConnect {
  my ($self,%args) = @_;
  $self->TTSTelnetClose;
  $self->TTSTelnetOpen;
}

sub TTSTelnetOpen {
  my ($self,%args) = @_;
  $self->TTSServer->open
    (Host => "localhost",
     Port => "1314");
}

sub TTSTelnetClose {
  my ($self,%args) = @_;
  $self->TTSServer->close();
}

sub RestartTTS {
  my ($self,%args) = @_;
  system "killall festival";
  $self->StartTTS;

}

sub ChangeTTSSpeed {
  my ($self,%args) = @_;
  # print out to the config file, then reload the tts
  my $duration = $args{Duration} || 1.0;
  my $OUT;
  my $templatefile = "/etc/clear/fest.conf.template";
  my $c = `cat $templatefile`;
  $c =~ s/<DURATION>/$duration/;
  open (OUT,">/etc/clear/fest.conf") or die "ouch\n";
  print OUT $c;
  close (OUT);
  $self->RestartTTS;
}

sub ChangeVolume {
  my ($self,%args) = @_;
  # print out to the config file, then reload the tts
  system "aumix -v $args{Volume}";
}

sub Say {
  my ($self,%args) = @_;
  # $char = $self->Say(Text => "test");
  my $text = $args{Text};
  if ($text) {
    $text =~ s/"//g;
    $text =~ s/\\//g;
    my $command = "(SayText \"$text\")";
    print wrap("", "", $text)."\n";
    $self->SendCommand
      (Command => $command);
  }
}

sub SendCommand {
  my ($self,%args) = @_;
  my $command = $args{Command};
  if ($command) {
    $self->TTSServer->print($command);
    # wait until it is finished
    my $loop = 1;
    while ($loop) {
      $self->TTSServer->waitfor
	(Match => '/ft_StUfF_keyOK/',
	 Timeout => 0.25,
	 Errmode => "return");
      my $mess = $self->TTSServer->errmsg;
      if ($mess !~ /pattern match timed-out/) {
	$loop = 0;
      }
    }
  }
}

sub SaySentences {
  my ($self,$text) = @_;
  my $sentences = get_sentences($text);
  foreach my $sent (@$sentences) {
    $self->Say(Text => $sent);
  }
}

sub SetSpeed {
  my ($self,%args) = @_;
  $self->SendCommand
    (Command => "(Parameter.set 'Duration_Stretch $args{Speed})");
}

sub DESTROY {
  my ($self,%args) = @_;
}

1;
