#!/usr/bin/perl -w

use Capability::TextClustering;
use Do::Misc::ListProcessor2;
use Manager::Misc::Light;

use Data::Dumper;

my $light = Manager::Misc::Light->new();
my $processor = Do::Misc::ListProcessor2->new();
my $clustering = Capability::TextClustering->new();

# now get some texts to cluster

my $todofile = "/home/andrewdo/to.do";
my $domain = $light->ParseDomainFile(DomainFile => $todofile);
my $res = $processor->ProcessDomainNew(Domain => $domain);
my $res2 = GetStrings(DataStructure => $res->{ReturnDomain});
if ($res2->{Success}) {
  my $strings = $res2->{Result};
  $clustering->AddTexts(Texts => $strings);
  $clustering->GetClusters;
}

sub GetStrings {
  my %args = @_;
  my $ds = $args{DataStructure};
  my @strings;
  my $ref = ref $ds;
  if ($ref eq "") {
    push @strings, $ds;
  } elsif ($ref eq "ARRAY") {
    foreach $item (@$ds) {
      my $res = GetStrings
	(
	 DataStructure => $item,
	);
      if ($res->{Success}) {
	push @strings, @{$res->{Result}};
      }
    }
  } elsif ($ref eq "HASH") {
    foreach $key (%$ds) {
      my $res = GetStrings
	(
	 DataStructure => $ds->{$key},
	);
      if ($res->{Success}) {
	push @strings, $key, @{$res->{Result}};
      }
    }
  }
  return {
	  Success => 1,
	  Result => \@strings,
	 };
}

# what do you think we should do - news stories, or how about unilang
# entries, or irc messages, hrm....  or we could do the Twitter stuff

# keep in mind we can use the same markup addition stuff as in
# Capability::TextClassification::Advanced

# just use the todo list stuff

