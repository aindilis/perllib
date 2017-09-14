package Capability::NLP::TextCase;

use Capability::ILP;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Examples MyILP Programs /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Examples
    (
     {
      Capitalization =>
      [
       ['frdcsa','FRDCSA'],
       ['x11vnc','X11vnc'],
       ['x11vnc','X11vnc'],
      ],
      Downcasing =>
      [
       ['FRDCSA','frdcsa'],
       ['X11VNC','x11vnc'],
      ],
      Upcasing =>
      [
       ['frdcsa','FRDCSA'],
       ['x11vnc','X11VNC'],
      ],
      ToCamelCase =>
      [
       ['abriefhistoryoftime','ABriefHistoryOfTime'],
       ['a-brief-history-of-time','ABriefHistoryOfTime'],
       ['a_brief_history_of_time','ABriefHistoryOfTime'],
       ['aBriefHistoryOfTime','ABriefHistoryOfTime'],
      ],
      FromCamelCase =>
      [
       ['abriefhistoryoftime','ABriefHistoryOfTime'],
       ['a-brief-history-of-time','ABriefHistoryOfTime'],
       ['a_brief_history_of_time','ABriefHistoryOfTime'],
       ['aBriefHistoryOfTime','ABriefHistoryOfTime'],
      ],
      ToPrologCamelCase =>
      [
       ['abriefhistoryoftime','aBriefHistoryOfTime'],
       ['a-brief-history-of-time','aBriefHistoryOfTime'],
       ['a_brief_history_of_time','aBriefHistoryOfTime'],
       ['aBriefHistoryOfTime','aBriefHistoryOfTime'],
      ],
      FromPrologCamelCase =>
      [
       ['abriefhistoryoftime','ABriefHistoryOfTime'],
       ['a-brief-history-of-time','ABriefHistoryOfTime'],
       ['a_brief_history_of_time','ABriefHistoryOfTime'],
       ['aBriefHistoryOfTime','ABriefHistoryOfTime'],
      ],
     },
    );
  $self->MyILP
    (
     Capability::ILP->new(),
    );
  $self->Programs({});
}

sub Capitalize {
  my ($self,%args) = @_;
  $self->ApplyFunction
    (
     Function => 'Capitalizatin',
     %args,
    );
}

sub UpCase {
  my ($self,%args) = @_;
  $self->ApplyFunction
    (
     Function => 'Upcasing',
     %args,
    );
}

sub DownCase {
  my ($self,%args) = @_;
  $self->ApplyFunction
    (
     Function => 'Downcasing',
     %args,
    );
}

sub ToCamelCase {
  my ($self,%args) = @_;
  $self->ApplyFunction
    (
     Function => 'ToCamelCase',
     %args,
    );
}

sub FromCamelCase {
  my ($self,%args) = @_;
  $self->ApplyFunction
    (
     Function => 'FromCamelCase',
     %args,
    );
}

sub ApplyFunction {
  my ($self,%args) = @_;
  if (! exists  $self->Programs->{$args{Function}}) {
    if (exists $self->Examples->{$args{Function}}) {
      my $program = $self->MyILP->LearnProgramFromExamples
	(
	 Examples => $self->Examples->{$args{Function}},
	);
      $self->Programs->{$args{Function}} = $program;
    } else {
      FixMe('throw errow');
      die "No such function: <$args{Function}>\n";
    }
  }
  return $self->Programs->{$args{Function}}->(Text => $args{Text});
}

1;
