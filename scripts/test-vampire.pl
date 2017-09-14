#!/usr/bin/perl -w

use BOSS::Config;
use Capability::TheoremProving::Vampire::VampireKIF;

use Data::Dumper;
use File::Slurp;
use XML::Smart;

my $specification = "
	-r	Restart server if already running
";

my $config = BOSS::Config->new
  (Spec => $specification,
   ConfFile => "");
my $conf = $config->CLIConfig;

my $tp = Capability::TheoremProving::Vampire::VampireKIF->new
  ();

$tp->StartServer
  (
   Restart => exists $conf->{'-r'},
  );

if (0) {
  ProcessXMLFile
    (File => "/var/lib/myfrdcsa/codebases/internal/perllib/scripts/vampire-test-query.xml");
} elsif (1) {
  my $query = read_file("/var/lib/myfrdcsa/codebases/internal/perllib/scripts/vampire-test-query.xml");
  my $res = $tp->QueryVampire
    (Query => $query);
  print Dumper($res);
} else {
  my $response = read_file("/var/lib/myfrdcsa/codebases/internal/perllib/scripts/vampire-response.xml");
  my $res = $tp->ProcessResponse
    (
     Query => $query,
     Response => $response,
    );
  print Dumper($res);
}

sub ProcessXMLFile {
  my %args = @_;
  my $query = read_file($args{File});
  if ($args{Altogether}) {
    my $xml = XML::Smart->new("<query>".$query."</query>");
    my $counter = {};
    foreach my $item (@{$xml->{query}{'/order'}}) {
      my $ref = $xml->{query}{$item}[$counter->{$item}++];
      my ($xmltext,$tmp) = $ref->data_pointer();
      my $xmltext2 = Clean(XML => $xmltext);
      $xmltext2 =~ s/&gt;/>/sg;
      # print Dumper
      # ({Item => $xmltext2})."\n";
      print "Content: ".$ref->content."\n";
      my $res =
	$tp->QueryVampire
	  (Query => $xmltext2."\n");
      print "Result: ".$res->{Result}."\n\n\n\n";
      if (! length $res->{Result}) {
	print $res->{Response}."\n\n\n\n";
      }
    }
  } else {
    my $res =
      $tp->QueryVampire
	(Query => $query);
    print Dumper($res);
  }
}

sub Clean {
  my %args = @_;
  my @l = split /\n/, $args{XML};
  shift @l;
  shift @l;
  return join("\n",@l);
}


