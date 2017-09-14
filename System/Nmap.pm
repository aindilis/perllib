package System::Nmap;

use Data::Dumper;
use Nmap::Scanner;
use Time::HiRes qw( usleep );

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyScanner CallbackData /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyScanner
    (Nmap::Scanner->new);
  $self->MyScanner->max_rtt_timeout(1);
}

sub OpenPortP {
  my ($self,%args) = @_;
  $self->CallbackData(undef);
  $self->MyScanner->register_port_found_event(sub {$self->PortFound(@_)});
  $self->MyScanner->scan($args{Host}.' -p '.$args{Port});
  while (! defined $self->CallbackData) {
    return 0;
    print "yo\n";
    usleep(1000);
  }
  if (! exists $self->CallbackData->[1]->{ports}->{tcp}->{$args{Port}}->{state}) {
    print Dumper({'OpenPortP-Res' => 0});
    return 0;
  }
  my $item = $self->CallbackData->[1]->{ports}->{tcp}->{$args{Port}}->{state};
  if ($item eq "open") {
    return 1;
  } else {
    return 0;
  }
}

sub PortFound {
  my ($self,@items) = @_;
  print "Hey\n";
  print Dumper(\@items);
  $self->CallbackData(\@items);
}

1;
