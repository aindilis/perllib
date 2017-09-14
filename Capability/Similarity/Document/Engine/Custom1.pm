package Capability::Similarity::Document::Engine::Custom1;

use Capability::NER;

use Data::Dumper;
use File::Slurp;
use HTML::Table;
use IO::File;
use Lingua::EN::StopWords qw(%StopWords);
use Lingua::EN::Tagger;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw/ Options Projects TargetDocuments MyTagger StorageFiles MyNER
   MySayer SourceDocuments Phrases /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Options($args{Options} || {});

  $self->MyTagger(Lingua::EN::Tagger->new);
  $self->Phrases({});
  $self->SourceDocuments({});
  if (exists $self->Options->{Advanced}) {
    $self->MyNER
      (Capability::NER->new
       (Engine => "Stanford"));
    $self->MySayer
      (DBName => "sayer_document_similarity");
  }
  $self->StorageFiles({});
}

sub CreateProject {
  my ($self,%args) = @_;
  my $dir = $UNIVERSAL::systemdir."/data/document-similarity/projects/".$args{ProjectName};
  if (! -d $dir) {
    mkdir $dir;
  }
  my $fh = IO::File->new;
  if ($fh->open("> $dir/files")) {
    print $fh join("\n", @{$args{SourceDocuments}});
    $fh->close;
  } else {
    die "Cannot open $dir/$files\n";
  }
}

sub MatchTargetDocuments {
  my ($self,%args) = @_;
  my $errors = {};
  $self->LoadProjects
    (
     Projects => $args{Projects},
    );
  # exit unless sourcedocuments and projects
  if (! scalar @{$self->Projects}) {
    $errors->{"No projects"} = 1;
  }
  $self->TargetDocuments($args{TargetDocuments} || []);
  if (! scalar @{$self->TargetDocuments}) {
    $errors->{"No sourcedocuments"} = 1;
  }
  if (scalar keys %$errors) {
    print "Errors, can't match sourcedocuments.\n";
    return $errors;
  }
  print Dumper({ProjectsLoaded => [keys %{$self->SourceDocuments}]});
  my $results = {};
  foreach my $project (@{$self->Projects}) {
    print "Matching TargetDocuments\n";
    my $sourcedocumenturi = "http://frdcsa.org";
    foreach my $sourcedocumentfile (@{$self->TargetDocuments}) {
      my $date = `date "+%Y%m%d-%H%M%S"`;
      chomp $date;
      my $outputlocation = $sourcedocumentfile;
      $outputlocation =~ s/^.*\///;
      $outputlocation = "$UNIVERSAL::systemdir/data/document-similarity/projects/$project/$outputlocation-$date.html";

      print Dumper
	($self->GetDoc
	 (
	  File => $sourcedocumentfile,
	  Type => "sourcedocument",
	 ));
      print "Done\n";
      # now we need to find similar documents
      my $res = $self->ProcessSourceDocument
	(
	 Save => $args{Save},
	 User => $args{User},
	 SourceDocumentFile => $sourcedocumentfile,
	 SourceDocumentURI => $sourcedocumenturi,
	 OutputLocation => $outputlocation,
	 Projects => $args{Projects},
	);
      if ($res->{Success}) {
	$results->{$project}->{$sourcedocumentfile} = $res->{Result};
	if ($args{Save}) {
	  $results->{$project}->{$sourcedocumentfile}->{OutputLocation} = $outputlocation;
	}
      }

    }
  }
  return {
	  Success => 1,
	  Result => $results,
	 };
}

