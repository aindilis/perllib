package System::Cyc::Access;

# see System::Cyc

# to get to the part that is handled past UniLang, see System::Cyc::Java::CycAccess;

use PerlLib::ServerManager::UniLang::Client;
use PerlLib::ServerManager::UniLang::Data;
use PerlLib::SwissArmyKnife;

use Try::Tiny;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw (Query ConverseObject);

{
  my $entry = 'Org-FRDCSA-System-Cyc';
  my $data = PerlLib::ServerManager::UniLang::Data->new;
  my $agentname = $data->Entries->{$entry}->{AgentName};
  $UNIVERSAL::client = PerlLib::ServerManager::UniLang::Client->new
    (
     AgentName => $agentname,
    );
  $UNIVERSAL::client->StartServer();
  $UNIVERSAL::client->Connect();
}

sub Query {
  my ($query, $mt) = @_;
  my $res;
  try {
    $res = $UNIVERSAL::client->Query
      (
       Query => $query,
       Mt => $mt || 'EverythingPSC',
       OutputType => 'Interlingua',
      );
    return @{$res->{Result}};
  } catch {
    warn Dumper($_);
  };
}

sub ConverseObject {
  my ($subl) = @_;
  my $res;
  try {
    $res = $UNIVERSAL::client->ConverseObject
      (
       SubL => $subl,
       OutputType => 'Interlingua',
      );
  } catch {
    warn Dumper($_);
  };
  return $res;
}

1;
