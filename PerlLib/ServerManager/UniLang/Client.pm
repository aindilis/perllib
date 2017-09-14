package PerlLib::ServerManager::UniLang::Client;

use CodeMonkey::Parse::Perl;
use PerlLib::ServerManager::UniLang::Data;
use UniLang::Util::TempAgent;

use Data::Dumper;

# need to extract the function names, and then create new functions for each of these


use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyTempAgent Receiver MyPerl MyData FunctionNames /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyData
    (PerlLib::ServerManager::UniLang::Data->new);

  my $entry = $self->MyData->Entries->{$args{AgentName}};
  my $agentname = $entry->{AgentName};
  my $modulename = $entry->{ModuleName};
  my $modulefile = $entry->{ModuleFile};

  $self->MyTempAgent
    (UniLang::Util::TempAgent->new
     (
      RandName => $agentname."-Client",
     ));
  $self->Receiver($agentname);

  # extract all the function names (what, with PPI?) and be ready to
  # call them, as necessary
  $self->MyPerl(CodeMonkey::Parse::Perl->new);

  # go ahead and create the local functions
  my $localfunctions = $self->MyPerl->ExtractFunctions
    (
     File => "/var/lib/myfrdcsa/codebases/internal/perllib/PerlLib/ServerManager/UniLang/Client.pm",
    );
  my $takennames = {};
  foreach my $functionentry (@$localfunctions) {
    $takennames->{$functionentry->{Name}} = 1;
  }
  my $functions = $self->MyPerl->ExtractFunctions
    (
     File => $modulefile,
    );
  foreach my $functionentry (@$functions) {
    my $functionname = $functionentry->{Name};
    next if exists $takennames->{$functionname};
    my $newfunction = 'sub '.$functionname.' {
  my ($self,%args) = @_;
  my @res = $self->MyTempAgent->RPC
    (
     Receiver => $self->Receiver,
     _RPC_Sub => "'.$functionname.'",
     _RPC_Args => [%args],
    );
  return $res[0];
}';
    # go ahead and eval this into existence
    print 'Eval-ing '.$functionname."\n" if $UNIVERSAL::debug;
    $functionnames->{$functionname} = 1;
    eval $newfunction;
  }
  $self->FunctionNames($functionnames);
}

sub StartServer {
  my ($self,%args) = @_;
  my @res = $self->MyTempAgent->MyAgent->QueryAgent
    (
     Receiver => $self->Receiver,
     Data => {
	      StartServer => 1,
	      Fast => $args{Fast},
	     },
    );
  return $res[0];
}

1;
