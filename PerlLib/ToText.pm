package PerlLib::ToText;

use PerlLib::RSSReader;
use PerlLib::HTMLConverter;
use PerlLib::ToText::StrangeCharacters;

use File::Temp;
use String::ShellQuote;

use utf8;
use Text::Unidecode;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw( RejectList QuotedOriginalFile MyDocData ParsedFile
       QuotedParsedFile CompressedParsedFile QuotedCompressedParsedFile
       HasBeenRead Order HTMLConverter MyVisualize Table InverseTable)

  ];

sub init {
  my ($self,%args) = @_;
  $self->RejectList($args{RejectList} || []);
  $self->Table
    ({
      # type => command
      "DjVu" => "djvutxt ORIGFILENAME > TEMPFILENAME",
      "English text" => "cp ORIGFILENAME TEMPFILENAME",
      "PDF" => "pdftotext OPTIONRAW ORIGFILENAME TEMPFILENAME",
      "Microsoft Office Document" => "wvText ORIGFILENAME TEMPFILENAME",
      "PostScript" => "ps2txt ORIGFILENAME TEMPFILENAME",
      "^UTF-8 Unicode text" => "cp ORIGFILENAME TEMPFILENAME",
      "EPUB document" => "ebook-convert ORIGFILENAME TEMPFILENAME.txt; mv TEMPFILENAME.txt TEMPFILENAME", # einfo -pp $1 | lynx -stdin -dump
      "Mobipocket E-book" => "ebook-convert ORIGFILENAME TEMPFILENAME.txt; mv TEMPFILENAME.txt TEMPFILENAME",
      "Lisp/Scheme program, UTF-8 Unicode text, with very long lines" => "cp ORIGFILENAME TEMPFILENAME",
      "Lisp/Scheme program, UTF-8 Unicode text" => "cp ORIGFILENAME TEMPFILENAME",
     });

  $self->InverseTable
    ({
      "w3m -T text/html MYOPTS -dump ORIGFILENAME > TEMPFILENAME" =>
      [
       "exported SGML document text",
       "HTML document text",
       "HTML document,",
       # "HTML document, ASCII text",
       # "HTML document, ISO-8859 text, with very long lines, with CR, LF line terminators",
       # "HTML document, Non-ISO extended-ASCII text, with CRLF line terminators",
       # "HTML document, UTF-8 Unicode text, with very long lines",
      ],
     });
  foreach my $command (keys %{$self->InverseTable}) {
    foreach my $type (@{$self->InverseTable->{$command}}) {
      $self->Table->{$type} = $command;
    }
  }
}

