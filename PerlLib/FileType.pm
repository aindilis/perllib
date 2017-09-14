package PerlLib::FileType;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / Type / ];

sub init {
  my ($self,%args) = @_;
}

sub FileType {
  my ($self,%args) = @_;
  my $f = $args{File};
  my $res = `file "$f"`;
  chomp $res;
  if ($res =~ /^(.*): (.*)$/) {
    $self->Type($2);
    print $self->Type."\n";
  }
}

sub FingerPrint {
  my ($self,%args) = @_;
}

sub ApplicationType {
  my ($self,%args) = @_;
  # what are the various types it could be
  # text, non-text
}

sub ConvertTo {
  my ($self,%args) = @_;
  # convert the file to some type using CCP or similar
  # get the clear tech here
}

sub IsIt {
  my ($self,%args) = @_;
  # a movie? a text file?
}

1;
