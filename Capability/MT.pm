package Capability::MT;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / /

  ];

sub init {
  my ($self,%args) = @_;

}

sub TranslateBetweenPairs {
  my ($self,%args) = @_;
  if (! $args{Engine} or $args{Engine} eq "Lingua::Translate") {
    require Rival::Lingua::Translate;
    my $xl8r = Rival::Lingua::Translate->new
      (
       src => $args{From},
       dest => $args{To},
      )
      or die "No translation server available for $args{From} -> $args{To}.\n";
    return {
	    Result => "success",
	    Contents => $xl8r->translate
	    (
	     $args{Text},
	     RareToken => $args{RareToken},
	    ),
	   };
  } elsif ($args{Engine} eq "System::Apertium") {
    # don't add this for now
  }
}


1;
