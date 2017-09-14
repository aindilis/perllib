#!/usr/bin/perl -w 
#
# driver for tagging time expressions
# this driver is aimed at TDT data
# Author:         George Wilson  - gwilson@mitre.org
# Last modified:  Jan 2003
# Copyright 2003  George Wilson

use  Lingua::EN::Extract::Dates::TempEx;
use  Lingua::EN::Extract::Dates::TempEx qw($TEmonthabbr %Month2Num);

use Data::Dumper;

## Expecting POS tags of the form
## <lex pos="NN">dog</lex>
## Change this if you use a different name
SetLexTagName("lex");

###   Nothing to change below this line
#######################################


# Read one document at a time
$/ = "<\/DOC>";

$HL        = 3;
$FirstDate = 0;
$TagHeader = 0;
$WARN      = 1;

#Process command line flags
while ((defined $ARGV[0]) && ($ARGV[0] =~ /^-/)) {
  $flag = shift(@ARGV);

  if ($flag eq "-h") {
    Usage(); exit(1);
  } elsif ($flag =~ /\A-D(\d)\Z/o) {
    $TE_DEBUG  = $1;
  } elsif ($flag =~ /\A-HL(\d)\Z/o) {
    $HL        = $1;
  } elsif ($flag =~ /\A-S([01])\Z/o) {
    $TE_Speed  = $1;
  } elsif ($flag =~ /\A-FD\Z/o) {
    $FirstDate = 1;
  } elsif ($flag =~ /\A-FDNW\Z/o) {
    $FirstDate = 1; $WARN = 0;
  } elsif ($flag =~ /\A-TH\Z/o) {
    $TagHeader = 1;
  } else {
    print STDERR "Unknown flag $flag\n";
    Usage(); exit(1);
  }
}

$Tag = "<[^>]+>";

# Main loop to process documents
while (<>) {
  #   unless (/<\/DOC>/o) {
  #     print; next;
  #   }
  if (/<DOC>/o) {
    print $`; $_ = $& . $';
  }
  $TE_HeurLevel = $HL;

  #extract date
  if (/<(DATE_TIME|DATE|DL|DD)>(.*)<\/(DATE_TIME|DATE|DL|DD)>/oi) {
    $temp = $2;
    $RefDate = Date2ISO($temp);
    if ($RefDate =~ /XXXXXXXX/o) {
      print STDERR "Failed to understand input date: $temp\n";
      print STDERR " Please report this format to the author.\n";
      print;   next;
    }
    if ($TagHeader) {
      $QMT = quotemeta($temp);
      s/>$QMT</><TIMEX2 VAL=\"$RefDate\">$temp<\/TIMEX2></i;
    }
  } elsif (/<[^>]*air_date=\"([^\"]+)\">/oi) {
    $temp = $1;
    $RefDate = Date2ISO($temp);
    if ($RefDate =~ /XXXXXXXX/o) {
      print STDERR "Failed to understand input date: $temp\n";
      print STDERR " Please report this format to the author.\n";
      print;   next;
    }
    if ($TagHeader) {
      $QMT = quotemeta($temp);
      s/>$QMT</><TIMEX2 VAL=\"$RefDate\">$temp<\/TIMEX2></i;
    }
  } elsif (/(\A|\n)Date:(.*)/io) {
    $temp = $2;
    chomp $temp;
    if (/(\A|\n)Time:(.*)/io) {
      $temp2 = $2;
      chomp $temp2;
      if (($temp2 =~ /\d\d\d\d/o) && ($temp2 !~ /[^\s0-9]/o)) {
	$temp2 .= " hours";
      }
      $temp .= " $temp2";
    }
    $RefDate = Date2ISO($temp);
  } elsif (/\S/) {
    $temp = length($_);
    unless($FirstDate)  {
      print STDERR "Warning: No date tag - $temp\n";
      print STDERR "You might want to use the FD flag\n";
      print STDERR "Skipping this document.\n";
      if ($temp < 100) {
	print STDERR "$_\n\n";
      }
      print;  next;
    }

    if (/\b$TEmonthabbr\.?\w*(?:$Tag)?\s+(?:$Tag)?([0123]?\d)(?:$Tag)*,?(?:$Tag)?\s+(?:$Tag)?([12]\d{3})\b/io) {
      $RefDate = sprintf("%4d%02d%02d", $3, $Month2Num{lc($1)}, $2);
    } elsif (/\b([0123]?\d)(?:$Tag)?\s+(?:$Tag)?$TEmonthabbr\.?\w*(?:$Tag)?\s+(?:$Tag)?([12]\d{3})\b/io) {
      $RefDate = sprintf("%4d%02d%02d", $3, $Month2Num{lc($2)}, $1);
    } elsif (/\b$TEmonthabbr\.?\w*(?:$Tag)?(?:$Tag)*,?(?:$Tag)?\s+(?:$Tag)?([12]\d{3})\b/io) {
      $RefDate = sprintf("%4d%02d%02d", $2, $Month2Num{lc($1)}, 15);
    } elsif (/\b([12]\d{3})\b/io) {
      $RefDate = sprintf("%4d%02d%02d", $1, 6, 30);
    } else {
      if ($WARN) {
	print STDERR "Warning: No reference date found in document\n";
      }
      $TE_HeurLevel = 0;
      $RefDate = 0;
    }
  }

  $Rest = $_;

  # loop through sentences
  while ($Rest =~ /(<\/s>)/io) {
    $b4     = $`;
    $EndTag = $1;
    $Rest   = $';

    $b4 =~ /(.*)(<s>)/ios;
    print $1;
    $StartTag = $2;
    $Sent = $';

    # Process sentences here
    $Sent = &TE_TagTIMEX($Sent);
    $Sent = &TE_AddAttributes($Sent, $RefDate);
    print "$StartTag$Sent$EndTag";
  }
  print "$Rest";
}

## End of Main program ##


sub Usage {
  # Display help message

  print "Usage:   TimeTag.pl [-h -FD -TH -Dn -HLn -Sn] files\n";
  print "                                  n is a number\n";
  print "         h    = help message\n";
  print "         FD   = First Date found will be used as reference date\n";
  print "         FDNW = First Date found will be used as reference date\n";
  print "                No Warnings given\n";
  print "         TH   = Tag Header, not tagged by default\n";
  print "         D    = Debug Level      -  0,1,2     default=0\n";
  print "         HL   = Heuristic Level  -  0,1,2,3   default=3\n";
  print "         S    = Speed Level      -  0,1       default=0\n\n";

}

# Copyright 2003 George Wilson
