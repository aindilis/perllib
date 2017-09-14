package Rival::Lingua::Translate;

use Sayer;

use Data::Dumper;
use HTML::Entities ();
use Lingua::Translate;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / XL8R MySayer Src Dest Inits Codes TempTranslationCache MaximumBabelfishTranslateSize Encoding /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MaximumBabelfishTranslateSize(9000);
  $self->Src($args{src});
  $self->Dest($args{dest});
  $self->XL8R
    (Lingua::Translate->new
     (%args));
  $self->MySayer
    ($args{Sayer} ||
     Sayer->new
     (DBName => "sayer_translate"));
  $self->Inits
    ({
      Translate => sub {
	my $self = shift;
      },
     });
  $self->Codes
    ({
      Translate => sub {
	my $self = $UNIVERSAL::RivalLinguaTranslate;
	return $self->TempTranslationCache;
      },
     });
  $self->Encoding
    ({
      '"' => "JFDISJDFJDSDSFJDS",
      '<' => "luf293ufewjldsffds",
      '>' => "fjds9jfsdfjodsjsl",
      "'" => "fjdsfj29e0jfdsfsdl",
     });
}

sub translate {
  my ($self,$text,%args) = @_;
  $UNIVERSAL::RivalLinguaTranslate = $self;
  # break it into small portions and store the results
  my $raretoken = $args{RareToken};
  if ($raretoken) {
    my @items = split /$raretoken/, $text;
    my @results;
    my @toprocess;
    my $i = -1;
    while (scalar @items) {
      my @chunk;
      while (scalar @items and (length(join($raretoken,map {$_->[0]} @chunk)) < $self->MaximumBabelfishTranslateSize)) {
	my $item = shift @items;
	++$i;
	# see if it has already been cached by sayer
	# be sure to mention which language pair
	if ($self->MySayer->ExecuteCodeOnData
	    (
	     HasResult => 1,
	     CodeRef => $self->Codes->{Translate},
	     Data => [{
		       Src => $self->Src,
		       Dest => $self->Dest,
		       Text => $item,
		      }],
	    )) {
	  my @translated = $self->MySayer->ExecuteCodeOnData
	    (
	     CodeRef => $self->Codes->{Translate},
	     Data => [{
		       Src => $self->Src,
		       Dest => $self->Dest,
		       Text => $item,
		      }],
	    );
	  print Dumper(\@translated);
	  $results[$i] = $translated;
	} else {
	  push @chunk, [$item,$i];
	}
      }
      if (scalar @items) {
	my $thing = pop @chunk;
	unshift @items, $thing->[0];
	$i--;
      }

      my $translated =
	$self->Decode
	  ($self->XL8R->translate
	   ($self->Encode
	    (join($raretoken,map {$_->[0]} @chunk))));

      print Dumper($translated);

      # delay here, to prevent crowding the server, but print
      # something to indicate progress
      sleep 5;
      print ".\n";

      # do some appropriate error checking here
      if (! $translated) {
	# error
	print "ERROR $translated\n";
      } else {
	# add this to the result, in order

	# now cache each individual entry, twice, once for uncleaned,
	# once for cleaned
	my @translatedchunk = split /$raretoken/, $translated;
	foreach my $thing (@chunk) {
	  my $t = shift @translatedchunk;
	  $results[$thing->[1]] = $t;

	  # we want to put this in the translation cache
	  $self->TempTranslationCache($t);

	  # now call the function to store it
	  $self->MySayer->ExecuteCodeOnData
	    (
	     CodeRef => $self->Codes->{Translate},
	     Data => [{
		       Src => $self->Src,
		       Dest => $self->Dest,
		       Text => $thing->[0],
		      }],
	    );

	  if (0) {
	    # now do the cleaned version
	    $self->TempTranslationCache($self->Clean($t));
	    $self->MySayer->ExecuteCodeOnData
	      (
	       CodeRef => $self->Codes->{Translate},
	       Data => [{
			 Src => $self->Src,
			 Dest => $self->Dest,
			 Text => $self->Clean($thing->[0]),
			}],
	      );
	  }
	}
      }
    }
    return join($raretoken,@results);
  }
}

sub Clean {
  my ($self,$text) = @_;
  # add something here later on
  return $text;
}

sub Encode {
  my ($self,$text) = @_;
  foreach my $key (keys %{$self->Encoding}) {
    my $value = $self->Encoding->{$key};
    # $key = "\\".$key;
    # print Dumper({Key => $key});
    $text =~ s/$key/$value/sg;
  }
  # print Dumper($text);
  return HTML::Entities::encode
      ($text);
}

sub Decode {
  my ($self,$text) = @_;
  my $text2 = HTML::Entities::decode
      ($text);
  foreach my $key (keys %{$self->Encoding}) {
    my $value = $self->Encoding->{$key};
    $text2 =~ s/$value/$key/sg;
  }
  return $text2;
}

1;
