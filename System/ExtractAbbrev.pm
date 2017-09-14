package System::ExtractAbbrev;

use Data::Dumper;
use File::Temp;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Proxy  /

  ];

sub init {
  my ($self,%args) = @_;
}

sub ExtractAbbrev {
  my ($self,%args) = @_;
  # really, use random number generation here
  my $f = File::Temp->new;
  my $file = $f->filename;
  print $f $args{Text};
  # my $java = "/usr/lib/jvm/java-1.5.0-sun-1.5.0.10/bin/java";
  my %abbrev = map $self->ExtractAbbrevs($_),
    split /\n/,`cd /var/lib/myfrdcsa/codebases/internal/perllib/scripts/extract-abbrev && java ExtractAbbrev $file`;
  undef $f;
  return \%abbrev;
}

sub ExtractAbbrevs {
  my ($self,$txt) = (shift,shift);
  if ($txt =~ /(\S+)\s+(.*)/) {
    return ($1,$2);
  }
}

1;
