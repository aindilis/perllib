package System::CAndC;

use Capability::Tokenize;
use PerlLib::SwissArmyKnife;

use Expect;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyExpect Debug CAndCDir /

  ];

sub init {
  my ($self,%args) = @_;
  $self->CAndCDir($args{CAndCDir} || "/var/lib/myfrdcsa/sandbox/candc-1.00/candc-1.00");
}

sub StartServer {
  my ($self,%args) = @_;
  my $dir = `pwd`;
  my $key = "bin/soap_server";
  my $res = `ps ax | grep '$key' | grep -v grep`;
  if ($res =~ /$key/) {
    return;
  }

  $self->MyExpect(Expect->new);
  $self->MyExpect->raw_pty(1);
  $self->MyExpect->log_stdout($self->Debug);

  my $command = "cd ".shell_quote($self->CAndCDir)." && bin/soap_server --models models --server 127.0.0.1:8999 --candc-printer prolog";
  $self->MyExpect->spawn($command, @parameters)
    or die "Cannot spawn $command: $!\n";

  print "Waiting for CAndC to initialize...\n";
  $self->MyExpect->expect(300, [qr/waiting for connections on/, sub {print "Initialized.\n"}]);
  # $self->MyExpect->clear_accum();
}

sub LogicForm {
  my ($self,%args) = @_;
  # $self->StartServer;
  return $self->NonServerLogicForm(Text => $args{Text});
  # return $self->CallClient(Text => $args{Text});
}

sub CallClient {
  my ($self,%args) = @_;
  my $OUT;
  open (OUT, ">/tmp/candctext") or die "death!\n";
  print OUT $args{Text};
  close (OUT);
  my $dir = $self->CAndCDir;
  my $res = `cd $dir && bin/soap_client --url http://127.0.0.1:8999 --input /tmp/candctext`;
  return $self->CleanUp(Result => $res);
}

sub CleanUp {
  my ($self,%args) = @_;
  # clean the text up nicely
  return $args{Result};
}

sub NER {
  my ($self,%args) = @_;
  # have to format the text carefully
  my $OUT;
  open (OUT, ">/tmp/candctext") or die "death!\n";
  print OUT $args{Text};
  close (OUT);
  my $dir = `pwd`;
  chdir $self->CAndCDir;
  my $res = `cat /tmp/candctext | bin/pos --model models/pos | bin/ner --model models/ner`;
  chdir $dir;
  return $res;
}

sub NonServerLogicForm {
  my ($self,%args) = @_;
  open (OUT, ">/tmp/candctext") or die "death!\n";
  print OUT tokenize_treebank($args{Text});
  close (OUT);
  my $dir = `pwd`;
  # chdir $self->CAndCDir;
  # print $self->CAndCDir."\n";
  my $qdir = shell_quote($self->CAndCDir);
  system "cd $qdir && bin/candc --input /tmp/candctext --models models/boxer > /tmp/test.ccg";
  my $res = `cd $qdir && bin/boxer --input /tmp/test.ccg`; # --box true --flat true`;
  return $self->CleanUp(Result => $res);
}

sub GetCCGAndDRS {
  my ($self,%args) = @_;
  my $root = "/var/lib/myfrdcsa/codebases/internal/perllib/data/candc-text";
  WriteFile
    (
     File => $root.'.met',
     Contents => "<META>rte\n".tokenize_treebank($args{Text})."\n",
    );
  ApproveCommands
    (
     Commands =>
     [
      "cd /var/lib/myfrdcsa/sandbox/nutcracker-1.0/nutcracker-1.0/candc && bin/candc --input $root.met --output $root.ccg --models models/boxer --candc-printer boxer",
      "cd /var/lib/myfrdcsa/sandbox/nutcracker-1.0/nutcracker-1.0/candc && bin/boxer --input $root.ccg --output $root.drs --resolve --vpe --box",
     ],
     Method => 'parallel',
     AutoApprove => 1,
    );
  my $ccg = read_file("$root.ccg");
  my $drs = read_file("$root.drs");

  return
    {
     CCG => $ccg,
     DRS => $drs,
    };
}

1;

