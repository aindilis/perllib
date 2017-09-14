package System::GnuPlot::Command;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Window Table Options /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Window($args{Window});	# a string containing the window
  $self->Table($args{Table});	# a list describing what the rows are
  $self->Options($args{Options}); # a list of options
}

sub SPrint {
  my ($self,%args) = @_;
  my @cp = ('plot');
  push @cp, $self->Window if $self->Window;
  my $i = 2;
  my @l;
  foreach my $label (@{$self->Table}) {
    my @m =
      (
       "'/tmp/measures'",
       "using 1:$i",
       "t",
       "\"$label\"",
      );
    if ($self->Options) {
      push @m, $self->Options
    } else {
      push @m, ('lw 3','with lines');
    }
    ++$i;
    push @l, join(" ",@m);
  }
  push @cp, join(", ",@l);
  my $com = join(" ",@cp);
  print $com."\n";
  return $com;
}

1;
