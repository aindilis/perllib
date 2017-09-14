package PerlLib::Converter;

use PerlLib::HTMLConverter;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / HTMLConverter / ];

sub init {
  my ($self,%args) = @_;
}

sub Convert {
  my ($self,%args) = @_;
  # for now just convert
  my $outputtype = $args{OutputType} || "text";
  my $file = $args{File};
  return unless $file and -f $file;
  my $result = `file $file`;
  chomp $result;
  # FIXME to be proper temp files instead of convert
  %table = (
	    "DjVu" => "djvutxt FILE > /tmp/convert.txt",
	    "PDF" => "ccp FILE /tmp/convert.txt",
	    "Microsoft Office Document" => "wvText FILE /tmp/convert.txt",
	    "PostScript" => "ccp FILE /tmp/convert.txt",
	    "English text" => "cp FILE /tmp/convert.txt",
	    "HTML document text" => "w3m -T text/html -dump FILE > /tmp/convert.txt",
	   );
  # "text" => q{lynx --force-html -dump -nolist FILE | perl -pe 's/\[[^\]]+\]//g'},
  $command = "";
  my $success = 0;
  foreach my $regex (keys %table) {
    if ($result =~ /$regex/) {
      $command = $table{$regex};
      $success = 1;
    }
  }
  if ($success) {
    $command =~ s/FILE/$file/;
    system $command;
    $contents = `cat /tmp/convert.txt`;
  }
  if (!$contents and $file =~ /\.html?/i) {
    my $htmlcontents = `cat \"$file\"`;
    $contents = $self->Preprocess(Contents => $htmlcontents);
    my $OUT;
    open(OUT,">/tmp/convert.txt") and print OUT $contents and close(OUT);
  }
  return "/tmp/convert.txt";
}

sub Preprocess {
  my ($self,%args) = (shift,@_);
  if (! defined $self->HTMLConverter) {
    $self->HTMLConverter(PerlLib::HTMLConverter->new());
  }
  my $txt = $self->HTMLConverter->ConvertToTxt
    (Contents => $args{Contents});
  $txt =~ s/\P{IsASCII}/ /g;
  return $txt;
}

1;
