package PerlLib::Cluster;

use MyFRDCSA qw ( ConcatDir Dir );
use Manager::Dialog qw (ApproveCommands);

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Contents FileNames InputDir OutputDir SystemDir Clusters
   IClusters /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Contents($args{Contents} || []);
  $self->FileNames($args{FileNames} || []);
  $self->SystemDir($args{SystemDir} || ConcatDir("/tmp","corpus"));
  $self->InputDir($args{InputDir} || ConcatDir($self->SystemDir,"input"));
  $self->OutputDir($args{OutputDir} || ConcatDir($self->SystemDir,"output"));
  $self->Clusters({});
  $self->IClusters({});
}

sub ExportData {
  my ($self,%args) = @_;
  # make sure dirs exist
  my @commands;
  push @commands, "rm -rf ~/.crossbow";
  if (! -e $self->SystemDir) {
    push @commands, "mkdir ".$self->SystemDir;
  } elsif (! -d $self->SystemDir) {
    push @commands, "rm ".$self->SystemDir;
  }
  foreach my $dir (qw (InputDir OutputDir)) {
    push @commands, "rm -rf ".$self->$dir;
    push @commands, "mkdirhier ".$self->$dir;
  }
  ApproveCommands(Method => "parallel",
		  Commands => \@commands);

  # export data in whatever format we have it
  foreach my $file (@{$self->FileNames}) {
    if (-f $file) {
      system "cp -b $file ".$self->InputDir;
    }
  }

  my $i = 0;
  foreach my $string (@{$self->Contents}) {
    while (-f ConcatDir($self->InputDir,$i)) {
      ++$i;
    }
    $self->Write(ConcatDir($self->InputDir,$i),$string);
    ++$i;
  }
}

sub Write {
  my ($self,$file,$string) = (shift,shift,shift);
  my $OUT;
  open (OUT,">$file");
  print OUT $string;
  close (OUT);
}

sub Index {
  my ($self,%args) = @_;
  system "crossbow -i ".$self->InputDir." > /tmp/index.1.log 2> /tmp/index.2.log";
}

sub Cluster {
  my ($self,%args) = @_;
  $hem = "--hem-branching-factor=$args{Branching}" if $args{Branching};
  # system "cd ".$self->OutputDir." && crossbow -c $hem --verbosity=0 > /tmp/cluster.1.log 2> /tmp/cluster.2.log";
  system "cd ".$self->OutputDir." && crossbow -c --cluster-output-dir=. > /tmp/cluster.1.log";
}

sub ProcessResults {
  my ($self,%args) = @_;
  my $outputdir = $self->OutputDir;
  my $max = 0;
  $args{Processor} ||= sub {
    my ($fi,$cl) = @_;
    my $co = `cat "$fi"`;
    return $co;
  };
  $args{ProcessorArgs} ||= [];
  foreach my $f (split /\n/, `ls $outputdir/crossbow-classifications-*`) {
    if ($f =~ /.*?(\d+)$/) {
      if ($1 > $max) {
	$max = $1;
      }
    }
  }
  my $f = "$outputdir/crossbow-classifications-$max";
  if (-f $f) {
    foreach my $l (split /\n/,`cat "$f"`) {
      my @li = split / \/ /,$l;
      my $fi = $li[0];
      my $cl = $li[1];
      my $co = $args{Processor}->($fi,$cl,@{$args{ProcessorArgs}});
      $self->Clusters->{$co} = $cl;
      $self->IClusters->{$cl}->{$co} = 1;
    }
    print Dumper($self->IClusters);
  } else {
    print "Cannot find file <$f>\n";
  }
}

1;
