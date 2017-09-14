package System::StanfordParserOld;

use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyServerManager /

  ];

sub init {
  my ($self,%args) = @_;

}

sub ProcessText {
  my ($self,%args) = @_;
  my $fh = IO::File->new();
  my $inputfile = "/tmp/stanfordparser.txt";
  system "rm $inputfile";
  $fh->open(">$inputfile") or die "cannot open inputfile $inputfile\n";
  print $fh $args{Text};
  $fh->close();
  my $command = "cd /var/lib/myfrdcsa/sandbox/stanford-parser-20100601/stanford-parser-20100601 && ./lexparser.csh $inputfile";
  my $res = `$command`;
  return $self->ProcessResults
    (Response => $res);
}

sub ProcessResults {
  my ($self,%args) = @_;
  my $c = $args{Response};
  print Dumper($c);
  $c =~ s/.*Parsing file: (.+?) with (\d+) sentences.\n//s;
  $c =~ s/\n\nParsed file: (.+?) \[(\d+) sentences\]\..*//s;
  my @items = split /\n\n/, $c;
  my @res;
  while (@items) {
    my ($tmp,$rel) = (shift @items, shift @items);
    if ($tmp =~ /(.+?)$(.+)/sm) {
      my $sent = $1;
      $tree = $2;
      $tree =~ s/^\s+//s;
      if ($sent eq "(ROOT") {
	$tree = "$sent\n$tree";
	$sent = "";
      }
      push @res, {
		  Sent => $sent,
		  Tree => $tree,
		  Rel => [split /\n/, $rel],
		 };

    } else {
      die "Error\n";
    }
  }
  return \@res;
}

1;
