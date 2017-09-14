package PerlLib::EasySayer;

use Sayer;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MySayer /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MySayer
    ($args{Sayer} ||
     Sayer->new
     (DBName => "sayer_perllib_easysayer"));
}

sub Do {
  my ($self,%args) = @_;
  my $sub = $args{_Sub};
  delete $args{_Sub};
  # print Dumper({Sub => $sub, Args => \%args});
  my @data = %args;
  my @res = $self->MySayer->ExecuteCodeOnData
      (
       Overwrite => $args{_Overwrite},
       CodeRef => $sub,
       Data => \@data,
      );
  return \@res;
}

1;
