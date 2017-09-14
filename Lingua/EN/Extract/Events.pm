package Lingua::EN::Extract::Events;

use Capability::NER;
use Lingua::EN::Extract::Dates;

use Data::Dumper;
use File::Temp;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyDates MyNER /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyDates
    (Lingua::EN::Extract::Dates->new);
  $self->MyNER
    (Capability::NER->new);
}

sub GetEvents {
  my ($self,%args) = @_;
  # get the dates, then get location, and then get function name
  my $res = $self->MyDates->GetDatesTime3XML
    (Text => $args{Text});
  my $dates = $res->{Dates};
  my @sents;
  my @location;
  my @other;
  my @entities;
  foreach my $sentence (@{$res->{Sentences}}) {
    my $text = join (" ",@$sentence);
    my $match = 0;
    foreach my $entity (@{$self->MyNER->NERExtract
			    (Text => $text)}) {
      if ($entity->[1] =~ /(ORGANIZATION|LOCATION)/) {
	push @location, $text;
	$match = 1;
	last;
      }
      push @entities, $entity;
    }
    if (! $match) {
      push @other, $text;
    }
  }
  return {
	  Date => $dates,
	  Location => join("\n",@location),
	  Other => join("\n",@other),
	  Entities => \@entities,
	 };
}

1;
