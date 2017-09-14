package System::YouTubeDL;

use BOSS::Config;
use Manager::Dialog qw();
use MyFRDCSA qw(ConcatDir);
use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / URLs /

  ];

sub init {
  my ($self,%args) = @_;
  $self->URLs({});
}

sub GetURL {
  my ($self,%args) = @_;
  my $entry = {};
  # Grianan Aileach 4%28%10 (Windy Day)
  # Grianan_Aileach_4_28_10_Windy_Day-MLXML9ETKqs.flv
  my $titlecommand = "youtube-dl -e -b ".shell_quote($args{URL});
  my $title = `$titlecommand`;
  print "$title\n";
  chomp $title;
  $entry->{Title} = $title;
  my $titlecopy = $title;
  $titlecopy =~ s/\(//g;
  $titlecopy =~ s/\)//g;
  $titlecopy =~ s/\W/_/g;
  $titlecopy =~ s/_+/_/g;
  my $projectname = $titlecopy;
  my $urlcopy = $args{URL};
  $urlcopy =~ s/^.+=//;
  my $filename = $titlecopy."-".$urlcopy.".mp4";
  $entry->{Filename} = $filename;
  $self->URLs->{$args{URL}} = $entry;
  # my $convertedfilename = $titlecopy."-".$urlcopy.".avi";
}

sub GetTitle {
  my ($self,%args) = @_;
  if (! defined $self->URLs->{$args{URL}}) {
    $self->GetURL(URL => $args{URL});
  }
  return $self->URLs->{$args{URL}}->{Title};
}

sub GetFilename {
  my ($self,%args) = @_;
  if (! defined $self->URLs->{$args{URL}}) {
    $self->GetURL(URL => $args{URL});
  }
  return $self->URLs->{$args{URL}}->{Filename};
}

sub DownloadURLAndReturnFilename {
  my ($self,%args) = @_;
  if (! defined $self->URLs->{$args{URL}}) {
    $self->GetURL(URL => $args{URL});
  }
  my $videodownloadcommand = "youtube-dl -bt ".shell_quote($args{URL});
  print $videodownloadcommand;
  system $videodownloadcommand;
  return {
	  Success => 1,
	  Result => $self->GetFilename,
	 };
}

1;
