package System::Liferea;

use Capability::TextAnalysis;
use Manager::Dialog qw(Approve);
use PerlLib::ToText;
use System::Liferea::Feed;

use Data::Dumper;
use DateTime;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / FeedCacheDir Feeds MyTextAnalysis MyToText /

  ];

sub init {
  my ($self,%args) = @_;
  $self->FeedCacheDir
    ($args{FeedCacheDir} ||
     "/var/lib/myfrdcsa/codebases/internal/perllib/data/liferea-feeds");
  # make sure liferea is down if we are going to edit these files
  $self->Feeds({});
  $self->MyTextAnalysis
    (Capability::TextAnalysis->new
     (DBName => "sayer_liferea"));
  $self->MyTextAnalysis->Skip->{SemanticAnnotation} = 1;
  $self->MyToText
    (PerlLib::ToText->new);
}

sub LoadFeeds {
  my ($self,%args) = @_;
  my $feedcachedir = $self->FeedCacheDir;
  foreach my $file (split /\n/, `ls "$feedcachedir"`) {
    my $wholefile = $self->FeedCacheDir."/".$file;
    print "<$wholefile>\n";
    my $contents = `cat "$wholefile"`;
    $self->Feeds->{$wholefile} = System::Liferea::Feed->new
      (
       Filename => $wholefile,
       Contents => $contents,
      );
    $self->Feeds->{$wholefile}->Parse;
    my $items = $self->Feeds->{$wholefile}->Parsed->{item};
    if (ref $items eq "HASH") {
      foreach my $key (keys %$items) {
	my $item = $items->{$key};
	my $res = $self->MyToText->ToText
	  (String => $item->{description});
	if (exists $res->{Success}) {
	  my $epoch = $item->{time};
	  $dt = DateTime->from_epoch( epoch => $epoch );
	  if ($args{BuildCorpus}) {
	    print $res->{Text}."\n";
	  } else {
	    my $res = $self->MyTextAnalysis->AnalyzeText
	      (
	       Text => $res->{Text},
	       Date => $dt->year."-".$dt->month."-".$dt->day,
	      );
	    print Dumper($res);
	    my $it = <STDIN>;
	  }
	}
      }
    }
    # I guess we should have an agent which interacts with CLEAR? or
    # how should this work?
    # we can have a command line option for clear
  }
}

1;
