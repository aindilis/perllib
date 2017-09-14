package System::Wiki::Page;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Contents  /

  ];

sub init {
  my ($self,%args) = @_;
  # are we using a template or generating one from scratch

}

sub CopyDocbookTemplateFiles {
  my ($self,%args) = @_;

}

sub BetterGenerateReport {
  my ($self,%args) = @_;
  my $c = `cat "$templatedir/$root.template"`;
  my @code;
  foreach my $line (split /\n/, $c) {
    if ($line =~ /^\s*\%\s*(.*)$/) {
      push @code, $1;
    } else {
      # this is part of a print
      my @res = split /(\<\%|\%\>)/, $line;
      my @result;
      while (my $item = shift @res) {
	if ($item eq "\<\%") {
	  my $t = shift @res;
	  push @result, "$t .";
	} elsif ($item eq "\%\>") {

	} else {
	  # $item =~ s/([^\s\w])/\\$1/g;
	  $item =~ s/\'/\\\'/g;
	  push @result, "'$item' .";
	}
      }
      push @code, "\$result .= ".join("",(@result,"\"\\n\";"));
    }
  }
  push @code, "return \$result;";
  my $code = join("\n",@code);
  my $output = eval $code;
  if (1) {
    my $OUT;
    open (OUT, ">$destdir/$root.xml") or die "cannot open xml file for writing\n";
    print OUT $output;
    close(OUT);
  }
}

sub BuildReport {
  my ($self,%args) = @_;
  # build the report
  system "cd $destdir && make clean";
  system "cd $destdir && make";
  system "gv $destdir/$root.ps";
}

sub ConvertToWiki {
  my ($self,%args) = @_;
  # ensure that the document has been generated and an html file exists

  my $htmlfile = "";
  # generate a wiki output from the docbook
  # use the HTML to wiki converter


  # upload the wiki to the website using mvs
}


1;
