package Rival::Lingua::EN::Sentence;

use Rival::Lingua::EN::Sentence::Helper qw(get_sentences_helper);

use Data::Dumper;
use Error qw(:try);
use IO::File;

require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw (get_sentences rival_get_sentences);

sub rival_get_sentences {
  return get_sentences(@_);
}

sub get_sentences {
  my ($text) = shift;
  my $sent = get_sentences_helper($text);
  my $numberofsentences = scalar @$sent;
  my $verbose = 0;
  my @alltokens = split /[^A-Za-z0-9]+/, $text;
  my $quit = 0;
  my $sent2;
  my @tokens;
  my @context;
  my @sentencesresult = ();
  while (! $quit) {
    while (@$sent) {
      my $innerquit = 0;
      while (! $innerquit) {
	if (! scalar @$sent) {
	  if (! scalar @alltokens) {
	    $innerquit = 1;
	  } else {
	    my $data = Dumper({
			       Version => 1,
			       Token => [$tokens[0]],
			       AllToken => [$alltokens[0]],
			       Tokens => \@tokens,
			       AllTokens => [@alltokens[0..4]],
			       # Context => [$context[0]],
			       AllContext => [@context[0..1]],
			      });
	    print $data if $verbose;
	  }
	}
	while (scalar @$sent and ! scalar @tokens) {
	  push @sentencesresult, join('',@output);
	  print "Count: ".(scalar @sentencesresult)."/$numberofsentences\n" if $verbose;
	  @output = ();
	  do {
	    $sent2 = shift @$sent;
	    print Dumper({Sent2 => $sent2}) if $verbose;
	    if ($sent2 =~ /^[^A-Za-z0-9]+$/) {
	      push @sentencesresult, $sent2;
	    }
	  } while (scalar @$sent and $sent2 =~ /^[^A-Za-z0-9]+$/);
	  @tokens = ();
	  @context = ();
	  my @items = $sent2 =~ /(.*?)([A-Za-z0-9]+)(.*?)/sg;
	  if (scalar @items) {
	    $items[-1] = substr($sent2,length(join('',@items)));
	  }
	  my $i = 0;
	  while (@items) {
	    my $pre = shift @items;
	    my $token = shift @items;
	    my $post = shift @items;
	    print "<Token: $token>\n" if $verbose;
	    push @tokens, $token;
	    $context[$i++] = [$pre,$token,$post];
	  }
	  print Dumper({TransTokens => \@tokens}) if $verbose;
	  print Dumper({Context => \@context}) if $verbose > 2;
	}
	my $alltoken;
	if ((scalar @tokens and scalar @alltokens) and $alltokens[0] eq $tokens[0]) {
	  # print "ho\n" if $verbose;
	  my $alltoken = shift @alltokens;
	  shift @tokens;
	  my $context = shift @context;
	  print Dumper({Context => $context}) if $verbose;
	  my $added = join("", @$context);
	  print "<Added: $added>\n" if $verbose;
	  push @output, $added;
	} else {
	  print "hi\n" if $verbose;

	  if (scalar @tokens) {
	    print "Tokens: <".$tokens[0].">\n" if $verbose;
	  } else {
	    print "Tokens: empty\n" if $verbose;
	  }
	  if (scalar @alltokens) {
	    print "AllTokens: <".$alltokens[0].">\n" if $verbose;
	  } else {
	    print "AllTokens: empty\n" if $verbose;
	  }

	  # FIXME: See this about fixing the incorrect  counts
	  # /var/lib/myfrdcsa/codebases/internal/clear/lab

	  my @res;
	  if (! (scalar @tokens or scalar @alltokens)) {
	    $innerquit = 1;
	  } elsif (scalar @alltokens and $alltokens[0] eq '') {
	    shift @alltokens;
	  } elsif (scalar @alltokens and $alltokens[0] =~ /^(+)$/) {
	    my $length = length($alltokens[0]);
	    shift @alltokens;
	    if (exists $context[0] and exists $context[0][0]) {
	      print "1 LENGTH $length\n" if $verbose;
	      my $tmpcount = 0;
	      foreach my $char (split //, $context[0][0]) {
		++$tmpcount if $char eq '';
	      }
	      $context[0][0] = $context[0][0].('' x ($length - $tmpcount));
	    } else {
	      print "2 LENGTH $length\n" if $verbose;
	      push @sentencesresult,('' x $length);
	    }
	  } elsif (scalar @alltokens and $alltokens[0] =~ /(+)/) {
	    my $length = length($1);
	    @res = $alltokens[0] =~ /^([^]*?)({$length})([^]*?)$/s;
	    # '^LTable' -> ['','','Table']
	    print Dumper({Res => \@res}) if $verbose;
	    shift @alltokens;
	    unshift @alltokens, @res;
	  } else {
	    my $fh1 = IO::File->new();
	    my $fh2 = IO::File->new();
	    my $errorsdir = "/var/lib/myfrdcsa/codebases/internal/perllib/data/rival/lingua/en/sentence/errors";
	    if (! -d $errorsdir) {
	      system "mkdir -p $errorsdir";
	    }
	    my $i = 1;
	    my $filename = "$errorsdir/$i-error.txt";
	    my $originalfilename = "$errorsdir/$i-orig.txt";
	    while (-f $filename) {
	      ++$i;
	      $filename = "$errorsdir/$i-error.txt";
	      $originalfilename = "$errorsdir/$i-orig.txt";
	    }
	    $fh1->open(">$filename") or
	      warn "Cannot open $filename\n";
	    $fh2->open(">$originalfilename") or
	      warn "Cannot open $originalfilename\n";
	    my $data = Dumper({
			       Version => 3,
			       Filename => $filename,
			       OriginalFilename => $originalfilename,
			       Token => [$tokens[0]],
			       AllToken => [$alltokens[0]],
			       Tokens => \@tokens,
			       AllTokens => [@alltokens[0..4]],
			       # AllTokens => [splice(@alltokens,0,5)],

			       # Context => [$context[0]],

			       AllContext => [@context[0..1]],
			       # AllContext => [splice(@context,0,2)],
			      });
	    print $data if $verbose;
	    print $fh1 $data;
	    print $fh2 $text;
	    $fh1->close();
	    $fh2->close();
	    # try to align
	    # just die for now
	    throw Error "Error trying to parse sentences, result logged in <$filename>.\n";
	  }
	}
      }
    }
    if (! scalar @alltokens) {
      $quit = 1;
    } elsif ($alltokens[0] =~ /^(+)$/) {
      my $length = length($1);
      print "3 LENGTH $length\n" if $verbose;
      $sentencesresult[-1] = $sentencesresult[-1].('' x $length);
      $quit = 1;
    } else {
      print Dumper({AllTokens => \@alltokens}) if $verbose;
      die "Not aligned\n";
    }
  }
  return \@sentencesresult;
}

1;
