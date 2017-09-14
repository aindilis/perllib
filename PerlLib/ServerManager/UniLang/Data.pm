package PerlLib::ServerManager::UniLang::Data;

# see also

# PerlLib::ServerManager::UniLang::Agent;
# PerlLib::ServerManager::UniLang::Client;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Entries /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Entries
    ({
      "Org-FRDCSA-Capability-SpeechActClassification" =>
      {
       AgentName => "Org-FRDCSA-Capability-SpeechActClassification",
       ModuleName => "Capability::SpeechActClassification",
       ModuleFile => "/var/lib/myfrdcsa/codebases/internal/perllib/Capability/SpeechActClassification.pm",
      },
      "Org-FRDCSA-System-FactualStatementExtractor" =>
      {
       AgentName => "Org-FRDCSA-System-FactualStatementExtractor",
       ModuleName => "System::FactualStatementExtractor",
       ModuleFile => "/var/lib/myfrdcsa/codebases/internal/perllib/System/FactualStatementExtractor.pm",
      },
      "Org-FRDCSA-System-Cyc" =>
      {
       AgentName => "Org-FRDCSA-System-Cyc",
       ModuleName => "System::Cyc",
       ModuleFile => "/var/lib/myfrdcsa/codebases/internal/perllib/System/Cyc.pm",
      },
     });
}

sub Item {
  my ($self,%args) = @_;

}

1;
