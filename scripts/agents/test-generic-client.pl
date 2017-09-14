#!/usr/bin/perl -w

use PerlLib::ServerManager::UniLang::Client;
use PerlLib::ServerManager::UniLang::Data;

use Data::Dumper;

use BOSS::Config;

my $specification = q{
	-a <agentname>			The name of the Agent (e.g. Org-FRDCSA-System-Cyc)
};

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;

my $data = PerlLib::ServerManager::UniLang::Data->new;
my $agentname = $data->Entries->{$conf->{'-a'}};

$UNIVERSAL::client = PerlLib::ServerManager::UniLang::Client->new
  (
   AgentName => $agentname,
  );

$UNIVERSAL::client->StartServer();

$UNIVERSAL::client->Connect();

foreach my $function (sort keys %{$UNIVERSAL::client->FunctionNames}) {
  if ($function eq 'Query') {
    print "F: ".$function."\n";
    my $res = $UNIVERSAL::client->$function
      (
       Query => '(#$isa ?X #$Researcher)',
       Mt => 'EverythingPSC',
       OutputType => 'Perl Interlingua',
      );
    print Dumper($res);
  }
}
