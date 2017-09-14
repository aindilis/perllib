package System::GnuPlot;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / /

  ];

sub init {
  my ($self,%args) = @_;

}

sub Plot {
  my ($self,%args) = @_;
  my $commandfile = "/tmp/gnuplot";
  my $OUT;
  open(OUT,">$commandfile") or die "cannot open commandfile for writing\n";
  if ($args{OutputFormat} and $args{OutputFormat} eq "jpeg") {
    print OUT "set terminal jpeg\n";
  }
  print OUT $args{Command};
  close(OUT);

  if ($args{OutputFormat} and $args{OutputFormat} eq "jpeg") {
    my $outputfile = $args{OutputFile} || "/tmp/plot.jpg";
    system "gnuplot $commandfile > \"$outputfile\"";
    system "xview \"$outputfile\"" if (! defined $args{Wait} or $args{Wait});
  } else {
    # system "gnuplot $commandfile";
    system "gnuplot -persist $commandfile";
    if (defined $args{Wait}) {
      if ($args{Wait}) {
	sleep $args{Wait};
      }
    } else {
      sleep 100;
    }
  }
}

1;
