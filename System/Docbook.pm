package System::Docbook;

use System::Wiki;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / SourceFile TemplateFile Root Source MakeDir /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Source
    ($args{Source});
  # are we using a template or generating one from scratch
  my $rootfile = $args{TemplateFile} || $args{SourceFile};
  my $root = "document";
  if ($rootfile and $rootfile =~ /\/([^\/]+)\.(template|xml)$/) {
    $root = $1;
  }
  $self->Root($root);
  $self->SourceFile($args{SourceFile});
  $self->TemplateFile($templatefile);
  $self->MakeDir($args{MakeDir} || "/tmp/docbook-make");
  if ($self->MakeDir and ! -d $self->MakeDir) {
    system "mkdirhier ".$self->MakeDir;
    my $makefile = "/var/lib/myfrdcsa/codebases/internal/perllib/System/Docbook/Makefile";
    my $c = `cat $makefile`;
    $c =~ s/report/$root/g;
    my $OUT;
    open(OUT,">".$self->MakeDir."/Makefile") or die "ouch!\n";
    print OUT $c;
    close(OUT);
  }
}

sub MakeDocument {
  my ($self,%args) = @_;
  if (! $self->Source) {
    if ($self->SourceFile) {
      my $sf = $self->SourceFile;
      my $c = `cat "$sf"`;
      $self->Source($c);
    } elsif ($self->TemplateFile) {
      if (-f $self->TemplateFile) {
	$self->Source($self->GenerateSourceFromTemplate)
      }
    }
  }
  if ($self->Source) {
    my $OUT;
    my $root = $self->Root;
    my $makedir = $self->MakeDir;
    open (OUT, ">$makedir/$root.xml") or die "cannot open xml file for writing\n";
    print OUT $self->Source;
    close(OUT);

    # build the report
    system "cd $makedir && make clean";
    system "cd $makedir && make";
    system "gv $makedir/$root.ps";
  }
}

sub GenerateSourceFromTemplate {
  my ($self,%args) = @_;
  my $templatefile = $self->TemplateFile;
  my $c = `cat "$templatefile"`;

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
  return $output;
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
