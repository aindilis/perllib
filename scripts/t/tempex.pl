#!/usr/bin/perl -w

use Lingua::EN::Extract::Dates;

use Data::Dumper;

my $text = "Call Eva tonight.  Go to class tomorrow.";

my $lingua = Lingua::EN::Extract::Dates->new;

print Dumper($lingua->TimeRecognizeText(Text => $text));
