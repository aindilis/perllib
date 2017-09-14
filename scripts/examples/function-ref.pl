#!/usr/bin/perl -w

my $things = {
	      "" => "hi",
	      "ARRAY" => ["hi"],
	      "HASH" => {"hi" => 1},
	      "Regexp" => qr/hi/,
	      "CODE" => sub {print "hi\n"},
	     };

foreach my $key (sort keys %$things) {
  my $ref = ref $things->{$key};
  print "Key: <$key>\n";
  if ($key ne $ref) {
    print "<$key> ne <$ref>\n";
  }
}
