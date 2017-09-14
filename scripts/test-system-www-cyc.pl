#!/usr/bin/perl -w

use System::WWW::Cyc;

my $wwwcyc = System::WWW::Cyc->new();

my $res = $wwwcyc->SearchForConstant(Constant => '#$AndrewDougherty');

