package Capability::Extraction::HTML::Banners;

use HTML::Parser;

use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Stream /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Stream([]);
}

sub Extract {
  my ($self,%args) = @_;
  my @stream;
  my @stream1;
  my $p = HTML::Parser->new
    (
     api_version => 3,
     start_h => [ sub {
		    my $start = shift;
		    if ($start =~ /<img /i) {
		      push @{$self->Stream}, $start;
		    }
		  },
		  "text"
		],
     unbroken_text => 1,
     utf8_mode => 1,
     marked_sections => 1,
    );

  my $html = read_file("sample.html");
  $p->parse($args{HTML});
  $p->eof;

  my $res = $self->CalculateAcceptableRatios();
  my $max = $res->{Max};
  my $min = $res->{Min};

  my @results;
  foreach my $item (@{$self->Stream}) {
    my ($width, $height);
    if ($item =~ /\bwidth\s*=\s*"?(\d)"?/) {
      $width = $1;
    }
    if ($item =~ /\bheight\s*=\s*"?(\d)"?/) {
      $height = $1;
    }
    if (defined $width and defined $height) {
      my $ratio = $width / $height;
      # print "$ratio $min $max\n";
      if ($ratio >= $min and $ratio <= $max) {
	if ($item =~ / src\s*=\s*\"(.+?)\"\s*/) {
	  my $src = $1;
	  push @results, $src;
	}
      }
    }
    # standard banner sizes
  }
  return {
	  Success => 1,
	  Result => \@results,
	 };
}

sub CalculateAcceptableRatios {
  my ($self,%args) = @_;
  my $banners =
    {
     Standard =>
     [
      [468, 60,  "Full Banner"],
      [728, 90,  "Leaderboard"],
      # [336, 280, "Square"],
      # [300, 250, "Square"],
      # [250, 250, "Square"],
      # [160, 600, "Skyscraper"],
      # [120, 600, "Skyscraper"],
      # [120, 240, "Small Skyscraper"],
      # [240, 400, "Fat Skyscraper"],
      [234, 60,  "Half Banner"],
      # [180, 150, "Rectangle"],
      # [125, 125, "Square Button"],
      # [120, 90,  "Button"],
      # [120, 60,  "Button"],
      # [88, 31,   "Button"],
     ],
     Nonstandard =>
     [
      [120, 30,  "Button"],
      [230, 33,  "Small Banner"],
      [728, 210, "Large Leaderboard"],
      [720, 300, "Large Leaderboard"],
      # [500, 350, "Pop-up"],
      # [550, 480, "Pop-up"],
      # [300, 600, "Half Page Banner"],
      # [94, 15,   "Blog Button"],
     ],
    };
  my $max = 0;
  my $min = 1000;
  foreach my $key (keys %$banners) {
    foreach my $banner (@{$banners->{$key}}) {
      my $ratio = $banner->[0] / $banner->[1];
      if ($ratio > $max) {
	$max = $ratio;
      }
      if ($ratio < $min) {
	$min = $ratio;
      }
    }
  }
  # ratio Dumper([$max,$min]);
  return {
	  Max => $max,
	  Min => $min,
	 };
}

1;
