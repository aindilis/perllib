package Capability::LogicForm::Engine::FreeLogicForm;

use Capability::WSD::UniLang::Client;
use LF;
use System::Enju::UniLang::Client;

use Data::Dumper;
use Lingua::EN::Sentence qw(get_sentences);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Name Engine MyEnju MyWSD MyLF Debug /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyEnju
    (System::Enju::UniLang::Client->new
     (
      Fast => $args{Fast},
     ));
  $self->MyLF
    (LF->new());
}

sub StartServer {
  my ($self,%args) = @_;
  $self->MyEnju->StartEnju
    (%args);
}

sub StartClient {
  my ($self,%args) = @_;

}

sub LogicForm {
  my ($self,%args) = @_;
  my @results;
  my $sentences = get_sentences($args{Text});
  foreach my $sentence (@$sentences) {
    my $formalism =
      $self->MyEnju->ApplyEnjuToSentence
	(
	 Sentence => $sentence,
	);
    print Dumper($formalism) if $self->Debug;
    if (! defined $self->MyWSD) {
      $self->MyWSD
	(Capability::WSD::UniLang::Client->new());
    }
    my $wsd;
    if ($args{WSD}) {
      $wsd = $self->MyWSD->ProcessSentence
	(
	 Sentence => $sentence,
	);
    }
    push @results, $self->ProcessFormalism
      (
       Sentence => $sentence,
       Formalism => $formalism,
       WSD => $wsd,
       Type => $args{Type},
      );
  }
  return {
	  Success => 1,
	  Result => \@results,
	 };
}

sub ProcessFormalism {
  my ($self,%args) = @_;
  my $formalism = $args{Formalism};
  if ($formalism->{Fail}) {
    return $formalism;
  } else {
    return $self->MyLF->LogicFormOfSentence
	    (
	     Sentence => $args{Sentence},
	     Formalism => $formalism->{Result},
	     WSD => $args{WSD},
	     Type => $args{Type},
	    );
  }
}

1;
