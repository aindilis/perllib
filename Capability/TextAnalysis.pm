package Capability::TextAnalysis;

use Capability::CoreferenceResolution;
use Capability::FactExtraction;
use Capability::NER;
use Capability::SpeechActClassification;
use Capability::TermExtraction;
use Capability::Tokenize;
use Capability::WSD;
use Lingua::EN::Extract::Dates;
use Manager::Misc::Light2;
use Sayer;
use System::KNext;
use System::MontyLingua;
use System::WWW::DBpediaSpotlight;
use System::WWW::Linkipedia;
use System::WWW::OpenCalais;
use UniLang::Util::TempAgent;

use Data::Dump::Streamer;
use Data::Dumper;
use Lingua::EN::Sentence qw(get_sentences);
use Lingua::EN::Tagger;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MySayer Codes Skip DontSkip MyDateExtract MyTagger MyNER
	MyOpenCalais MyDBpediaSpotlight MyMontyLingua Results Inits
	HasBeenInitialized MyCoref MyWSD MySpeechActClassifier
	MyTempAgent MyLight2 MyKNext IsCached AllResultsWereCached /

  ];

sub init {
  my ($self,%args) = @_;
  $UNIVERSAL::textanalysis = $self;

  $self->MySayer($args{Sayer} || Sayer->new(DBName => $args{DBName}));
  # $self->MySayer->Debug(1);

  $self->Inits
    ({
      DateExtraction => sub {
	my $self = shift;
	if (! defined $self->MyDateExtract) {
	  $self->MyDateExtract(Lingua::EN::Extract::Dates->new);
	}
      },
      GetDatesTIMEX3 => sub {
	my $self = shift;
	if (! defined $self->MyDateExtract) {
	  $self->MyDateExtract(Lingua::EN::Extract::Dates->new);
	}
      },
      NounPhraseExtraction => sub {
	my $self = shift;
	$self->MyTagger(Lingua::EN::Tagger->new);
      },
      NamedEntityRecognition => sub {
	my $self = shift;
	$self->MyNER(Capability::NER->new);
      },
      MontyLingua => sub {
	my $self = shift;
	$self->MyMontyLingua(System::MontyLingua->new);
	$self->MyMontyLingua->StartServer;
      },
      SemanticAnnotation => sub {
	my $self = shift;
	# my $type = "Text/HTML";
	my $type = "Text/Simple";

	$self->MyOpenCalais
	  (System::WWW::OpenCalais->new
	   (Type => $type));
      },
      DBpediaSpotlight => sub {
	my $self = shift;
	$self->MyDBpediaSpotlight(System::WWW::DBpediaSpotlight->new());
      },
      CoreferenceResolution => sub {
	my $self = shift;
	$self->MyCoref
	  (Capability::CoreferenceResolution->new);
	$self->MyCoref->StartServer;
      },
      WSD => sub {
	my $self = shift;
	$self->MyWSD
	  (Capability::WSD->new);
	$self->MyWSD->StartServer;
      },
      CycLsForNP => sub {
	my $self = shift;
	$self->MyLight2(Manager::Misc::Light2->new);
	$self->MyTempAgent
	  (UniLang::Util::TempAgent->new
	   (
	    RandName => "text-analysis",
	   ));
      },
      KNext => sub {
	my $self = shift;
	$self->MyKNext
	  (System::KNext->new
	   (
	    DontUseCommandLine => 1,
	    DontFormalize => 1,
	    Overwrite => 0,
	    ClearSayerCache => 0,
	    Debug => 0,
	    SplitBy => "every few sentences",
	   ));
      },
      Linkipedia => sub {
	my $self = shift;
	$self->MyLinkipedia
	  (System::WWW::Linkipedia->new());
      },
     });
  $self->HasBeenInitialized({});

  $self->Codes
    ({
      NounPhraseExtraction => sub {
	my $self = $UNIVERSAL::textanalysis;
	my $tagged_text = $self->MyTagger->add_tags
	  ( $_[0]->{Text} );
	return $self->MyTagger->get_noun_phrases
	  ($tagged_text);
      },
      NamedEntityRecognition => sub {
	my $self = $UNIVERSAL::textanalysis;
	$self->MyNER->NERExtract
	  (Text => $_[0]->{Text});
      },
      Tokenization => sub {
	tokenize_treebank
	  ($_[0]->{Text});
      },
      TermExtraction => sub {
	my $self = $UNIVERSAL::textanalysis;
	require Capability::TermExtraction;
	TermExtraction
	  (String => $_[0]->{Text});
      },
      SemanticAnnotation => sub {
	my $self = $UNIVERSAL::textanalysis;
	$self->MyOpenCalais->ProcessAndParse
	  (Contents => $_[0]->{Text});
      },
      DBpediaSpotlight => sub {
	my $self = $UNIVERSAL::textanalysis;
	my $res = $self->MyDBpediaSpotlight->ProcessTextWithDBpediaSpotlight
	  (
	   Text => $_[0]->{Text},
	  );
      },
      MontyLingua => sub {
	my $self = $UNIVERSAL::textanalysis;
	$self->MyMontyLingua->ApplyMontyLinguaToText
	  (Text => $_[0]->{Text});
      },
      DateExtraction => sub {
	my $self = $UNIVERSAL::textanalysis;
	$self->MyDateExtract->TimeRecognizeText
	  (
	   Text => $_[0]->{Text},
	   Date => $_[0]->{Date},
	  );
      },
      GetDatesTIMEX3 => sub {
	my $self = $UNIVERSAL::textanalysis;
	# process the data first, to remove 
	$self->MyDateExtract->GetDatesTIMEX3
	  (
	   Text => $_[0]->{Text},
	   Date => $_[0]->{Date},
	   Message => $_[0]->{Message} || 0,
	  );
      },
      FactExtraction => sub {
       	return FactExtraction(Text => $_[0]->{Text});
      },
      CoreferenceResolution => sub {
	my $self = $UNIVERSAL::textanalysis;
	$self->MyCoref->ReplaceCoreferences
	  (Text => $_[0]->{Text});
      },
      WSD => sub {
	my $self = $UNIVERSAL::textanalysis;
	$self->MyWSD->ProcessText
	  (Text => $_[0]->{Text});
      },
      SpeechActClassification => sub {
	my $self = $UNIVERSAL::textanalysis;
	$self->MySpeechActClassifier->GetSpeechActs
	  (Text => $_[0]->{Text});
      },
      CycLsForNP => sub {
	my $self = $UNIVERSAL::textanalysis;
	return ['test'];
	my $m = $self->MyTempAgent->MyAgent->QueryAgent
	  (
	   Receiver => "Cyc",
	   Data => {
		    SubLQuery => "(ps-get-cycls-for-np \"$item\")",
		    _DoNotLog => 1,
		   },
	  );
	print ClearDumper({MessageX => $m});
	# if (exists $m->Data->{Result}) {
	#   my $result = $m->Data->{Result};
	#   if ($result =~ /^200 (.+)/s) {
	#     # pretty print this result
	#     my $cycl = $1;
	#     my $structure = $light->Parse(Contents => $cycl);
	#     my $pretty = $light->PrettyGenerate
	#       (
	#        PrettyPrint => 1,
	#        Structure => $structure->{Domain},
	#       );
	#     return {
	# 	    Success => 1,
	# 	    Result => {
	# 		       Structure => $structure,
	# 		       Pretty => $pretty,
	# 		      },
	# 	   };
	#   }
	# }
      },
      KNext => sub {
	my $self = $UNIVERSAL::textanalysis;
	$self->MyKNext->Process(Contents => $_[0]->{Text});
      },
      Linkipedia => sub {
	my $self = $UNIVERSAL::textanalysis;
	$self->MyLinkipedia->Linkify(Query => $_[0]->{Text});
      },
     });

  $self->Skip
    ($args{Skip} ||
     {
      NamedEntityRecognition => 1,
     });

  $self->DontSkip
    ($args{DontSkip});

  $self->Results({});
}