sub LoadProjects {
  my ($self,%args) = @_;
  $self->Projects($args{Projects} || []);

  if (! scalar @{$self->Projects}) {
    print "No projects!\n";
    return;
  }
  foreach my $project (@{$self->Projects}) {
    print "Loading project: $project\n";
    if (! exists $self->SourceDocuments->{$project}) {
      $self->StorageFiles->{$project} = "$UNIVERSAL::systemdir/data/document-similarity/projects/$project/storage.dat";
      my $mustload = 0;
      if (-f $self->StorageFiles->{$project}) {
	# load $self->StorageFiles->{$project}
	my $storagefile = $self->StorageFiles->{$project};
	my $c = read_file($storagefile);
	$VAR1 = undef;
	eval $c;
	$self->SourceDocuments->{$project} = $VAR1;
	$VAR1 = undef;

	# now check that we don't have to load
	my @files = split /\n/, read_file($UNIVERSAL::systemdir."/data/document-similarity/projects/$project/files");
	# print Dumper(\@files);
	if (exists $args{Tiny}) {
	  @files = splice @files,0,100;
	}
	my $matches = {};
	foreach my $file (keys %{$self->SourceDocuments->{$project}}) {
	  $matches->{$file}++;
	}
	foreach my $file (@files) {
	  $matches->{$file}++;
	}
	foreach my $key (keys %$matches) {
	  if ($matches->{$key} != 2) {
	    print "MISMATCH: $key\n";
	    $mustload = 1;
	    # last;
	  }
	}
      } else {
	$mustload = 1;
      }
      if ($mustload) {
	print "Must load!\n";
	my $old = $self->SourceDocuments->{$project};
	$self->SourceDocuments->{$project} = {};
	my @files = split /\n/, read_file($UNIVERSAL::systemdir."/data/document-similarity/projects/$project/files");
	if (exists $args{Tiny}) {
	  @files = splice @files,0,100;
	}
	foreach my $file (@files) {
	  if (-f $file) {
	    if (exists $old->{$file}) {
	      print "using existing: $file\n";
	      $self->SourceDocuments->{$project}->{$file} = $old->{$file};
	    } else {
	      print "adding: $file\n";
	      $self->SourceDocuments->{$project}->{$file} =
		$self->GetDoc
		  (
		   File => $file,
		  );
	    }
	  }
	}
	my $OUT;
	open (OUT,">".$self->StorageFiles->{$project}) or die "Cannot write Storage file: ".$self->StorageFiles->{$project}."!\n";
	print OUT Dumper($self->SourceDocuments->{$project});
	close(OUT);
      }
      # now build the phrase index, so that we can find similar documents by phrases

      print "Building phrase index\n";
      foreach my $title (keys %{$self->SourceDocuments->{$project}}) {
	foreach my $phrase (keys %{$self->SourceDocuments->{$project}->{$title}}) {
	  $self->Phrases->{$phrase}->{$title} = 1;
	}
      }
      # remove phrases that are in every document
      my $num_docs = scalar keys %{$self->SourceDocuments->{$project}};
      foreach my $phrase (keys %{$self->Phrases}) {
	if ($num_docs == scalar keys %{$self->Phrases->{$phrase}}) {
	  delete $self->Phrases->{$phrase};
	}
      }
    }
  }
}

sub ProcessSourceDocument {
  my ($self,%args) = @_;
  my $file = $args{SourceDocumentFile};
  my $sourcedocumenturi = $args{SourceDocumentURI};
  my $outputlocation = $args{OutputLocation};

  my $res = $self->FindSimilar
    (
     File => $file,
     Projects => $args{Projects},
    );

  my $results = {};
  my @table;
  foreach my $title (sort {$res->{Scores}->{$b} <=> $res->{Scores}->{$a}} keys %{$res->{Scores}}) {
    my $uri = $title;
    my @row = (sprintf("%1.4f", $res->{Scores}->{$title}), sprintf("<a href=\"%s\">%s</a><br>",$uri,$uri), join(", ",sort keys %{$res->{SharedPhrases}->{$title}}));
    push @table, \@row;
    $results->{$title} = {
			  Score => $res->{Scores}->{$title},
			  URI => $uri,
			  SharedPhrases => $res->{SharedPhrases}->{$title},
			  Metadata => $res->{Metadata}->{$title},
			 };
  }
  if ($args{Save}) {
    my $OUT;
    open(OUT,">$outputlocation") or die "Cannot write sourcedocument analysis results to $outputlocation!\n";
    my $htmltable = HTML::Table->new
      (
       -align=>'center',
       -border=>1,
       # -bgcolor=>'lightblue',
       # -spacing=>0,
       # -padding=>0,
       # -style=>'color: blue',
       -evenrowclass=>'even',
       -oddrowclass=>'odd',
       -data=> \@table,
      );
    print OUT join("\n",
		   (
		    "<html>",
		    "<h3>Similar Documents</h3>",
		    "for ".($args{User} || "unknown user"),
		    $htmltable->getTable,
		    "</html>",
		   )
		  );
    close(OUT);
    print "Saved to $outputlocation\n";
  }
  return {
	  Success => 1,
	  Result => $results,
	 };
}

sub min {
  my ($a,$b) = @_;
  if ($a < $b) {
    return $a;
  }
  return $b;
}

