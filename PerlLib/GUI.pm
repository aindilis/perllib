package PerlLib::GUI;

use Manager::Dialog qw(Approve ApproveCommands Choose Message QueryUser);
use PerlLib::SwissArmyKnife;
use PerlLib::GUI::Configuration;
use PerlLib::GUI::TabManager;

use Tk;
use Tk::Menu;

$VERSION = '1.00';
use strict;
use Class::MethodMaker
  new_with_init => 'new',
  get_set       => 
  [

   qw / Menu Hooks Continue OrderedMenu CurrentMenu Input Stack
	MenuStack MyMainWindow MyTabManager MyConfiguration
	Title Width Height /

  ];

sub init {
  my ($self, %args) = @_;
  $self->Title($args{Title} || "Application");
  $self->OrderedMenu($args{Menu});
  $self->Menu($self->ConstructMenu(OrderedMenu => $self->OrderedMenu));
  $self->CurrentMenu($args{CurrentMenu});
  $self->Hooks($args{Hooks} || {});
  $self->Width($args{Width} || 1024);
  $self->Height($args{Width} || 768);
  $self->MyMainWindow
    (MainWindow->new
     (
      -title => $self->Title,
      -width => $self->Width,
      -height => $self->Height,
     ));
  $UNIVERSAL::managerdialogtkwindow = $self->MyMainWindow;
  $self->MyConfiguration
    (PerlLib::GUI::Configuration->new
     (MainWindow => $self->MyMainWindow));
  $self->MyConfiguration->SelectProfile();
}

sub BeginEventLoop {
  my ($self,%args) = @_;
  $self->MyMainWindow->geometry($self->Width.'x'.$self->Height);

  my $menu = $self->MyMainWindow->Frame(-relief => 'raised', -borderwidth => '1');
  $menu->pack(-side => 'top', -fill => 'x');

  my $menu_file_1 = $menu->Menubutton
    (
     -text => 'File',
     -tearoff => 0,
     -underline => 0,
    );
  $menu_file_1->pack
    (
     -side => 'left',
    );

  my $menu_file_2 = $menu->Menubutton
    (
     -text => 'Actions',
     -tearoff => 0,
     -underline => 0,
    );
  $menu_file_2->pack
    (
     -side => 'left',
    );

  #   $self->MyMainWindow->Label
  #     (
  #      -text => "hi",
  #      )->pack(-expand => 1, -fill => 'both');

  my $menuhash;
  my $exit = 0;
  $self->Continue(1);
  $self->Stack([]);
  $self->MenuStack([]);
  $self->Goto
    (Menu => $self->CurrentMenu);

  if (! @{$self->Stack}) {
    $self->Goto
      (Menu => "Main Menu");
  }

  $menuhash = $self->Stack->[-1];
  my @choices = ("Cancel");
  push @choices, @{$menuhash->{'_ordering'}};
  print "\n";
  if (exists $self->Hooks->{Refresh}) {
    &{$self->Hooks->{Refresh}};
  }
  print join(" :: ",@{$self->MenuStack})."\n";
  my $i = 0;
  foreach my $response (@choices) {
    if ($i or $response ne "Cancel") {
      $menu_file_2->command
	(
	 -label => $response,
	 -command => sub {
	   if ($response) {
	     my $thing = $menuhash->{$response};
	     if (defined $thing && ref $thing eq "CODE") {
	       &$thing;
	     } else {
	       $self->Goto
		 (Menu => $response);
	     }
	   }
	 },
	 -underline => 0,
	);
    }
    ++$i;
  }

  $self->MyMainWindow->bind
    (
     'all',
     '<Control-q>',
     sub {
       $self->Exit();
     },
    );
  $self->MyTabManager
    (PerlLib::GUI::TabManager->new());
  $self->MyTabManager->Execute
    (MyMainWindow => $self->MyMainWindow);
  MainLoop();
}

sub ExitEventLoop {
  my ($self, %args) = @_;
  $self->Continue(0);
}

sub ConstructMenu {
  my ($self, %args) = @_;
  my @copy = @{$args{OrderedMenu}};
  my @keys;
  my %menu;
  while (@copy) {
    my ($key,$value) = (shift @copy, shift @copy);
    push @keys, $key;
    if (ref($value) eq "ARRAY") {
      $menu{$key} = $self->ConstructMenu(OrderedMenu => $value);
    } else {
      $menu{$key} = $value;
    }
  }
  $menu{'_ordering'} = \@keys;
  return \%menu;
}

sub Back {
  my ($self, %args) = @_;

  # kill the current menu
  # ->destroy(); ->DESTROY();


  pop @{$self->Stack};
  pop @{$self->MenuStack};
}

sub Goto {
  my ($self, %args) = @_;
  my $menu = $args{Menu};
  if (exists $self->Menu->{$menu}) {
    push @{$self->Stack}, $self->Menu->{$menu};
    push @{$self->MenuStack}, $menu;

    # also create a new recursive GUI for this, but have it not a top
    # level

    # PerlLib::GUI->new();

  } else {
    Message(Message => "Menu not found: <$menu>");
  }
}

sub GetCurrentTab {
  my ($self,%args) = @_;
  return $self->MyTabManager->Tabs->{$self->MyTabManager->MyNoteBook->raised()};
}

sub Exit {
  my ($self,%args) = @_;
  if (1) {
    my $dialog = $UNIVERSAL::managerdialogtkwindow->Dialog
      (
       -text => "Please Choose",
       -buttons => ["Exit", "Reinvoke", "Cancel"],
      );
    my $res = $dialog->Show;
    if ($res eq "Exit") {
      exit(0);
    } elsif ($res eq "Reinvoke") {
      # kill it and start a new one
      my $cli = GetCommandLineForCurrentProcess();
      my $cwd = `pwd`;
      chomp $cwd;
      system "(sleep 1; cd $cwd && $cli) &";
      exit(0);
    } elsif ($res eq "Cancel") {
      # do nothing
    }
  } else {
    if (Approve("Exit ".$self->Title."?")) {
      exit(0);
    }
  }
}

sub EditConfiguration {
  my ($self,%args) = @_;
  $self->MyConfiguration->EditProfile();
}

1;