sub AnalyzeText {
  my ($self,%args) = @_;
  return $self->ProcessText
    (
     Text => $args{Text},
     Date => $args{Date},
     Overwrite => $args{Overwrite},
     NoRetrieve => $args{NoRetrieve},
     OnlyRetrieve => $args{OnlyRetrieve},
     Skip => $args{Skip},
     DontSkip => $args{DontSkip},
    );
}

sub AnalyzeSentences {
  my ($self,%args) = @_;
  # okay do everything we know how to do on this
  my $sentences = get_sentences($args{Text});
  my @list;
  foreach my $sentence (@$sentences) {
    push @list, $self->ProcessText(Text => $sentence);
  }
  print Dumper(\@list);
}

sub ProcessText {
  my ($self,%args) = @_;
  my $results;
  # my $versions =
  #   {
  #    GetDatesTIMEX3 => 1,
  #    NounPhraseExtraction => 1,
  #    TermExtraction => 1,
  #    Tokenization => 1,

  #    CoreferenceResolution => 2,
  #    CycLsForNP => 2,
  #    DateExtraction => 2,
  #    FactExtraction => 2,
  #    KNext => 2,
  #    MontyLingua => 2,
  #    NamedEntityRecognition => 2,
  #    SemanticAnnotation => 2,
  #    DBpediaSpotlight => 2,
  #    SpeechActClassification => 2,
  #    WSD => 2,

  #    Linkipedia => 3,
  #   };

  my $overwrite = $args{Overwrite} || {};
  my $skip = $args{Skip} || $self->Skip;
  my $dontskip = $args{DontSkip} || $self->DontSkip;
  if ($args{Light}) {
    $skip = {
	     CoreferenceResolution => 1,
	     CycLsForNP => 1,
	     DateExtraction => 1,
	     FactExtraction => 1,
	     # GetDatesTIMEX3 => 1,
	     KNext => 1,
	     Linkipedia => 1,
	     MontyLingua => 1,
	     NamedEntityRecognition => 1,
	     # NounPhraseExtraction => 1,
	     SemanticAnnotation => 1,
	     DBpediaSpotlight => 1,
	     SpeechActClassification => 1,
	     # TermExtraction => 1,
	     # Tokenization => 1,
	     WSD => 1,
	    };
    $dontskip = {
		 # CoreferenceResolution => 1,
		 # CycLsForNP => 1,
		 # DateExtraction => 1,
		 # FactExtraction => 1,
		 GetDatesTIMEX3 => 1,
		 # KNext => 1,
		 # MontyLingua => 1,
		 # NamedEntityRecognition => 1,
		 NounPhraseExtraction => 1,
		 # SemanticAnnotation => 1,
		 # DBpediaSpotlight => 1,
		 # SpeechActClassification => 1,
		 TermExtraction => 1,
		 Tokenization => 1,
		 # WSD => 1,
		};
  }
  my $hasdontskip = ! ! scalar keys %$dontskip;
  print Dumper({Skip => $skip}) if 1; # $UNIVERSAL::debug;
  print Dumper({DontSkip => $dontskip}) if 1; # $UNIVERSAL::debug;
  $self->IsCached({});
  foreach my $key (keys %{$self->Codes}) {
    my $doesntsaytoskip = ! exists $skip->{$key};
    my $saysdontskip = exists $dontskip->{$key};
    my $proceed = 0;
    if ($hasdontskip) {
      if ($saysdontskip) {
	$proceed = 1;
      }
    } else {
      if ($doesntsaytoskip) {
	$proceed = 1;
      }
    }
    if ($proceed) {
      print "Doing $key\n";
      my $complete = 0;
      if (! exists $self->HasBeenInitialized->{$key}) {

	# check Sayer to see if it's in the cache so we don't have to
	# bother initializing at least for now
	my $res = $self->MySayer->ExecuteCodeOnData
	  (
	   GiveHasResult => 1,
	   CodeRef => $self->Codes->{$key},
	   Data => [{
		     Text => $args{Text},
		     Date => $args{Date},
		    }],
	   Overwrite => (exists $overwrite->{$key} or exists $overwrite->{_ALL}),
	   NoRetrieve => $args{NoRetrieve},
	   Skip => $args{Skip},
	  );
	print Dumper({RawResults => $res}) if $args{Debug};
	if ($res->{Success}) {
	  $results->{$key} = $res->{Result};
	  $complete = 1;
	} else {
	  print "Initializing $key\n";
	  if (exists $self->Inits->{$key}) {
	    &{$self->Inits->{$key}}($self);
	  }
	  $self->HasBeenInitialized->{$key} = 1;
	}
      }
      if (! $complete) {
	$results->{$key} =
	  [
	   $self->MySayer->ExecuteCodeOnData
	   (
	    CodeRef => $self->Codes->{$key},
	    Data => [{
		      Text => $args{Text},
		      Date => $args{Date},
		     }],
	    Overwrite => (exists $overwrite->{$key} or exists $overwrite->{_ALL}),
	    NoRetrieve => $args{NoRetrieve},
	    OnlyRetrieve => $args{OnlyRetrieve},
	    Skip => $args{Skip},
	   ),
	  ];
	$self->IsCached->{$key} = $self->MySayer->IsCached();
      }
    }
  }
  my $all = 1;
  foreach my $key (keys %{$self->IsCached}) {
    if (! $self->IsCached->{$key}) {
      $all = 0;
      last;
    }
  }
  $self->AllResultsWereCached($all);
  return $results;
}

1;

# NounPhraseExtraction NamedEntityRecognition Tokenization TermExtraction SemanticAnnotation DateExtraction
