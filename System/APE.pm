package System::APE;

use PerlLib::Util;

use Data::Dumper;
use File::Temp;
use Lingua::EN::Tagger;
use Net::Telnet;
use XML::Simple qw(XMLin);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Client MyTagger /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyTagger
    (Lingua::EN::Tagger->new);
}

sub StartServer {
  my ($self,%args) = @_;

  my $PORT = $args{Port} || 3453;
  my $apeexe = $args{APEExe} || "/var/lib/myfrdcsa/sandbox/ape-6.6.110816/ape-6.6.110816/ape/ape.exe";
  my $subcommand = "swipl -x $apeexe -- -server -port $PORT";
  my $pids = PidsForProcess
    (
     Process => $subcommand,
    );
  return if scalar @$pids;
  my $command = "nohup $subcommand > /tmp/stdout.txt 2> /tmp/stderr.txt &";
  print $command."\n";
  system $command;
  sleep 5;
}

sub StartClient {
  my ($self,%args) = @_;

  my $PORT = $args{Port} || 3453;
  my $f = File::Temp->new;
  $client = Net::Telnet->new
    (
     Host => "localhost",
     Port => $PORT,
     Dump_Log => $f->filename,
    );
  my $msg = 0;
  while (! $client->open) {
    print "Cannot open connection to server.  Retrying periodically.\n" unless $msg;
    $msg = 1;
    sleep 10;
  }
  # $client->autoflush(0);
  $self->Client($client);
}

sub StopClient {
  my ($self,%args) = @_;
  $self->Client->close;
}

sub StopServer {
  my ($self,%args) = @_;
  my $command = "killall -9 swipl";
  print $command."\n";
  system $command;
}

sub Parse {
  my ($self,%args) = @_;
  my $text = $args{Text};
  # my $tagged_text = $self->MyTagger->add_tags( $text );
  # print Dumper($tagged_text);
  my $item = "get([text='$text', cparaphrase1=on]).";
  # print "<$item>\n";
  $self->StartClient();
  my $handle = $self->Client;
  print $handle $item."\n";
  # printflush $handle $item;
  my $line = "";
  my $content;
  while ($line !~ /APESERVERSTREAMEND/) {
    $content .= $line;
    $line = $self->Client->getline();
  }
  $self->StopClient();
  my $xmlhash = XMLin($content);
  return {
	  Success => 1,
	  Result => {
		     Input => $args{Text},
		     XMLHash => $xmlhash,
		     Content => $content,
		    },
	 };
}

1;
