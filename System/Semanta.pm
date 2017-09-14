package System::Semanta;

use PerlLib::Util;

use Data::Dumper;
use Expect;
use Text::CSV;
use XMLRPC::Lite;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyProcessString MyCSV MyExpect /

  ];

sub init {
  my ($self,%args) = @_;
  print "Note: Semanta can take several minutes to fully initialize, test using test-semanta.pl.\n";
  $self->MyProcessString("/usr/bin/java -jar /media/andrewdo/s3/sandbox/nepomuklite-20150821/nepomuklite-20150821/./startup.jar -os linux -ws gtk -arch x86 -launcher /media/andrewdo/s3/sandbox/nepomuklite-20150821/nepomuklite-20150821/./nepomukServerLinux -name NepomukServerLinux -showsplash 600 -exitdata 26d0027 -noExit -vm /usr/bin/java -vmargs -jar /media/andrewdo/s3/sandbox/nepomuklite-20150821/nepomuklite-20150821/./startup.jar");
  $self->MyCSV(Text::CSV->new({sep_char => ";"}));
}

sub AlreadyRunning {
  my ($self,%args) = @_;
  my $item = PidsForProcess
    (Process => $self->MyProcessString);
  return scalar @$item;
}

sub StartServer {
  my ($self,%args) = @_;
  if (! $self->AlreadyRunning and ! defined $self->MyExpect) {
    $self->MyExpect(Expect->new);
    $self->MyExpect->raw_pty(1);
    my @parameters;
    my $command = "cd /media/andrewdo/s3/sandbox/nepomuklite-20150821/nepomuklite-20150821 && ./NEPOMUKLiteLinux.sh";
    print "$command\n";
    $self->MyExpect->spawn($command, @parameters);
    $self->MyExpect->expect(300, [qr/NEPOMUK-Lite Running/, sub {print "\nNEPOMUK-Lite Running\n\n"}]);
  }
}

sub StopServer {
  my ($self,%args) = @_;
  KillProcesses
    (Process => $self->MyProcessString);
}

sub GetSpeechActs {
  my ($self,%args) = @_;
  my $text = $args{Text};
  my $req = XMLRPC::Lite
    -> proxy("http://localhost:8181/RPC2")
    -> call('sememailservice.extractSpeechActsFromContent', 'andrewdo@frdcsa.org', 'andrewdo@frdcsa.org', $text);
  my $lines = $req->{'_content'}[2][0][2][0][2][0][2][0][4];
  my @ret;
  foreach my $line (@$lines) {
    my $res = $self->MyCSV->parse($line);
    my @res = $self->MyCSV->fields;
    # 'ID;706;38;http://ontologies.smile.deri.ie/smail#Assign;http://ontologies.smile.deri.ie/smail#Task;http://ontologies.smile.deri.ie/smail#Pending;;;;;andrewdo@frdcsa.org;andrewdo@frdcsa.org',
    my ($offset,$length,$mode,$type,$status) = ($res[1],$res[2],$res[3],$res[4],$res[5]);
    # now extract the actual items:
    my $item = substr($text,$offset,$length);
    chomp $item;
    $type =~ s/^.+#//;
    $mode =~ s/^.+#//;
    push @ret, {
		Item => $item,
		Mode => $mode,
		Type => $type,
	       };
  }
  return {
	  Success => 1,
	  Result => \@ret,
	 };
}

1;
