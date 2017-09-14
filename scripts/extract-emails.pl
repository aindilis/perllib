#!/usr/bin/perl -w

use BOSS::Config;
use KBS2::Util;
use PerlLib::SwissArmyKnife;
use PerlLib::ToText;
use Regexp::Common qw[Email::Address];
use Email::Address;

$specification = q(
	-i <item>...	Item to process

	-r		Recursively process dirs

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

my $verbose = 0;

my @list;
push @list, @{$conf->{'-i'} || []};
push @list, @{$conf->{'-o'} || []};

my $emails = {};
foreach my $tmpitem (@list) {
  print "<1: $tmpitem>\n" if $verbose;
  my $data;
  my @files;
  if (-d $tmpitem) {
    push @files, @{ListFilesInDirectoryRecursively(Dirs => [$tmpitem])};
  } else {
    push @files, $tmpitem;
  }
  foreach my $item (@files) {
    print "<2: $item>\n" if $verbose;
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

    # now extract all the emails there
    my $text = $data || '';
    foreach $line (split /\n/, $text) {
      $line =~ s/\s+/ /sg;
      print "<$line>\n" if $verbose;
      my (@found) = $line =~ /($RE{Email}{Address})/g;
      my (@addrs) = map $_->address,
	Email::Address->parse("@found");
      foreach my $addr (@addrs) {
	$emails->{$addr} = 1;
      }
    }

    # foreach (split /\n/, $data) {
    #   $_ =~ s/^\s*//;
    #   $_ =~ s/\s*$//;
    #   print "<$_>\n";
    #   my (@found) = /($RE{Email}{Address})/g;
    #   my (@addrs) = map $_->address,
    # 	Email::Address->parse("@found");
    #   foreach my $addr (@addrs) {
    # 	$emails->{$addr} = 1;
    #   }
    # }
  }
}
my $res = [sort keys %$emails];
if (exists $conf->{'--emacs'}) {
  print "'".PerlDataStructureToStringEmacs
    (
     DataStructure => $res,
    );
} else {
  # if ($conf->{'-c'}) {
  #   print "# $item\n";
  # }
  if (exists $conf->{'-f'}) {
    print join("\n",@$res)."\n";
  } else {
    print Dumper($res);
  }
}

