#!/usr/bin/perl -w

use BOSS::Config;
use KBS2::Util;
use PerlLib::SwissArmyKnife;
use PerlLib::ToText;
use PerlLib::URIExtractor2;

$specification = q(
	-i <item>...	Item to process
	-c		Print items in comment
	-f		Flat output (no Dumper)

	--emacs		Output for Emacs

	-o <item>...	Open in Firefox

);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;

die unless (exists $conf->{'-i'} or exists $conf->{'-o'});

my @list;
push @list, @{$conf->{'-i'}};
push @list, @{$conf->{'-o'}};

foreach my $item (@list) {
  my $data;
  if (-f $item) {
    my $totext = PerlLib::ToText->new();
    my $res = $totext->ToText(File => $item);
    if ($res->{Success}) {
      $data = $res->{Text};
    } else {
      $data = '';
    }
  } elsif ($item =~ /^(ftp|https?):\/\//) {
    # require LWP::Simple;
    # require HTTP::Cache::Transparent;
    # HTTP::Cache::Transparent::init
    # 	({
    # 	  BasePath => '/var/lib/myfrdcsa/codebases/minor/metasite-extractor/data/cache',
    # 	 });
    # $data = get( $item );

    require WWW::Mechanize;
    my $mech = WWW::Mechanize->new();
    $mech->get($item);
    $data = $mech->content();
  }

  # now extract all the links there
  my $res = ExtractURIs($data);
  if ($conf->{'-o'}) {
    my $fn = '/tmp/extract-links.txt';
    my $fh = IO::File->new();
    $fh->open(">$fn") or die "Ouch!\n";
    print $fh join("\n",@$res)."\n";
    $fh->close();
    my $command = '/var/lib/myfrdcsa/codebases/internal/akahige/scripts/launch-websites.pl -f '.shell_quote($fn);
    print $command;
    system $command;
  }
  if (exists $conf->{'--emacs'}) {
    print "'".PerlDataStructureToStringEmacs
      (
       DataStructure => $res,
      );
  } else {
    if ($conf->{'-c'}) {
      print "# $item\n";
    }
    if (exists $conf->{'-f'}) {
      print join("\n",@$res)."\n";
    } else {
      print Dumper($res);
    }
  }
}
