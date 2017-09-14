package System::Apertium;

use Data::Dumper;
use Lingua::Identify qw(:language_identification);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / ReadableLanguages Languages /

  ];

sub init {
  my ($self,%args) = @_;
  $self->ReadableLanguages
    ($args{ReadableLanguages} || ["en"]);
  $self->PopulateLanguageTranslationMatrix;
}


sub Translate {
  my ($self,%args) = @_;
  my $fromlang = lc(scalar langof($args{Text}));
  if ($fromlang) {
    # now we have our pair
    foreach my $tolang (@{$self->ReadableLanguages}) {
      my $res = $self->TranslateBetweenPairs
	(Text => $args{Text},
	 From => $fromlang,
	 To => $tolang);
      if ($res->{Result} eq "success") {
	return $res;
      }
    }
  }
  return {
	  Result => "failure",
	  Contents => $args{Text},
	 };
}

sub TranslateBetweenPairs {
  my ($self,%args) = @_;
  my $path = $self->GetPath
    (
     To => $args{To},
     From => $args{From},
    );
  if (scalar @$path) {
    return $self->TranslateTextUsingPath
	(Path => $path,
	 Text => $args{Text});
  } else {
    return {
	    Result => "failure",
	    Error => "no translation path",
	   };
  }
}

sub TranslateTextUsingPair {
  my ($self,%args) = @_;
  # try three times and give up if apertium crashed
  my $retries = 3;
  my $res;
  do {
    $res = $self->TranslateTextUsingPairInner(%args);
    $retries--;
  } while ($retries and exists $res->{Error} and $res->{Error} eq "apertium crashed");
  return $res;
}

sub TranslateTextUsingPairInner {
  my ($self,%args) = @_;
  my $from = $args{Pair}->[0];
  my $to = $args{Pair}->[1];

  my $OUT;

  my $f = "/tmp/system-apertium-$from";
  my $g = "/tmp/system-apertium-$to";
  my $h = "/tmp/system-apertium-log";
  system "rm -f '$f' '$g' '$h'";

  open (OUT,">$f") or die "can't\n";
  print OUT $args{Text};

  my $command = "((apertium $from-$to $f $g) 3>&2 2>&1 1>&3) 2>&1 | tee $h";
  # my $command = "((echo '======= Backtrace: =========') 3>&2 2>&1 1>&3) 2>&1 | tee $h";
  # print $command."\n";

  `$command`;

  my $c = `cat "$h"`;

  if ($c =~ /======= Backtrace: =========/) {
    return {
	    Result => "failure",
	    Error => "apertium crashed",
	   };
  }
  if (! -f $g) {
    return {
	    Result => "failure",
	    Error => "no output file",
	   };
  }
  my $contents = `cat "$g"`;
  return {
	  Result => "success",
	  Contents => $contents,
	 };
}

sub TranslateTextUsingPath {
  my ($self,%args) = @_;
  my $path = $args{Path};
  if (scalar @$path > 1) {
    my $from = $path->[0];
    my $to = $path->[1];
    my $res = $self->TranslateTextUsingPair
      (Pair => [$from,$to],
       Text => $args{Text});
    if ($res->{Result} eq "success") {
      shift @$path;
      return $self->TranslateTextUsingPath
	(Path => $path,
	 Text => $res->{Contents});
    } else {
      return $res;
    }
  } else {
    # just return the text, it is in the correct language
    return {
	    Result => "success",
	    Contents => $args{Text},
	   };
  }
}

sub GetPath {
  my ($self,%args) = @_;
  my $marked = {};
  my @accessible = ({
		     Lang => $args{From},
		     Path => [$args{From}],
		    });
  while (@accessible) {
    my $thing = shift @accessible;
    if (exists $self->Languages->{$thing->{Lang}}) {
      foreach my $tolang (keys %{$self->Languages->{$thing->{Lang}}}) {
	if ($tolang eq $args{To}) {
	  # this is the correct path
	  my @path = @{$thing->{Path}};
	  push @path, $tolang;
	  return \@path;
	}
	if (! $marked->{$tolang}) {
	  my @path = @{$thing->{Path}};
	  push @path, $tolang;
	  push @accessible, {
			     Lang => $tolang,
			     Path => \@path,
			    };
	  $marked->{$tolang} = 1;
	}
      }
    }
  }
  return [];
}


sub PopulateLanguageTranslationMatrix {
  my ($self,%args) = @_;
  my $langs = "en-ca es-ca es-gl es-pt es-ro fr-ca";
  my $lang = {};
  foreach my $langpair (split / /, $langs) {
    my $res = [split /-/,$langpair];
    $lang->{$res->[0]}->{$res->[1]} = 1;
    $lang->{$res->[1]}->{$res->[0]} = 1;
  }
  $self->Languages($lang);
}

1;