sub ToText {
  my ($self,%args) = @_;
  if ($args{UseBodyTextExtractor}) {
    foreach my $type (@{$self->InverseTable->{"w3m -T text/html MYOPTS -dump ORIGFILENAME > TEMPFILENAME"}}) {
      $self->Table->{$type} = "/var/lib/myfrdcsa/codebases/internal/clear/scripts/body-text-extractor.pl ORIGFILENAME > TEMPFILENAME";
    }
  } else {
    foreach my $type (@{$self->InverseTable->{"w3m -T text/html MYOPTS -dump ORIGFILENAME > TEMPFILENAME"}}) {
      $self->Table->{$type} = "w3m -T text/html -dump ORIGFILENAME > TEMPFILENAME";
    }
  }
  if ($args{String}) {
    if ($args{Unidecode}) {
      $args{String} = unidecode($args{String});
    } else {
      utf8::decode($args{String});
    }
    my $mystringfile = "/tmp/totext-string.html";
    my $OUT;
    open(OUT,">$mystringfile") or die "oops can't open $mystringfile\n";
    if ($args{String} !~ /<html>/i) {
      print OUT "<html>\n".$args{String}."\n</html>";
    } else {
      print OUT $args{String};
    }
    close(OUT);
    $args{File} = $mystringfile;
  }
  my $file = $args{File};
  my $quotedfile = shell_quote $file;
  if ($args{File} and -f $args{File}) {
    if (scalar @{$self->RejectList}) {
      my $regex = "\.(".join("|",@{$self->RejectList}).")\$";
      if ($file =~ /$regex/) {
	return {
		Failed => 1,
		FailureReason => "InRejectList",
	       };
      }
    }
    if ($file =~ /\.opml$/i) {
      my $rssreader = PerlLib::RSSReader->new(OPMLFile => $file);
      return {
	      Success => 1,
	      Text => $rssreader->GetContents,
	     };
    }

    my $fh = File::Temp->new(DIR => "/tmp");
    my $tempfilename = shell_quote $fh->filename;
    my $result;
    if ($args{Type}) {
      $result = $args{Type};
    } else {
      $result = `file $quotedfile`;
      chomp $result;
      $result =~ s/^.*: //;
      print "<RESULT: $result>\n" if $debug;
    }

    # if ($file =~ /\.fb2$/i) {
    #   if ($result =~ /XML document text/) {
    # 	# convert it
    # 	return {
    # 		Success => 1,
    # 		Text => 
    # 	       };
    # # 'ebook-convert ebook.fb2 out.txt', add to list, have qualifications
    #   }
    # }

    my @list = ("ASCII text","English text","program text","shell script","ISO-8859 text");
    foreach my $regex (@list) {
      if ($result =~ /$regex/) {
	# next if $result =~ /HTML document, ASCII text$/;
	next if $result =~ /HTML document, ASCII text\b/;
	my $text = `cat $quotedfile`;
	return {
		Success => 1,
		Text => $text,
	       };
      }
    }
    my $myopts = "";
    if ($args{Width}) {
      $myopts = "-cols ".$args{Width};
    }
    # "text" => q{lynx --force-html -dump -nolist FILE | perl -pe 's/\[[^\]]+\]//g'},
    $command = "";
    my $success = 0;
    # if (exists $self->Table->{$result}) {
    #   $command  = $self->Table->{$result};
    #   $success = 1;
    # } else {
    foreach my $regex (keys %{$self->Table}) {
      if ($result =~ /$regex/i) {
	$command = $self->Table->{$regex};
	$success = 1;
      }
    }
    # }
    if ($success) {
      $command =~ s/ORIGFILENAME/$quotedfile/g;
      $command =~ s/TEMPFILENAME/$tempfilename/g;
      $command =~ s/MYOPTS/$myopts/;
      if ($args{Raw}) {
	$command =~ s/OPTIONRAW/-raw/;
      } else {
	$command =~ s/OPTIONRAW/ /;
      }
      print "<COMMAND: $command>\n"  if $debug;
      system $command;
      $contents = `cat $tempfilename`;
      if (!$contents and $file =~ /\.html?/i) {
	my $htmlcontents = `cat $quotedfile`;
	$contents = $self->Preprocess(Contents => $htmlcontents);
      }

      if ($args{CleanStrangeCharacters}) {
	my $res = from_strange_characters(Text => $contents);
	$contents = $res->{Text};
      }
      # •
      # ©
      # s/’/'/sg;
      # s/ﬁ/fi/sg;
      # s/ﬂ/fl/sg;
      return {
	      Success => 1,
	      Text => $contents,
	     };
    }
    return {
	    Failure => 1,
	    FailureReason => $result,
	   };

  }
}

sub ListTypes {
  my ($self,%args) = @_;
  print join("\n", sort keys %{$self->Table})."\n";
}

sub Preprocess {
  my ($self,%args) = @_;
  if (! defined $self->HTMLConverter) {
    $self->HTMLConverter(PerlLib::HTMLConverter->new());
  }
  my $txt = $self->HTMLConverter->ConvertToTxt
    (Contents => $args{Contents});
  $txt =~ s/\P{IsASCII}/ /g;
  return $txt;
}

1;