sub FindSimilar {
  my ($self,%args) = @_;
  my $file = $args{File};
  my $doc = $self->GetDoc
    (
     File => $file,
     Type => "sourcedocument",
    );
  my $score = {};
  my $sharedphrases = {};
  my $metadata = {};
  $args{Measure} = "Jaccard";
  if ($args{Measure} eq "original") {
    foreach my $phrase (keys %$doc) {
      foreach my $title (keys %{$self->Phrases->{$phrase}}) {
	foreach my $project (@{$args{Projects}}) {
	  if (exists $self->SourceDocuments->{$project}->{$title}->{$phrase} and
	      exists $doc->{$phrase}) {
	    $score->{$title} += $self->SourceDocuments->{$project}->{$title}->{$phrase} * $doc->{$phrase};
	  } else {
	    $score->{$title} += 0;
	  }
	  $sharedphrases->{$title}->{$phrase} = 1;
	}
      }
    }
  } elsif ($args{Measure} eq "new") {
    my $doccount = scalar keys %$doc;

    # Here is the idea, we want to see how different a given document
    # is.  Whenever they share a term, the score increases, and
    # whenever they don't, the score decreases

    my $matches = {};
    foreach my $phrase (keys %$doc) {
      foreach my $title (keys %{$self->Phrases->{$phrase}}) {
	foreach my $project (@{$args{Projects}}) {
	  if (exists $self->SourceDocuments->{$project}->{$title}->{$phrase} and
	      exists $doc->{$phrase}) {
	    # $matches->{$title} += min($self->SourceDocuments->{$project}->{$title}->{$phrase},$doc->{$phrase});
	    $matches->{$title}++;
	  }
	  $sharedphrases->{$title}->{$phrase} = 1;
	}
      }
    }

    foreach my $project (@{$args{Projects}}) {
      foreach my $title (keys %{$self->SourceDocuments->{$project}}) {
	my $count = scalar keys %{$self->SourceDocuments->{$project}->{$title}};
	if (! defined $matches->{$title}) {
	  $score->{$title} = 0;
	} else {
	  if ($count > 0) {
	    # $score->{$title} = (2 * $matches->{$title}) / ($count + $doccount);
	    $score->{$title} = $matches->{$title};
	    $metadata->{$title} = {
				   Matches => $matches->{$title},
				   Count => $count,
				   DocCount => $doccount,
				  };
	  }
	}
      }
    }
  } elsif ($args{Measure} eq "Jaccard") {
    my $union = {};
    my $intersection = {};
    foreach my $phrase (keys %{$self->Phrases}) {
      my $xa = exists $doc->{$phrase};
      foreach my $title (keys %{$self->Phrases->{$phrase}}) {
	foreach my $project (@{$args{Projects}}) {
	  if (exists $self->SourceDocuments->{$project}->{$title}) {
	    my $xb = exists $self->SourceDocuments->{$project}->{$title}->{$phrase};
	    if ($xa or $xb) {
	      $union->{$title}++;
	      if ($xa and $xb) {
		$intersection->{$title}++;
		$sharedphrases->{$title}->{$phrase} = 1;
	      }
	    }
	  }
	}
      }
    }

    foreach my $project (@{$args{Projects}}) {
      foreach my $title (keys %{$self->SourceDocuments->{$project}}) {
	if (exists $union->{$title} and $union->{$title} > 0) {
	  $score->{$title} = $intersection->{$title} / $union->{$title};
	  $metadata->{$title} = {
				 Union => $union->{$title},
				 Intersection => $intersection->{$title},
				};
	} else {
	  $score->{$title} = 0;
	}
      }
    }
  }
  return {
	  Scores => $score,
	  SharedPhrases => $sharedphrases,
	  Metadata => $metadata,
	 };
}

sub GetDoc {
  my ($self,%args) = @_;
  my $file = $args{File};
  my $debug = $args{Debug};
  my $text = read_file($file);

  if (0) {
    print "Performing named entity detection\n" if $debug;
    my $nerresult = $self->MyNER->NERExtract(Text => $text);
    foreach my $entry (@$nerresult) {
      my $string = join(" ",@{$entry->[0]});
      $string =~ s/(\W)/\\$1/g;
      $text =~ s/$string/ /g;
    }
  }

  print "Getting noun phrases\n" if $debug;
  my $tagged_text = $self->MyTagger->add_tags( $text );
  my %nps = $self->MyTagger->get_noun_phrases($tagged_text);

  print "Building Dictionary\n" if $debug;
  my $doc = {};
  foreach my $origtoken (keys %nps) {
    my $token = $origtoken;
    $token =~ s/\W/ /g;
    $token =~ s/\s+/ /g;
    $token =~ s/^\s+//g;
    $token =~ s/\s+$//g;
    if (! exists $StopWords{$token}) {
      $doc->{lc($token)} = $nps{$origtoken};
    }
  }
  return $doc;
}

1;
