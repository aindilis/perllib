package PerlLib::UI;

use Manager::Dialog qw ( Approve Choose Message QueryUser );

use Data::Dumper;

$VERSION = '1.00';
use strict;
use Class::MethodMaker
  new_with_init => 'new',
  get_set       => 
  [

   qw / Menu Hooks Continue OrderedMenu CurrentMenu Input Stack
   MenuStack /

  ];

sub init {
  my ($self, %args) = @_;
  $self->OrderedMenu($args{Menu});
  $self->Menu($self->ConstructMenu(OrderedMenu => $self->OrderedMenu));
  $self->CurrentMenu($args{CurrentMenu});
  $self->Hooks($args{Hooks} || {});
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

sub BeginEventLoop {
  my ($self, %args) = @_;
  my $menuhash;
  my $exit = 0;
  $self->Continue(1);
  $self->Stack([]);
  $self->MenuStack([]);
  $self->Goto
    (Menu => $self->CurrentMenu);
  do {
    if (! @{$self->Stack}) {
      $self->Goto
	(Menu => "Main Menu");
    }
    while ($self->Continue and @{$self->Stack}) {
      $menuhash = $self->Stack->[-1];
      my @choices = ("Cancel");
      push @choices, @{$menuhash->{'_ordering'}};
      print "\n";
      if (exists $self->Hooks->{Refresh}) {
	&{$self->Hooks->{Refresh}};
      }
      print join(" :: ",@{$self->MenuStack})."\n";
      my $response = Choose(@choices);
      if ($response) {
	my $thing = $menuhash->{$response};
	if (defined $thing && ref $thing eq "CODE") {
	  &$thing;
	} elsif ($response eq "Cancel") {
	  $self->Back;
	} else {
	  $self->Goto
	    (Menu => $response);
	}
      }
    }
  } while ($self->Continue and ! Approve("Okay to quit?"));
}

sub ExitEventLoop {
  my ($self, %args) = @_;
  $self->Continue(0);
}

sub Back {
  my ($self, %args) = @_;
  pop @{$self->Stack};
  pop @{$self->MenuStack};
}

sub Goto {
  my ($self, %args) = @_;
  my $menu = $args{Menu};
  if (exists $self->Menu->{$menu}) {
    push @{$self->Stack}, $self->Menu->{$menu};
    push @{$self->MenuStack}, $menu;
  } else {
    Message(Message => "Menu not found: <$menu>");
  }
}

1;
