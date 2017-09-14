#!/usr/bin/perl -w

use System::EclipseProlog;

use PerlLib::SwissArmyKnife;

my $eclipseprolog = System::EclipseProlog->new();

$eclipseprolog->StartServer;
my $res1 = $eclipseprolog->ProcessInteraction(Query => "['test-eclipse'].");
my $res2 = $eclipseprolog->ProcessInteraction(Query => 'b(X).');
print Dumper({Res => [$res1,$res2]});o

# use System::EclipseProlog::UniLang::Client;
# use System::Enju::UniLang::Client;
