#!/usr/bin/perl -w

use BOSS::Config;
use PerlLib::SwissArmyKnife;
use PerlLib::ToText;
use System::WWW::Linkipedia;

$specification = q(
	-u <url>		URL to process
	-h <htmlfile>		HTML filename to process
	-t <textfile>		Text filename to process
);

# FIXME: this query killed it

# ./test-system-www-linkipedia.pl -t ../System/WWW/Linkipedia/longer.txt

# First, because the links on the far left are not working, please see the repositories of software. Also, in order to see previous articles in the system, just do a search for 'the' in the left column. The www.frdcsa.org site is fundamentally broken and will be replaced with a new dynamic site based on Perl Catalyst , in which web services will be available to users to demo the capabilities of the FRDCSA. 2012 has been a year of solid employment, and I am now in position to have some financial resources for accomplishing some of the objectives of the project. I am saving up the requisite funds to pay for a period of development wherein the FRDCSA itself is finally released . I have also been able to obtain server equipment and many areas of the project are now feeling a new breath of freedom. However, with employment, there hasn't been any time to develop the software itself, however, I am learning many techniques such as Moose and Catalyst which will come in handy for the revised FRDCSA and FRDCSA 2.0. Work has focused in a few areas. The Free Life Planning System has come along, and I've learned all about the field of practical reasoning and rational agency . To this end the Utility Maximization System is also being developed, in order to help improve the allocation of funds within the project and for those struggling to make ends meet. Many of the user level programs like Paperless Office are working well. There is work on integrating GDL-II with the Free Life Planner, and synthesizing a forward chaining expert system within the Datalog constructs. The rules for the life planner are being mined by natural language processing systems , and are tailored to extract rules based on logic form. NLU is an area of development. We now have a private cloud and are creating new virtual machines for various free software projects. This is the basis of the POSI groupware system , in which the POSI system is being reinvisioned in terms of Multi-Agent Epistemic Logic and other Dynamic/Action logics . There is a good paper in a previous Artificial Intelligence Magazine , called Logics for Multiagent Systems , which is very useful in covering alot of the areas I am focused on



my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
# $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";

my $totext = PerlLib::ToText->new();
my $t;
my $outputfilename = '/tmp/system-www-linkipedia.txt';
if ($conf->{'-u'}) {
  system 'wget '.shell_quote($conf->{'-u'}).' -O '.shell_quote($outputfilename);
  $conf->{'-h'} = $outputfilename;
}
if ($conf->{'-h'}) {
  my $res = $totext->ToText(UseBodyTextExtractor => 1, File => $conf->{'-h'});
  if ($res->{Success}) {
    $t = $res->{Text};
  }
} elsif ($conf->{'-t'}) {
  $t = read_file($conf->{'-t'});
}
$t =~ s/<[^\>]+?>/ /sg;
$t =~ s/[^[:ascii:]]/ /sg;
$t =~ s/\s+/ /sg;
$t =~ s/digg_url = .*?>//sg;
# $t =~ s/\W+/ /sg;
$t =~ s/^\s*//sg;
$t =~ s/\s*$//sg;

print Dumper($t);
# die;

if ($t) {
  my $linkipediaclient = System::WWW::Linkipedia->new();
  my $res = $linkipediaclient->Linkify(Query => $t);
  print Dumper($res);
} else {
  die "File must be specified with -f and exist.\n";
}

