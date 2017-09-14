#!/usr/bin/perl -w

use System::WWW::Firefox;
use PerlLib::SwissArmyKnife;

# ensure that we can start and stop the Firefox app
my $firefox1 = System::WWW::Firefox->new
  (
   Method => 'Normal',
   ViewHeadless => 1,
  );
if ($firefox1->MyIsRunningP(System => 'Firefox')) {
  print "IS RUNNING\n";
}

# ensure that we can get data off the website
my $c1 = $firefox1->GetContent(URL => 'http://frdcsa.org/frdcsa');
print Dumper({C1 => $c1});
if ($c1->{Res2} =~ /FLOSS applications/is) {
   print "YES\n";
}

$firefox1->StopServer();
$firefox1->MyIsRunningP(System => 'Firefox');


# # ensure that we can start and stop the Tor Browser Bundle app
# my $firefox2 = System::WWW::Firefox->new(Method => 'Tor');
# $firefox2->MyIsRunningP(System => 'Firefox');

# # ensure that we can get data off the website
# $firefox2->GetContent(URL => 'http://frdcsa.org/frdcsa');
# my $c2 = $firefox2->Contents();
# if ($c2 =~ /free and floss/is) {
#   print "Yes\n";
# }

# $Firefox2->StopServer();
# $firefox2->MyIsRunningP(System => 'Firefox');
