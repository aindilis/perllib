package System::SuperSenseTagger;

use Capability::POSTagging;

use Data::Dumper;
use IO::File;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyTagger /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyTagger(Capability::POSTagging->new);
}

sub SenseTag {
  my ($self,%args) = @_;
  my $text = $args{Text};
  # first we need to pos tag the text

  my $tagged_text = $self->MyTagger->Tag
    (
     Text => $text,
     Style => "supersensetagger",
    );
  # print Dumper($tagged_text);

  my $fh = IO::File->new("> /var/lib/myfrdcsa/sandbox/sst-1.0/sst-1.0/SST-1.0/SST-1.0/DEMO/TEST.POS");
  print $fh $tagged_text;
  system "cd /var/lib/myfrdcsa/sandbox/sst-1.0/sst-1.0/SST-1.0/SST-1.0 && ./sst tag demo_run WNSS_DEFAULT ./DEMO/TEST.POS WNSS";
  my $res = `cat /var/lib/myfrdcsa/sandbox/sst-1.0/sst-1.0/SST-1.0/SST-1.0/DEMO/TEST.WNSS_SST`;
  print Dumper($res);
  $self->ProcessResults(Result => $res);
}

sub ProcessResults {
  my @entries;
  foreach my $line (split /\n/, $args{Result}) {
    my @items = split /\t/, $line;
    shift @items;
    my @sentence;
    foreach my $item (@items) {
      if ($item =~ /^(.+)\s+([A-Z,.():\$]+)\s+(.+)$/) {
	my $word = $1;
	my $pos = $2;
	my $class = $3;
	my $classdata = {
			 0 => 1,
			};
	if ($class =~ /^([A-Z])-(\w+).(\w+)$/) {
	  $classdata = {
			ClassLetter => $1,
			ClassPOS => $2,
			ClassModifier => $3,
		       };
	  delete $classdata->{0};
	}
	push @sentence, {
			 Word => $word,
			 POS => $pos,
			 Class => $classdata,
			};
      }
    }
    push @entries, \@sentence;
  }
  return {
	  Success => 1,
	  Result => \@entries,
	 };
}

1;
