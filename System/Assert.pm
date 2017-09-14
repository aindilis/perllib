package System::Assert;

use Data::Dumper;
use File::Temp qw(tempfile tempdir);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / /

  ];

sub init {
  my ($self,%args) = @_;
}

sub Parse {
  my ($self,%args) = @_;
  my $dir = "/var/lib/myfrdcsa/sandbox/assert-0.14/assert-0.14/system-assert-data";
  # my $dir = "/var/lib/myfrdcsa/sandbox/assert-0.14/assert-0.14/system-assert-data";
  chdir $dir;
  my $fh = File::Temp->new(DIR => ".");
  print $fh $args{Text};
  my $filename = $fh->filename;
  system "/var/lib/myfrdcsa/sandbox/assert-0.14/assert-0.14/scripts/assert \"$filename\"";
  my $results;
  my $parsefile = "$dir/${filename}.parses";
  print "PARSEFILE: $parsefile\n";
  if (-f $parsefile) {
    $results = `cat "$parsefile"`;
  }
  $fh = undef;
  my @all;
  foreach my $line (split /\n/, $results) {
    # 0: [ARG1 I] am [TARGET tired ] [ARG0 of those who claim that good is subjective]
    my $res = {};
    foreach my $item ($line =~ /\[([^\]]+)\]/g) {
      if ($item =~ /^([\w\-]+)\s+(.+?)\s*$/) {
	$res->{$1} = $2;
      }
    }
    push @all, $res;
  }
  if ($args{Results} eq "full") {
    return {
	    Parsed => $results,
	    Processed => \@all,
	   };
  } else {
    return \@all;
  }
}

sub PrintStruct {
  my $res = shift;
  my @list;
  if (exists $res->{TARGET}) {
    push @list, $res->{TARGET};
  }
  if (exists $res->{"ARG0"}) {
    my $i = 0;
    while (exists $res->{"ARG$i"}) {
      push @list, $res->{"ARG$i"};
      ++$i;
    }
  } elsif (exists $res->{"ARG1"}) {
    my $i = 1;
    while (exists $res->{"ARG$i"}) {
      push @list, $res->{"ARG$i"};
      ++$i;
    }
  }
  print join(" ",map {"'$_'"} @list)."\n";
}


1;
