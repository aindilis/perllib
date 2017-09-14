package System::Xvfb;

use PerlLib::SwissArmyKnife;
use PerlLib::Util::Misc;

# use Manager::Dialog;
# use System::WWW::Firefox;

# my $xvfb = System::Xvfb->new(Instances => {2 => {}});

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Instances Commands Verbose /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Instances($args{Instances} || {});
  $self->Commands({});
  $self->Verbose(1);
}


############
# Start/Stop
############

sub StartAll {
  my ($self,%args) = @_;

}

sub StopAll {
  my ($self,%args) = @_;
  print "Stop All\n" if $self->Verbose;
  $self->StopX11vnc
    (
     Display => $args{Display},
     Simulate => $args{Simulate},
    );
  $self->StopXvncViewer
    (
     Display => $args{Display},
     Simulate => $args{Simulate},
    );
  $self->StopWindowManager
    (
     Display => $args{Display},
     Simulate => $args{Simulate},
    );
  $self->StopXvfb
    (
     Display => $args{Display},
     Simulate => $args{Simulate},
    );
}


sub StartXvfb {
  my ($self,%args) = @_;
  print "Start Xvfb\n" if $self->Verbose;
  my $hostname = $args{Hostname} || 'localhost';
  my $display = $args{Display};

  my $simulate = $args{Simulate};

  my $screen = $args{Screen} || 0;
  my $resolution = $args{Resolution} || '1280x800';
  my $colordepth = $args{ColorDepth} || '24';

  my $command = "Xvfb $display -screen $screen ${resolution}x$colordepth";
  $self->Commands->{$hostname}{$display}{Xvfb} = $command;
  if (! IsRunningP
      (
       Search => $command,
      )) {
    MyDoCommandAsync
      (
       Command => $command,
       Simulate => $simulate,
      );
    sleep 5;
  }

  # wait until it's running
  $self->StartWindowManager
    (
     Display => $display,
     Simulate => $simulate,
    );

  if ($args{StartX11vnc}) {
    $self->StartX11vnc
      (
       Display => $display,
       X11vncPassword => 'beatrice',
       StartXvncViewer => $args{StartXvncViewer},
       Simulate => $simulate,
      );
  }
  if ($args{Command}) {
    $self->RunCommandAsynchonous
      (
       Display => $display,
       Command => $args{Command},
       Simulate => $simulate,
      );
    sleep 5;
  }
  $self->ListRunningComponents();
  print "Done Initializing System::Xvfb\n";
}

sub StopXvfb {
  my ($self,%args) = @_;
  print "Stop Xvfb\n" if $self->Verbose;
  my $hostname = $args{Hostname} || 'localhost';
  my $display = $args{Display};
  if (IsRunningP
      (
       Search => $self->Commands->{$hostname}{$display}{Xvfb},
      )) {
    Killall
      (
       Pattern => $self->Commands->{$hostname}{$display}{Xvfb},
       Simulate => $args{Simulate},
      );
  }
  $self->ListRunningComponents();
}

sub StartWindowManager {
  my ($self,%args) = @_;
  print "Start Window Manager\n" if $self->Verbose;
  my $command = "metacity --display $args{Display}";
  my $hostname = $args{Hostname} || 'localhost';
  my $display = $args{Display};
  $self->Commands->{$hostname}{$display}{metacity} = $command;
  if (! IsRunningP
      (
       Search => $command,
      )) {
    MyDoCommandAsync
      (
       Command => $command,
       Simulate => $args{Simulate},
      );
    sleep 5;
  }
  $self->ListRunningComponents();
}

sub StopWindowManager {
  my ($self,%args) = @_;
  print "Stop Window Manager\n" if $self->Verbose;
  my $hostname = $args{Hostname} || 'localhost';
  my $display = $args{Display};
  if (IsRunningP
      (
       Search => $self->Commands->{$hostname}{$display}{metacity},
      )) {
    Killall
      (
       Pattern => $self->Commands->{$hostname}{$display}{metacity},
       Simulate => $args{Simulate},
      );
    sleep 3;
  }
  $self->ListRunningComponents();
}

sub StartX11vnc {
  my ($self,%args) = @_;
  print "Start X11vnc\n" if $self->Verbose;
  my $hostname = $args{Hostname} || 'localhost';
  my $display = $args{Display};
  my $command = "sudo x11vnc -display $display -shared -passwd ".shell_quote($args{X11vncPassword});
  $self->Commands->{$hostname}{$display}{x11vnc} = $command;
  if (! IsRunningP
      (
       Search => $command,
      )) {
    MyDoCommandAsync
      (
       Command => $command,
       Simulate => $args{Simulate},
      );
    sleep 5;
  }
  if ($args{StartXvncViewer}) {
    $self->StartXvncViewer
      (
       Display => $args{Display},
       X11vncPassword => $args{X11vncPassword},
       Simulate => $args{Simulate},
      );
  }
  $self->ListRunningComponents();
}

sub StopX11vnc {
  my ($self,%args) = @_;
  print "Stop X11vnc\n" if $self->Verbose;
  my $hostname = $args{Hostname} || 'localhost';
  my $display = $args{Display};
  if (IsRunningP
      (
       Search => $self->Commands->{$hostname}{$display}{x11vnc},
      )) {
    Killall
      (
       Pattern => $self->Commands->{$hostname}{$display}{x11vnc},
       Simulate => $args{Simulate},
      );
  }
  $self->ListRunningComponents();
}

sub StartXvncViewer {
  my ($self,%args) = @_;
  print "Start XvncViewer\n" if $self->Verbose;
  my $tmpfile = ConcatDir($ENV{HOME},'vnc');
  my $hostname = $args{Hostname} || 'localhost';
  my $display = $args{Display};
  my $command = "xvncviewer $hostname:5900 -passwd ".shell_quote($tmpfile);
  $self->Commands->{$hostname}{$display}{xvncviewer} = $command;
  if (! IsRunningP
      (
       Search => $command,
      )) {
    MyDoCommandAsync
      (
       Command => $command,
       Simulate => $args{Simulate},
      );
    sleep 3;
  }
  $self->ListRunningComponents();
}

sub StopXvncViewer {
  my ($self,%args) = @_;
  print "Stop XvncViewer\n" if $self->Verbose;
  my $hostname = $args{Hostname} || 'localhost';
  my $display = $args{Display};
  if (IsRunningP
      (
       Search => $self->Commands->{$hostname}{$display}{xvncviewer},
      )) {
    Killall
      (
       Pattern => $self->Commands->{$hostname}{$display}{xvncviewer},
       Simulate => $args{Simulate},
      );
  }
  $self->ListRunningComponents();
}

######
# Util
######

sub RunCommand {
  my ($self,%args) = @_;
  my $command = "DISPLAY=$args{Display} $args{Command}";
  ApproveCommands
    (
     Commands => [$command],
     AutoApprove => 1,
    ) unless $args{Simulate};
}

sub RunCommandAsynchonous {
  my ($self,%args) = @_;
  my $command = "DISPLAY=$args{Display} $args{Command} &";
  ApproveCommands
    (
     Commands => [$command],
     AutoApprove => 1,
    ) unless $args{Simulate};
}

sub ListRunningComponents {
  my ($self,%args) = @_;
  my $results = `ps auxwww | grep -E '(Xvfb|x11vnc|xvncviewer|metacity)' | grep -v grep`;
  print "##############\n";
  print $results;
  print "##############\n";
}

1;
