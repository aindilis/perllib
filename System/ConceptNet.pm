package System::ConceptNet;

use XMLRPC::Lite;
use Data::Dumper;

# xmlrpc info at
# http://ailab.ru.is/projects/bilskursgervigreind/hugbunadur/conceptnet01.html

# guess_mood, guess_topic, get_analogous_concepts

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Proxy  /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Proxy($args{Proxy} || "http://localhost:8000");
}

sub StartServer {
  my ($self,%args) = @_;
  # if the server has not been started, we can start an instance here
  # just need to run the command "conceptnetserver"
}

sub GuessMood {
  my ($self,%args) = @_;
  XMLRPC::Lite
      -> proxy($self->Proxy)
	-> call('guess_mood',($args{Text}))
	  -> result;
}

sub SummarizeDocument {
  my ($self,%args) = @_;
  XMLRPC::Lite
      -> proxy($self->Proxy)
	-> call('summarize_document',($args{Text}))
	  -> result;
}

sub GuessTopic {
  my ($self,%args) = @_;
  XMLRPC::Lite
      -> proxy($self->Proxy)
	-> call('guess_topic',($args{Text}))
	  -> result;
}

sub GuessConcept {
  my ($self,%args) = @_;
  XMLRPC::Lite
      -> proxy($self->Proxy)
	-> call('guess_concept',($args{Text}))
	  -> result;
}

sub GetAnalogousConcepts {
  my ($self,%args) = @_;
  XMLRPC::Lite
      -> proxy($self->Proxy)
	-> call('get_analogous_concepts',($args{Text}))
	  -> result;
}

sub GetContext {
  my ($self,%args) = @_;
  XMLRPC::Lite
      -> proxy($self->Proxy)
	-> call('get_context',($args{Text}))
	  -> result;
}

sub GetJist {
  my ($self,%args) = @_;
}

sub TestAllKnownFeatures {
  my $text = `cat script`;
  # figure out how to send these queries
  # possible jisting using generate_extraction
  # def lemmatise(self,text):
  # def chunk_and_lemmatise(self,text):
  # def chunk(self,text):
  # def tag(self,text):
  $self->GuessMood(Text => $text);
  $self->SummarizeDocument(Text => $text);
  $self->GuessTopic(Text => $text);
  $self->GuessConcept(Text => $text);
  $self->GetAnalogousConcepts(Text => $text);
  $self->GetContext(Text => $text);
  $self->GetJist(Text => $text);
}

1;
