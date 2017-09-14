#!/usr/bin/perl -w

use System::WWW::Firefox;

my $firefox = System::WWW::Firefox->new();

# ensure that we can start and stop the Firefox app
my $firefox1 = System::WWW::Firefox->new(Method => 'Normal');
$firefox1->StartServer();
$firefox1->IsRunningP();

# ensure that we can get data off the website
$firefox1->GetContent(URI => 'http://frdcsa.org/frdcsa');
my $c = $firefox1->Contents();
if ($c =~ /free and floss/is) {
  print "Yes\n";
}

$firefox1->StopServer();
$firefox1->IsRunningP();



# ensure that we can start and stop the Tor Browser Bundle app
my $firefox2 = System::WWW::Firefox->new(Method => 'Tor');
$firefox2->StartServer();
$firefox2->IsRunningP();

# ensure that we can get data off the website
$firefox2->GetContent(URI => 'http://frdcsa.org/frdcsa');
my $c = $firefox2->Contents();
if ($c =~ /free and floss/is) {
  print "Yes\n";
}

$firefox2->StopServer();
$firefox2->IsRunningP();
