#!/usr/bin/perl -w

use Lingua::Translate;

my $languages = {
		 "Chinese" => "zh",
		 "Dutch" => "nl",
		 "French" => "fr",
		 "German" => "en",
		 "Greek" => "el",
		 "Italian" => "it",
		 "Japanese" => "ja",
		 "Korean" => "ko",
		 "Portuguese" => "pt",
		 "Russian" => "ru",
		 "Spanish" => "es",
		};

my $english = "I would like some cigarettes and a box of matches";
print "$english\n";
foreach my $key (keys %$languages) {
  my $dl = $languages->{$key};
  print "Translating to $key\n";
  my $xl8r = Lingua::Translate->new(src => "en",
				    dest => $dl)
    or die "No translation server available for en -> $dl";
  my $dest = $xl8r->translate($english); # dies or croaks on error
  print "\t$dest\n";
}
